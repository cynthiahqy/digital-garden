library(tidyverse)

meta_regex <- "(\\d{2}:\\d{2}:\\d{2}) From (.+?) to (.+?):"

reply_regex <- "^\tReplying to \"(.+?)\"\\s?$"
react_regex <- "^\tReacted to \"(.+?)\" with \"?(.+?)\"?$"
unreact_regex <- "^\tRemoved a (.+?) reaction from \"(.+?)\"$"

chat_txt <- file("~/Desktop/meeting_saved_chat.txt", "r")
chat <- list()
while (length(line <- readLines(chat_txt, n = 1))) {
    if (stringr::str_starts(line, "\t")) {
        # Continuation of event

        # Skip empty log line
        if (line == "\t") next
        if (str_detect(line, reply_regex)) {
            chat[[length(chat)]]$type <- "reply"
            parts <- str_match(line, reply_regex)
            chat[[length(chat)]]$target <- parts[, 2]
        } else if (str_detect(line, react_regex)) {
            chat[[length(chat)]]$type <- "react"
            parts <- str_match(line, react_regex)
            chat[[length(chat)]]$target <- parts[, 2]
            chat[[length(chat)]]$emoji <- parts[, 3]
        } else if (str_detect(line, unreact_regex)) {
            chat[[length(chat)]]$type <- "unreact"
            parts <- str_match(line, unreact_regex)
            chat[[length(chat)]]$target <- parts[, 3]
            chat[[length(chat)]]$emoji <- parts[, 2]
        } else {
            # Message contents
            chat[[length(chat)]]$message <- paste0(chat[[length(chat)]][["message"]], sub("^\t", "", line), collapse = "\n")
        }
    } else {
        # New event
        meta <- stringr::str_match(line, meta_regex)
        chat[[length(chat) + 1L]] <- tibble(
            time = hms::as_hms(meta[, 2]),
            from = meta[, 3],
            to = meta[, 4],
            type = "message"
        )
    }
}
close(chat_txt)

chat <- bind_rows(chat) |>
    mutate(
        time = as.POSIXct(paste("2024-03-08", time), tz = "Australia/Melbourne")
    )

# Match reacts to messages
# (
#   assumes unique matching of messages!
#   this can be improved by matching in time order.
# )
chat_msg <- chat |>
    filter(!is.na(message)) |>
    mutate(message_match = substr(trimws(message), 1L, 14L))

chat_react <- chat |>
    filter(is.na(message)) |>
    select(-message) |>
    mutate(target = substr(trimws(target), 1L, 14L)) |>
    nest(reactions = c(time, from, to, type, emoji))

chat_with_reacts <- left_join(chat_msg, chat_react, by = c("message_match" = "target")) |>
    select(-emoji)

chat_replies <- chat_with_reacts |>
    filter(type == "reply") |>
    mutate(target = substr(trimws(target), 1L, 14L)) |>
    nest(replies = c(-target))

chat_tidy <- chat_with_reacts |>
    filter(type == "message") |>
    left_join(chat_replies, by = c("message_match" = "target")) |>
    select(-target, -message_match)
chat_tidy |>
    mutate(nreact = map_dbl(replies, NROW)) |>
    arrange(desc(nreact)) |>
    transmute(time, from, message, nreact)

chat_tidy |>
    ggplot(aes(x = time)) +
    geom_density(bw = 100)

chat_tidy |>
    mutate(
        time_bin = ceiling_date(time, "2 minutes")
    ) |>
    group_by(time_bin) |>
    summarise(
        n_msg = sum(map_dbl(replies, NROW)) + n()
    ) |>
    ggplot(aes(x = time_bin, y = n_msg)) +
    geom_col()

chat_tidy |>
    select(replies) |>
    unnest(replies) |>
    bind_rows(chat_tidy) |>
    ggplot(aes(x = time)) +
    geom_density(bw = 100)
