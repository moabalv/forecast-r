library(tidyverse)
library(forecast)

data <- read_csv("https://raw.githubusercontent.com/moabalv/analise-dados/main/walmart-sales-dataset-of-45stores.csv")
names(data)
lojas <- data %>%
  select(Store, Weekly_Sales, Date) %>%
  rename(store = Store, weekly_sales = Weekly_Sales, date = Date) %>%
  mutate(date = as.POSIXct(date, format = "%d-%m-%Y"))

loja_1 <- lojas %>%
  filter(store == 1, date > 01-01-2011) %>%
  select(date, weekly_sales)

ts_loja <- loja_1 %>%
  select(weekly_sales) %>%
  ts(frequency = 52, start = c(2010,5), end = c(2012,43))

ts_loja.train = window(ts_loja, end = time(ts_loja)[115])
ts_loja.test = window(ts_loja, start= time(ts_loja)[116])

fit <- stl(ts_loja.train[,1], s.window = 54)
autoplot(fit)

fc <- fit %>% 
  forecast(method = "naive", h = 28) 

fc %>%
  autoplot(include = 10) +
  autolayer(ts_loja.test)


checkresiduals(fc)
accuracy(fc, ts_loja.test)
