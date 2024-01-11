
# Load necessary libraries
library(shiny)
library(DT)
library(tidyverse)
library(ChainLadder)
library(shinyjs)
library(gridExtra)

source("server.R")
source("ui.R")

# Run app
shinyApp(ui, server)
