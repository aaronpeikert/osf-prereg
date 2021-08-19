library(magrittr)
#source(here::here("R", "retrieve.R"))
prepare_dates <- function(raw) {
  dplyr::select(raw,
                analytics_key,
                date_modified,
                date_created,
                date_registered) %>%
    dplyr::mutate(dplyr::across(dplyr::starts_with("date"), lubridate::as_datetime))
}

prepare_registration_ <- function(registration_responses) {
  registration_responses %>%
    dplyr::select(-matches(".*uploader.*")) %>%
    purrr::map_dfc(clinch_character)
}

concenate_questions <- function(questions) {
  purrr::map(questions, stringr::str_replace_na, "") %>%
    purrr::pmap_chr(stringr::str_c,
                    sep = "\n",
                    collapse = "\n") %>%
    stringr::str_squish()
}

prepare_registration <- function(registration_responses) {
  concenate_questions(prepare_registration_(registration_responses))
}

clinch_character <- function(x) {
  all_vector <- purrr::map_lgl(x, ~ is.vector(.x) | is.null(.x))
  if (any(!all_vector))
    x[!all_vector] <- NA_character_
  x <- purrr::map_chr(x, stringr::str_c, collapse = "\n")
  dplyr::if_else(x == "", NA_character_, x)
}

prepare_files <- function(registration_responses) {
  uploads <- dplyr::select(registration_responses, matches("upload"))
  if (ncol(uploads) == 0L)
    return(rep(list(NA_character_), nrow(registration_responses)))
  uploads %>%
    purrr::map(prepare_files_) %>%
    purrr::pmap(function(...)
      purrr::flatten_chr(list(...)))
}

prepare_files_ <- function(upload) {
  upload %>% purrr::map("file_name") %>% purrr::map_if(is.null, function(x)
    NA_character_)
}

extract_keep <-
  . %>% dplyr::mutate(
    registration_text = prepare_registration(registration_responses),
    files = prepare_files(registration_responses),
    date_registered = lubridate::as_datetime(date_registered),
    date_created = lubridate::as_datetime(date_created)
  )
extract <- . %>%
  extract_keep() %>%
  dplyr::select(
    title,
    description,
    registration_text,
    files,
    date_created,
    date_registered,
    withdrawn
  )

files <- fs::dir_ls("data")

preregistrations <- files %>%
  purrr::map_dfr(
    ~ jsonlite::read_json(.x, simplifyVector = TRUE) %>%
      purrr::keep( ~ "registration_responses" %in% names(.x)) %>%
      purrr::map_dfr(extract)
  )
# first_last <- files %>%
#   sort() %>%
#   .[c(1, length(.))] %>%
#   fs::path_file() %>%
#   fs::path_ext_remove()
# outfile <-
#   stringr::str_c("osf-registrations-from-", first_last[1], "-till-", first_last[2], ".csv")

outfile <- "osf-registrations.csv"
readr::write_csv(preregistrations, here::here( outfile))
