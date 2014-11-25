# -*- coding: utf-8 -*-
setwd('~/Documents/vis_opportunities')
Sys.setlocale(category = "LC_ALL", locale = "UTF-8")
df <- read.csv('ria_lenta.csv')
head(df)
nrow(df)

df$timestamp <- strptime(as.character(df$timestamp), format = '%Y-%m-%d %H:%M:%S')

df$day <- strftime(df$timestamp, format='%d %b')

filter.vec <- append(grep('путин', tolower(df$text)), grep('путин', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$putin <- FALSE
df$putin[filter.vec] <- TRUE

filter.vec <- append(grep('обама', tolower(df$text)), grep('обама', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$obama <- FALSE
df$obama[filter.vec] <- TRUE

filter.vec <- append(grep('меркель', tolower(df$text)), grep('меркель', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$merkel <- FALSE
df$merkel[filter.vec] <- TRUE

filter.vec <- append(grep('порошенко', tolower(df$text)), grep('порошенко', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$porosh <- FALSE
df$porosh[filter.vec] <- TRUE

100*sum(df$putin | df$obama | df$merkel | df$porosh)/nrow(df)

sum.df <- data.frame()
sum.df <- rbind(sum.df, table(df$obama, df$day)['TRUE', ])
sum.df <- rbind(sum.df, table(df$putin, df$day)['TRUE', ])
sum.df <- rbind(sum.df, table(df$merkel, df$day)['TRUE', ])
sum.df <- rbind(sum.df, table(df$porosh, df$day)['TRUE', ])
names(sum.df) <- colnames(table(df$obama, df$day))
rownames(sum.df) <- c('Obama', 'Putin', 'Merkel', 'Poroshenko')
write.csv(sum.df, 'persons.csv')

library(tm)
df$f.txt <- paste(df$title.text, df$text, sep=": ")
corp <- Corpus(DataframeSource(data.frame(df[, "f.txt"])))
corp <- tm_map(corp, removePunctuation)
corp <- tm_map(corp, content_transformer(tolower))
corp <- tm_map(corp, function(x) removeWords(x, stopwords("ru")))
tdm <- TermDocumentMatrix(corp)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
d <- d[d$freq >= 100, ]
write.csv(d, 'wordcloud.csv', row.names = FALSE)


filter.vec <- append(grep('росси', tolower(df$text)), grep('росси', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$rus <- FALSE
df$rus[filter.vec] <- TRUE

filter.vec <- append(grep('сша', tolower(df$text)), grep('сша', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$us <- FALSE
df$us[filter.vec] <- TRUE

filter.vec <- append(grep('герман', tolower(df$text)), grep('герман', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$de <- FALSE
df$de[filter.vec] <- TRUE

filter.vec <- append(grep('украин', tolower(df$text)), grep('украин', tolower(df$title.text)))
filter.vec <- unique(filter.vec)
df$ukraine <- FALSE
df$ukraine[filter.vec] <- TRUE

100*sum(df$rus | df$us | df$de | df$ukraine)/nrow(df)

sum.df <- data.frame()
sum.df <- rbind(sum.df, table(df$us, df$day)['TRUE', ])
sum.df <- rbind(sum.df, table(df$rus, df$day)['TRUE', ])
sum.df <- rbind(sum.df, table(df$de, df$day)['TRUE', ])
sum.df <- rbind(sum.df, table(df$ukraine, df$day)['TRUE', ])
names(sum.df) <- colnames(table(df$rus, df$day))
rownames(sum.df) <- c('USA', 'Russia', 'Germany', 'Ukraine')
write.csv(sum.df, 'countries.csv')