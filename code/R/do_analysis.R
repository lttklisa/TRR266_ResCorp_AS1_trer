library(dplyr)
library(ggplot2)
library(ExPanDaR)

load("data/generated/sample.rda")

##Figure World Map

library(ggmap)
library(maps)
world_map <- map_data("world")
names(world_map)[names(world_map)=="region"] <- "country"

#Changing some country names
  world_map$country[world_map$country=="USA"] <- "United States"
  world_map$country[world_map$country=="UK"] <- "United Kingdom"
  world_map$country[world_map$country=="Russia"] <- "Russian Federation"
  world_map$country[world_map$country=="Democratic Republic of the Congo"] <- "Congo, Dem. Rep."
  world_map$country[world_map$country=="Republic of Congo"] <- "Congo, Rep."
  world_map$country[world_map$country=="Ireland"] <- "Ireland-Rep"
  world_map$country[world_map$country=="Hong Kong SAR, China"] <- "Hong Kong"
  world_map$country[world_map$country=="United Arab Emirates"] <- "Utd Arab Em"
  world_map$country[world_map$country=="Slovakia"] <- "Slovak Rep"
  world_map$country[world_map$country=="Egypt"] <- "Egypt, Arab Rep."
  world_map$country[world_map$country=="Uganda"] <- "Uganda"
  world_map$country[world_map$country=="Ghana"] <- "Ghana"
  world_map$country[world_map$country=="Iran"] <- "Iran, Islamic Rep."
  world_map$country[world_map$country=="Yemen"] <- "Yemen, Rep."
  world_map$country[world_map$country=="Venezuela"] <- "Venezuela, RB."

card <- dplyr::left_join(world_map, smp, by.x="country")
card <- card[order(card$group, card$order),]
fig_world <- ggplot(card, aes(x=long, y=lat, group=group)) + geom_polygon(aes(fill=life_expectancy), color="black") + scale_fill_gradient(low="royalblue1", high="brown3", na.value="grey80") +
  theme_minimal() +xlab("Longitude") + ylab("Latitude")

#Other figures and tables 

fig_scatter <- ggplot(
  smp, aes(x = ln_gdp_capita, y = life_expectancy, color = region)
) +
  geom_point(alpha = 0.3) +
  labs(
    color = "World Bank Region",
    x = "Ln(Income per capita in thsd. 2010 US-$)",
    y = "Life expectancy in years"
  ) +
  theme_minimal()

tab_desc_stat <- prepare_descriptive_table(
  smp %>% select(-year, -ln_gdp_capita, -ln_health_capita)
)

tab_corr <- prepare_correlation_table(
  smp %>% select(-year, -gdp_capita, -health_exp_capita),
  format = "latex", booktabs = TRUE, linesep = ""
)

tab_regression <-  prepare_regression_table(
  smp,
  dvs = rep("life_expectancy", 5),
  idvs = list(
    c("ln_gdp_capita"),
    c("ln_gdp_capita", "unemployment"),
    c("ln_health_capita", "unemployment"),
    c("ln_gdp_capita", "unemployment"),
    c("ln_gdp_capita", "unemployment")
  ),
  feffects = list("", "","", "year", c("country", "year")),
  cluster = list("", "","",  "year", c("country", "year")),
  format = "latex"
)

smp_high <- smp[smp$income_level=="High income" | smp$income_level=="Upper middle income",]
tab_regression_high <-  prepare_regression_table(
  smp_high,
  dvs = rep("life_expectancy", 5),
  idvs = list(
    c("ln_gdp_capita"),
    c("ln_gdp_capita", "unemployment"),
    c("ln_health_capita", "unemployment"),
    c("ln_gdp_capita", "unemployment"),
    c("ln_gdp_capita", "unemployment")
  ),
  feffects = list("", "","", "year", c("country", "year")),
  cluster = list("", "","",  "year", c("country", "year")),
  format = "latex"
)

save(
  list = c(ls(pattern = "fig_*"), ls(pattern = "tab_*")),
  file = "output/results.rda"
)
