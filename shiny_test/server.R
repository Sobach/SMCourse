# -*- coding: utf-8 -*-
# One file Shiny application
# Based on data from KimonoLabs RIA API

# File: server.R

# Required libraries. 
library(RCurl)   # http-requests
library(rjson)   # decoder for json objects
library(SnowballC) # tm compatibility
library(tm)      # text-mining package
library(RColorBrewer)  # brewer color palettes
library(wordcloud)     # wordcloud graph

api.name <- '1xl232p8'
api.key <- 'DTndIua4tfpz5kxITOILI6FvmGV8xw9g'

# Server object:
# number of input-output functions,
# describing controls and outputs

shinyServer(function(input, output) {
  js.data <- reactive({
    json.url <- paste0('https://www.kimonolabs.com/api/', api.name, '?apikey=', api.key)
    json.file <- getURL(json.url, .encoding = 'UTF-8', .opts = list(ssl.verifypeer = FALSE))
    json.data <- fromJSON(json.file)
  })
  
  csv.data <- reactive({
    df <- data.frame()
    for(i in 1:input$snapshots){
      j <- js.data()$version - i + 1
      csv.url <- paste0('https://www.kimonolabs.com/api/csv/', j, '/', api.name, '?apikey=', api.key)
      csv.file <- getURL(csv.url, .encoding = 'UTF-8', .opts = list(ssl.verifypeer = FALSE))
      csv.rows <- read.csv(textConnection(csv.file), skip=1)
      df <- rbind(df, csv.rows)
    }
    df <- unique(df)
  })
  
  output$distPlot <- renderPlot({
    hist(rnorm(input$obs), col = 'darkgray', border = 'white')
  })
  
  output$lasttry <- renderText({
    js.data()$thisversionrun
  })
  
  output$cloud <- renderPlot({
    df <- csv.data()
    df$f.txt <- paste(df$title.text, df$text, sep=": ")
    corp <- Corpus(DataframeSource(data.frame(df[, "f.txt"])))
    corp <- tm_map(corp, removePunctuation)
    corp <- tm_map(corp, tolower)
    corp <- tm_map(corp, function(x) removeWords(x, stopwords("ru")))
    tdm <- TermDocumentMatrix(corp)
    m <- as.matrix(tdm)
    v <- sort(rowSums(m),decreasing=TRUE)
    d <- data.frame(word = names(v),freq=v)
    pal <- brewer.pal(9, "Blues")
    img <- wordcloud(d$word[1:30], d$freq[1:30], 
                     random.order=T, colors=pal, max.words=100
                     )
    print(img)
  })
}
)
