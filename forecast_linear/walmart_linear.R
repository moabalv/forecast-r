library(tidyverse)
library(forecast)


data <- read.csv("https://raw.githubusercontent.com/moabalv/analise-dados/main/walmart-sales-dataset-of-45stores.csv")
names(data)

lojas <- data %>%
  select(Store, Weekly_Sales, Date) %>%
  rename(store = Store, weekly_sales = Weekly_Sales, date = Date) %>%
  group_by(store)

ts_loja <- lojas %>%
  filter(store == 1) %>%
  ungroup() %>%
  select(weekly_sales) %>%
  ts(frequency = 52, start = c(2010,5), end = c(2012,43))

autoplot(ts_loja) +
  ggtitle("Walmart: vendas da loja 1") +
  xlab("Ano") +
  ylab("Vendas")

ggseasonplot(ts_loja) +
  ggtitle("Sazonalidade das vendas") +
  xlab("Semana") + 
  ylab("Vendas")


autoplot(forecast(ts_loja))

fit_loja1 <- tslm(ts_loja ~ season + trend)
fc_linear <- forecast(fit_loja1, h = 104)
autoplot(fc_linear)

fit_loja1 <- tslm(ts_loja ~ season)
fc_linear <- forecast(fit_loja1, h = 104)
autoplot(fc_linear)

fit_loja1 <- tslm(ts_loja ~ trend)
fc_linear <- forecast(fit_loja1, h = 104)
autoplot(fc_linear)

