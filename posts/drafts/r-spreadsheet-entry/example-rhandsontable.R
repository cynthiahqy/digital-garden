library(rhandsontable)

DF <- data.frame(
    val = 1:10, bool = TRUE, big = LETTERS[1:10],
    small = letters[1:10],
    dt = seq(from = Sys.Date(), by = "days", length.out = 10),
    stringsAsFactors = FALSE
)

DF$chart <- c(
    sapply(
        1:5,
        function(x) {
            jsonlite::toJSON(list(
                values = rnorm(10),
                options = list(type = "bar")
            ))
        }
    ),
    sapply(
        1:5,
        function(x) {
            jsonlite::toJSON(list(
                values = rnorm(10),
                options = list(type = "line")
            ))
        }
    )
)

rhandsontable(DF, rowHeaders = NULL, width = 550, height = 300) %>%
    hot_col("chart", renderer = htmlwidgets::JS("renderSparkline"))
