# -*- coding: utf-8 -*-
# One file Shiny application
# Based on data from KimonoLabs RIA API

shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput('snapshots', label = h3('Use X last snapshots:'),
                  min = 1, max = 10, value = 1)
      
    ),
    mainPanel(h1('Wordcloud of last news'),
              plotOutput('cloud'),
              p('Timestamp:'),
              textOutput('lasttry')
    )
  )
))