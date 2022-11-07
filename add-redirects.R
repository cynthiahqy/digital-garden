# website section redirects

# list names of gallery folders
posts <- list.dirs(
  path = here::here("gallery/sketchnotes"),
  full.names = FALSE,
  recursive = FALSE
)

# extract the slugs
slugs <- gsub("^.*_", "", posts)

# lines to insert to a netlify _redirect file
redirects <- paste0("/", slugs, " ", "/gallery/sketchnotes/", posts)

# write the _redirect file
write(redirects,
      file=file.path(Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR"), "_redirects"),
      append=TRUE
)
