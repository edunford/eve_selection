library(revemetrics)
library(caTools)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(scales)
library(lubridate)
library(tidyverse)
library(showtext)
library(Cairo)
font.add.google("Roboto Condensed")
showtext.auto()

tmp <- revemetrics::GetCounter(c(1411,0,0), days = 1000) %>%
  mutate(value_ma = runmean(value, 28))

png("c:/temp/plot.png", width = 1200, height = 800)
CairoPNG("c:/temp/plot2.png", width = 1200, height = 800)
tmp %>%
  gather(variable, value, -date) %>%
  mutate(variable = forcats::fct_recode(variable, "Daily Series" = "value", "28D Moving Average" = "value_ma")) %>%
  ggplot(aes(date, value, size = variable, color = variable)) +
  geom_line() +
  theme_fivethirtyeight(18, "Roboto Condensed") +
  scale_size_manual(values = c("Daily Series" = 0.5, "28D Moving Average" = 1), guide = F) +
  scale_color_fivethirtyeight() +
  scale_y_continuous(breaks = pretty_breaks(10), limits = c(0,NA)) +
  labs(title = "Title", color = "")
dev.off()

