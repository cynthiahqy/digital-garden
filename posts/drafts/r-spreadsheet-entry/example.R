sheet <- tibble::tibble()
sheet <- edit(sheet)
sheet |> datapasta::tribble_paste()

sheet <- tibble::tribble(
    ~month, ~ndays,
    "jan", 31,
    "feb", 28,
    "mar", 31,
    "apr", 30,
    "may", 31,
    "jun", 30,
    "jul", 31
)

utils::data.entry(sheet)

new_sheet <- vi(sheet)
