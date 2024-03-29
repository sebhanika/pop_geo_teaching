# Title: Deaths
# Date: 2023-09-22
# Purpose: deaths in sweden
# /* cSpell:disable */

library(dplyr)
library(ggplot2)
library(tidyr)
library(HMDHFDplus)
library(ggthemes)
library(countrycode)
library(nationalparkcolors)

source("scripts/0_config.R")
source("scripts/0_settings.R")

# Load data --------------

deaths <-
    readHMDweb(
        CNTRY = "SWE",
        item = "Deaths_1x1",
        username = hmd_username,
        password = hmd_password,
        fixup = TRUE
    ) %>%
    select(-c(Total)) %>%
    pivot_longer(
        cols = c(Female, Male),
        names_to = "Sex"
    ) %>%
    mutate(value = ifelse(value == 0, NA, value))


plot_deaths <- deaths %>%
    filter(Year == 2022) %>%
    ggplot(aes(x = Age, y = value, col = Sex, linetype = Sex)) +
    geom_line(linewidth = 1.1, alpha = 0.75) +
    scale_color_manual(values = (c("#9C6114", "#000080"))) +
    scale_linetype_manual(values = (c(1, 3))) +
    theme(
        legend.position = c(0.094, 0.91),
        legend.background = element_rect(
            linetype = "solid",
            color = "black"
        ),
        legend.key.width = unit(2, "cm"),
    ) +
    labs(
        x = "Age",
        y = "Deaths",
        title = "Number of deaths in Sweden in 2022",
        caption = "Source: Human Mortality Database (2023)"
    )

plot_deaths


ggsave(
    filename = "viszs/deaths.png",
    plot = plot_deaths, width = 32, height = 18, units = "cm"
)



# Trying out USA and Switzerland --------------


# Load data --------------

# Specify countries of interest
deaths_countries <- c("USA", "CHE")


# create labels if
cntry_labels <- setNames(
    countrycode(deaths_countries,
        origin = "iso3c",
        destination = "country.name"
    ),
    deaths_countries
)

mort <- list()
for (i in seq_along(deaths_countries)) {
    mort[[i]] <- readHMDweb(
        CNTRY = deaths_countries[i],
        "Deaths_1x1",
        username = hmd_username,
        password = hmd_password,
        fixup = TRUE
    )
    mort[[i]]$CNTRY <- deaths_countries[i]
}

# combine data
dat_che_usa <- do.call(dplyr::bind_rows, mort) %>%
    select(-c(Total)) %>%
    pivot_longer(
        cols = c(Female, Male),
        names_to = "Sex"
    ) %>%
    mutate(value = ifelse(value == 0, NA, value))


deaths_usa_che <- dat_che_usa %>%
    filter(Year == 2019) %>%
    ggplot(aes(x = Age, y = value, col = Sex, linetype = Sex)) +
    geom_line(linewidth = 1.1, alpha = 0.75) +
    scale_color_manual(values = (c("#9C6114", "#000080"))) +
    scale_linetype_manual(values = (c(1, 3))) +
    theme(
        legend.position = c(0.094, 0.91),
        legend.background = element_rect(
            linetype = "solid",
            color = "black"
        ),
        legend.key.width = unit(2, "cm"),
    ) +
    labs(
        x = "Age",
        y = "Deaths",
        title = "Number of deaths in 2019",
        caption = "Source: Human Mortality Database (2023)"
    ) +
    facet_wrap(~CNTRY,
        labeller = as_labeller(cntry_labels),
        scales = "free"
    )


ggsave(
    filename = "viszs/deaths_usa_che.png",
    plot = deaths_usa_che, width = 32, height = 18, units = "cm"
)
