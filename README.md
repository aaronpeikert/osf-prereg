
<!-- README.md is generated from README.Rmd. Please edit that file -->

# OSF Preregistrations

<!-- badges: start -->

<!-- badges: end -->

This repository simply scrapes the Open Science Framework’s (OSF) API to
get all preregistrations posted there since 2018 (2018-01-01) till today
(2021-08-19). No magic involved, just asking the api and flattening the
JSON into a single string and extracting attached files.

You can either run the script yourself getting the data hot and fresh
(either with
[Docker](https://github.com/aaronpeikert/osf-prereg/releases/download/v0.1/osf-prereg.tar.gz)
`make DOCKER=TRUE` or without Docker `make`) or [here is a CSV
version](https://github.com/aaronpeikert/osf-prereg/releases/tag/v0.1)
([compressed](https://github.com/aaronpeikert/osf-prereg/releases/download/v0.1/osf-registrations.csv.tar.gz)
and
[uncompressed](https://github.com/aaronpeikert/osf-prereg/releases/download/v0.1/osf-registrations-from-2018-01-01-till-2021-08-19.csv)).
