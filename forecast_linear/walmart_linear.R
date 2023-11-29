library(tidyverse)
library(forecast)


data <- read_csv("https://raw.githubusercontent.com/moabalv/analise-dados/main/walmart-sales-dataset-of-45stores.csv")
names(data)
lojas <- data %>%
  select(Store, Weekly_Sales, Date) %>%
  rename(store = Store, weekly_sales = Weekly_Sales, date = Date) %>%
  mutate(date = as.POSIXct(date, format = "%d-%m-%Y"))

loja_1 <- lojas %>%
  filter(store == 1) %>%
  select(date, weekly_sales)

ts_loja <- loja_1 %>%
  select(weekly_sales) %>%
  ts(frequency = 52, start = c(2010,5), end = c(2012,43))

ggplot(ts_loja) +
  geom_line(mapping = aes(y = ts_loja[], x = loja_1$date)) +
  scale_x_datetime(name = "Ano e mês", date_labels = "%Y-%m", date_breaks = "3 month") + 
  labs(y = "Vendas") +
  theme_bw()

plot(decompose(ts_loja))

ts_loja.train = window(ts_loja, end = time(ts_loja)[115])
ts_loja.test = window(ts_loja, start= time(ts_loja)[116])

fc <- forecast(ts_loja.train, h = 28)

autoplot(fc, include = 10) +
  autolayer(ts_loja.test, series = "Observado")
accuracy(fc, ts_loja.test)

fit_loja1 <- tslm(ts_loja.train ~ season + trend)
fc_linear <- forecast(fit_loja1, h = 28)

autoplot(fc_linear, include = 10, series = "Previsto") +
  autolayer(ts_loja.test, series = "Observado") +
  labs(y = "Vendas", x = "Ano") +
  scale_color_manual(values = c("Observado" = "red"))

accuracy(fc_linear, ts_loja.test)
autoplot(checkresiduals(fit_loja1))
