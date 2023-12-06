library(fpp2)
library(tidyverse)

date <- as.Date(time(elec))
time(elec)
df <- data.frame(timestamp = date, value = elec)

df %>%
  ggplot(aes(timestamp, value)) +
  geom_line() +
  labs(y = "Produção Elétrica", x = "Tempo", title = "Produção de Eletricidade na Austrália") +
  scale_x_date(date_labels = "%Y", date_breaks = "3 year") +
  theme_bw()

train = window(elec, end = time(elec)[380])
test = window(elec, start = time(elec)[381])

lambda <- BoxCox.lambda(train)
transf_data <- BoxCox(train, lambda)
autoplot(transf_data)
fc_transf <- forecast(transf_data, h = 96)
fc_transf <- InvBoxCox(fc_transf$mean, lambda)

autoplot(fc_transf) +
  autolayer(test)

accuracy(fc_transf, test)
fc <- forecast(train, h = 96)
accuracy(fc,test)
