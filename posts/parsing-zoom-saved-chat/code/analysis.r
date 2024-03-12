library(jsonlite)
library(tidyverse)

chat_df <- read_json("do-not-track/chat_df.json", simplifyVector = TRUE)
chat_date <- "2024-03-08"
chat_tz <- "Australia/Melbourne"

msg_tbl <- chat_df |>
    as_tibble() |>
    rowid_to_column() |>
    mutate(across(
        c(type, message, interacts),
        ~ na_if(.x, "")
    )) |>
    # mutate(across(c(message, interacts),
    # ~ emoji_extract_all(.x, simplify = FALSE),
    # .names = "emoji_{.col}")
    # )
    # mutate(type = replace_na(message))
    # mutate(content = coalesce(message, interacts)) |>
    mutate(datetime = {
        paste(chat_date, time) |>
            ymd_hms(tz = chat_tz)
    }) |>
    select(-time) |>
    select(
        rowid, datetime, type, sender,
        lines, message, interacts, everything()
    )

set.seed(42)
msg_ehm <- msg_tbl |>
    mutate(
        dt_hm = ceiling_date(datetime, "minute"),
        elapsed = difftime(dt_hm, min(dt_hm), units = "mins"),
        dt_hr = hour(datetime),
        dt_min = minute(datetime)
    ) |>
    select(-datetime) |>
    tidyr::unite(
        col = "content",
        interacts, message,
        na.rm = TRUE
    ) |>
    mutate(emojis = emoji_extract_all(content)) |>
    mutate(
        emoji_paste =
            map_chr(emojis, ~ paste0(.x, collapse = "")),
        uniq_emoji = map(emojis, unique),
        uniq_emoji_paste =
            map_chr(uniq_emoji, ~ paste0(.x, collapse = "")),
        n_emoji_clap = str_count(uniq_emoji_paste, emoji("clap")),
        emoji_clap = map_lgl(emojis, ~ any(str_detect(.x, emoji("clap"))))
    )

msg_mins <- msg_ehm |>
    group_by(dt_hm, elapsed) |>
    summarise(
        n_events = n(),
        n_claps = sum(n_emoji_clap),
        has_clap = any(emoji_clap),
        random_emoji = sample(uniq_emoji_paste, 1) |>
            emoji_modifier_remove()
    ) |>
    mutate(diff_n_events = n_events - lag(n_events))

ggplot(
    msg_mins,
    aes(x = dt_hm, y = n_events)
) +
    geom_point(
        data = filter(msg_mins, has_clap == TRUE),
        mapping = aes(y = n_claps),
        fill = "pink",
        colour = "pink"
    ) +
    geom_line()
# scale_y_sqrt()
# geom_line() +
# geom_point(aes(colour = has_clap))

# facet_wrap(~type, ncol = 1, scales = "free")

msg_ehm |>
    filter(type != "remove") |>
    group_by(dt_hm, elapsed, type) |>
    summarise(
        n_events = n(),
        random_emoji = sample(uniq_emoji_paste, 1) |>
            emoji_modifier_remove()
    ) |>
    mutate(diff_n_events = n_events - lag(n_events))

ggplot(aes(
    x = dt_hm, y = n_events,
    fill = type, colour = type
)) +
    geom_line()


prev_talk_end <-
    ymd_hm(paste(chat_date, "12:52"), tz = chat_tz)
my_talk_end <- prev_talk_end + minutes(10)

msg_tbl |>
    filter(!(type %in% c("reaction", "remove"))) |>
    filter(datetime > prev_talk_end & datetime < my_talk_end) |>
    filter(str_detect(message, regex("thank", ignore_case = TRUE)))
