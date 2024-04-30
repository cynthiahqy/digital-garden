# source(here::here("_utilities/travel_dates_load.R"))
library(ggplot2)
library(ggiraph)

## ---- daily-loc-prep ----

## expand dates: https://stackoverflow.com/a/54728153

travel_days <- travel_dates |>
    mutate(nights = interval(startDate, endDate) / days(1)) |>
    arrange(startDate, desc(nights)) |>
    rowid_to_column() |>
    rowwise() |>
    reframe(rowid, location, details, nights,
        date = seq(startDate, endDate, by = "day")
    ) |>
    group_by(date) |>
    slice_min(order_by = nights, n = 1) |>
    ungroup() |>
    mutate(country = countrycode::countryname(location, "iso2c"))

away_days <- travel_days |>
    summarise(
        startDate = min(date),
        endDate = max(date)
    ) |>
    mutate(rowid = 0, location = "TBC") |>
    reframe(rowid, location, date = seq(startDate, endDate, by = "day"))

daily_loc <- away_days |>
    anti_join(travel_days, by = "date") |>
    bind_rows(travel_days) |>
    mutate(
        flag = countrycode::countrycode(country, "iso2c", "unicode.symbol"),
        continent = countrycode::countrycode(country, "iso2c", "continent")
    ) |>
    mutate(flag = case_when(
        location == "en route" ~ "\u2708",
        location == "TBC" ~ "❔",
        TRUE ~ flag
    ))

## ---- prep-full-calendar-data ----

# based on: https://github.com/nrennie/tidytuesday/blob/9dbe69d696f6c1edad41a72d157a42f3b5a63a81/2023/2023-03-07/20230307.R

# calculate extra months to make plot rectangular
cal_ncol <- 3
startMonth <- month(floor_date(min(travel_days$date), "month"))
endMonth <- month(ceiling_date(max(travel_days$date), "month") - 1)
n_extra_month <- cal_ncol - ((endMonth - startMonth + 1) %% cal_ncol)
padding_days <- summarise(
    travel_days,
    startDate = floor_date(min(date), "month"),
    endDate = ceiling_date(max(date) %m+% months(n_extra_month), "month") - 1
) |>
    reframe(date = seq(startDate, endDate, by = "day"))

# prepare calendar data
full_calendar <- padding_days |>
    anti_join(daily_loc, by = "date") |>
    bind_rows(daily_loc) |>
    mutate(
        Year = year(date),
        Month = month(date, label = TRUE),
        Day = wday(date, label = TRUE, week_start = 1),
        mday = mday(date),
        Month_week = (5 + day(date) +
            wday(floor_date(date, "month"), week_start = 1)) %/% 7
    )

## ---- travel-dates-calendar-display ----

base_data_aes <- full_calendar |>
    ggplot(aes(x = Day, y = Month_week))

layers_geom_text <- list(
    geom_text(aes(label = mday), nudge_y = 0.25),
    geom_text(aes(label = flag), nudge_y = -0.25)
)
layers_scale_coord <- list(
    scale_y_reverse(),
    coord_fixed(expand = TRUE)
)
layers_facet_labs <- list(
    facet_wrap(vars(Month),
        ncol = cal_ncol
    ),
    labs(y = NULL, x = NULL)
)
layers_theme <- list(
    theme_bw(),
    theme(
        plot.margin = margin(0, 0, 0, 0),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        # panel.spacing = unit(0, "lines"),
        panel.border = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_blank(),
        strip.background = element_rect(fill = "grey95"),
        strip.text = element_text(hjust = 0)
    )
)

## ---- tooltip-travel-calendar ----

p_cal_girafe <- base_data_aes +
    geom_tile_interactive(
        aes(
            tooltip = paste(details, "@", location),
            data_id = location
        ),
        alpha = 0.2,
        fill = "transparent",
        colour = "grey80"
    ) +
    layers_geom_text +
    layers_scale_coord +
    coord_fixed(expand = FALSE) +
    layers_facet_labs +
    layers_theme

# girafe(ggobj = p_cal_girafe)
