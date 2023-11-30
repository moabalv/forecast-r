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

dff <- tibble(data.frame(timestamp = loja_1$date, values = ts_loja))
ggplot(dff, aes(timestamp, weekly_sales)) +
  geom_line() +
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
fc_linear

media <- fc_linear$mean
upper <- fc_linear$upper
lower <- fc_linear$lower
train <- tail(ts_loja.train, 10)

teste <- zoo::as.yearmon(time(media))

teste
### meu autoplot ####

ggplot(data = media, aes(y = media[], x = time(media))) +
  geom_line(color = "blue")+
  geom_ribbon(aes(ymin = lower[,1], ymax = upper[,1]), alpha = 0.35, fill = "blue") +
  geom_ribbon(aes(ymin = lower[,2], ymax = upper[,2]), alpha = 0.15, fill = "blue") +
  labs(title = "Comparação vendas reais e previstas", y = "Vendas", x = "Tempo") +
  geom_line(train, mapping = aes(x = time(train), y = train[])) +
  scale_y_continuous() +
  geom_line(ts_loja.test, mapping = aes(x= time(ts_loja.test), y = ts_loja.test[]), color =  "red")

#######################

autoplot(fc_linear, include = 10) +
  geom_line(ts_loja.test, mapping = aes(x= time(ts_loja.test), y = ts_loja.test[]), color =  "red")

autoplot(fc_linear, include = 10, series = "Previsto") +
  autolayer(ts_loja.test, series = "Observado") +
  labs(y = "Vendas", x = "Ano") +
  scale_color_manual(values = c("Observado" = "red"))

accuracy(fc_linear, ts_loja.test)
autoplot(checkresiduals(fit_loja1))

###
