# Declaring constants
api.name <- '1xl232p8'
api.key <- 'DTndIua4tfpz5kxITOILI6FvmGV8xw9g'

# Loading libraries
library(RCurl)
library(rjson)

# Constructing URL
json.url <- paste0('https://www.kimonolabs.com/api/', api.name, '?apikey=', api.key)

# Loading json as list
json.file <- getURL(json.url, .encoding = 'UTF-8')
json.data <- fromJSON(json.file)

# Parsing JSON fucntion
results.from.json <- function(json.data){
  df <- data.frame(title=c(), link=c(), time=c(), text=c())
  for(item in json.data$results$collection1){
    r = data.frame(title = item$title$text,
                   link = item$title$href,
                   time = item$timestamp,
                   text = item$text)
    df <- rbind(df, r)
  }
  return(df)
}

# Parsing JSON
results.from.json(json.data)

# Parsing csv - it's simplier
csv.url <- paste0('https://www.kimonolabs.com/api/csv/', api.name, '?apikey=', api.key)
csv.file <- getURL(csv.url, .encoding = 'UTF-8')
csv.rows <- read.csv(textConnection(csv.file), skip=1)

# Parsing all data: current and previous
df <- data.frame()

for(i in 1:json.data$version){
  print(i)
  csv.url <- paste0('https://www.kimonolabs.com/api/csv/', i, '/', api.name, '?apikey=', api.key)
  csv.file <- getURL(csv.url, .encoding = 'UTF-8')
  csv.rows <- read.csv(textConnection(csv.file), skip=1)
  df <- rbind(df, csv.rows)
}

# Clearing from duplicates
nrow(df)
df <- unique(df)
nrow(df)

# Transforming date-time strings to date-time objects
df$timestamp <- strptime(as.character(df$timestamp), format = '%H:%M %d.%m.%Y')

# Simple plot
hist(df$timestamp, breaks='hours')

# Summary
summary(df$timestamp)

# DEALING WITH DATES
# Filtering by datetime
timelimits <- list(
  from = as.POSIXct('2014-10-30 00:00:00'),
  to = as.POSIXct('2014-10-30 23:59:59')
  )

df.filtered.1 <- df[df$timestamp >= timelimits$from & df$timestamp <= timelimits$to, ]
summary(df.filtered.1$timestamp)
hist(df.filtered.1$timestamp, breaks='hours')

# Summarizing by hour
df$hour <- df$timestamp$hour
hist(df$hour, breaks=24)

# Summarizing by date
df$day <- strftime(df$timestamp, format='%d %b')

# DEALING WITH TEXT
# Filtering by one field
df[grep('путин', tolower(df$text)), ]

# Filtering by multiple fields
filter.vec <- append(grep('путин', tolower(df$text)), grep('путин', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df[filter.vec, ]

# PLOTTING
library(ggplot2)
library(RColorBrewer)

df.plot <- aggregate(df, by = list(df$day, df$hour), FUN = length)
df.plot <- df.plot[, 1:3]
names(df.plot) <- c('Date', 'Hour', 'Amount')

# Define palette
specPal <- colorRampPalette(rev(brewer.pal(11, "Spectral")))

plot <- ggplot(df.plot,
              aes(x = Hour, y = Date, fill = Amount))
plot <- plot + geom_tile()
plot <- plot + scale_fill_gradientn(guide="colourbar", colours = specPal(100), guide_legend(title="Количество \nновостей"))
plot <- plot + scale_x_discrete("Часы", limits=0:22, labels=0:23)
plot <- plot + scale_y_discrete("Дата")
plot <- plot + coord_equal()
plot <- plot + theme_bw()
plot <- plot + theme(legend.position="bottom", legend.background = element_rect(colour = "grey"))
plot <- plot + ggtitle(expression("Частота публикации новостей"))
plot