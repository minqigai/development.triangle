
# Load necessary libraries
library(shiny)
library(DT)
library(tidyverse)
library(ChainLadder)
library(shinyjs)
library(gridExtra)

# Source the functions from the code file
source("server.R")
source("ui.R")

# Run app
shinyApp(ui, server)
