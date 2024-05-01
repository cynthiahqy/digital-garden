#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| file: code-blocks/calendR-calendR.R
#
#
#
#
#
#
#
#
#
#
#| file: code-blocks/ggweekly-ggweek_planner.R
#
#
#
#
#
#
#
#
#
#
#
ggcal(dates, fills)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| file: code-blocks/ggtilecal-recipe.R
#| code-fold: true
#| code-line-numbers: true
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
gg_facet_wrap_months(
  .events_long,
  date_col,
  locale = NULL,
  week_start = NULL,
  nrow = NULL,
  ncol = NULL,
  .geom = list(
    geom_tile(color = "grey70", fill = "transparent"),
    geom_text(nudge_y = 0.25)
  ),
  .scale_coord = list(
    scale_y_reverse(),
    scale_x_discrete(position = "top"),
    coord_fixed(expand = TRUE)),
  .theme = list(theme_bw_tilecal()),
  .other = list()
)
#
#
#
#
#
#
gg_facet_wrap_months <- function(...){
  cal_data <- fill_missing_units({{ date_col }}) |>
    calc_calendar_vars({{ date_col }})

  base_plot <- cal_data |>
    ggplot2::ggplot(mapping = aes_string(
      x = "TC_wday_label",
      y = "TC_month_week",
      label = "TC_mday"
    )) +
    facet_wrap(c("TC_month_label"), axes = "all_x", nrow = nrow, ncol = ncol) +
    labs(y = NULL, x = NULL) +
    .geom +
    .scale_coord +
    .theme +
    .others

  base_plot
}
#
#
#
#
#
#
#
#
#
#| code-fold: true
#| code-summary: "Show code for static calendar example"
#| eval: true
library(ggplot2)
library(ggtilecal)
make_empty_month_days(c("2024-01-05", "2024-06-30")) |>
  gg_facet_wrap_months(unit_date,
                       .geom = list(
                         geom_tile(color = "grey70",
                                   fill = "transparent"),
                         geom_text(nudge_y = 0.25,
                                   color = "#6a329f")),
                       .theme = list(
                         theme_bw_tilecal(),
                         theme(strip.background = element_rect(fill = "#d9d2e9")))
                       )
#
#
#
#
#
#| eval: true
#| code-fold: true
#| code-summary: "Show code for interactive calendar example"
#| fig.height: 3
#| fig.width: 9
# remotes::install_github("cynthiahqy/ggtilecal")
library(ggiraph)
library(ggplot2)
library(ggtilecal)

gi <- demo_events_gpt |>
    reframe_events(startDate, endDate) |>
  gg_facet_wrap_months(unit_date) +
  geom_text(aes(label = event_emoji), nudge_y = -0.25, na.rm = TRUE) +
  geom_tile_interactive(
        aes(
            tooltip = paste(event_title),
            data_id = event_id
        ),
        alpha = 0.2,
        fill = "transparent",
        colour = "grey80"
    )

girafe(ggobj = gi)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
