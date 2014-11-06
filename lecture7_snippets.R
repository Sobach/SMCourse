# -*- coding: utf-8 -*-
# One file Shiny application
# Based on data from KimonoLabs RIA API
setwd('/Users/quatsch/Documents/RIA_Lectures/shiny_test')

library(shiny)
runApp()

#addAuthorizedUser("tester")
#devtools::install_github('rstudio/shinyapps')
#devtools::install_github('rstudio/rscrypt')

Sys.setlocale(category = "LC_ALL", locale = "C")

Sys.setlocale(category = "LC_ALL", locale = "UTF-8")

library(shinyapps)
shinyapps::setAccountInfo(name="tolmach", token="5513C3D68CFF512E99F8AAAD8F35F7E7", secret="VxH/rA4poXz8jRPnUiauYU+OgIkz1v6pEvGWIWUt")
deployApp()