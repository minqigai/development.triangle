library(shiny)
library(DT)
library(tidyverse)
library(ChainLadder)
library(shinyjs)
library(gridExtra)

################################################## UI #################################################


# Set UI to show results in different tabs
ui <- fluidPage(
  tabsetPanel(
    # Panel 1
    tabPanel("Upload data",
             fileInput("upload", buttonLabel = "Browse...", multiple = TRUE,
                       accept = c("text/csv",
                                  "text/comma-separated-values,text/plain",
                                  ".csv"),
                       placeholder = "Choose files",
                       tableOutput("files")),
             textOutput("text0"),
             DT::dataTableOutput("contents")
    ),
    # Panel 2
    tabPanel("Result",
             numericInput("tail", label = "Input Tail Factor", value = 1, min = -10, max = 10),
             textOutput("tail"),
             textOutput("n"),
             textOutput("ldf"),
             verbatimTextOutput("f"),
             textOutput("text1"),
             verbatimTextOutput("table1"),
             textOutput("text2"),
             verbatimTextOutput("table")
    ),
    # Panel 3
    tabPanel("Graph",
             plotOutput("plot", width = "400px")
    )
  )
)


################################################## Server #################################################


server <- function(input, output, session) {
  
  
  # Upload claims data file
  myData <- reactive({
    req(input$upload)
    
    ext <- tools::file_ext(input$upload$name)
    switch(ext,
           csv = vroom::vroom(input$upload$datapath, delim = ","),
           validate("Please upload the claims data in .csv")
    )
  })
  
  
  # Print file preview
  output$text0 <- renderText("Uploaded File Preview")
  output$contents <- renderDT({
    print("Data Loaded:")
    print(myData())
    myData()
  })
  

  ###################################################################################################
  
  # Rename columns
  claims_data <- reactive({
    myData() %>%
      rename("loss_year" = "Loss Year", "dev_year" = "Development Year", "claims_paid" = "Amount of Claims Paid ($)") %>% 
      mutate(claims_paid = as.numeric(claims_paid)) 
  })
  
  # Create incremental development triangle from the claim data
  incr_triangle <- reactive({
    as.triangle(claims_data(), 
                dev = "dev_year", 
                origin = "loss_year", 
                value = "claims_paid")
  })
  
  
  # Create cumulative development triangle
  cumu_triangle <- reactive({
    incr2cum(incr_triangle())
  })
  
  
  cumu_triangle_1 <- reactive({
    as.triangle(cumu_triangle(),
                dev = "Development Year",
                origin = "Loss Year",
                value = "claims_paid")
  })
  
  
  # Print
  output$text1 <- renderText("Cumulative Loss Development Triangle")
  output$table1 <- renderPrint(cumu_triangle_1()) 
  
  
  ###################################################################################################  
  
  
  # Tail factor
  LDF_tail <- reactive({input$tail})
  
  
  # Print
  output$tail <- renderText({
    paste0("Tail Factor: ", LDF_tail())
  })
  
  
  # Largest Development Year
  n <- reactive(max(isolate(claims_data()$dev_year), na.rm = TRUE)) 
  
  
  # Print
  output$n <- renderText({
    paste0("Total Development Years: ", n())
  })
  
  
  # Compute LDF
  LDF <- reactive({
    sapply(1:(n() - 1), function(i){
      sum(cumu_triangle()[c(1:(n() - i)), i + 1])/sum(cumu_triangle()[c(1:(n() - i)), i])
    })
  })
  
  
  # Merge LDF and tail factor
  f <- reactive({
    c(LDF(), LDF_tail())
  })
  
  
  # Print
  output$ldf <- renderText("Loss Development Factors ")
  output$f <- renderPrint(f()) # f showed as ldf combined with tail
  
  
  ###################################################################################################  
  
  
  # Projection to Ultimate
  dt <- reactive({cbind(cumu_triangle_1(), Ultimate = rep(0, nrow(cumu_triangle_1())))
  }) 
  
  projection <- reactive({
    n1 <- n()
    value <- dt()
    
    for (k in 1:n()){
      value[(n() - k + 1):n(), k + 1] <- value[(n1 - k + 1):n1, k] * f()[k]
    }
    value
  })    
  
  
  # Tidy up triangle header  
  full <- reactive({
    as.triangle(round((projection())),
                dev = "Development Year",
                origin = "Loss Year",
                value = "claims_paid")
  })
  
  
  # Print
  output$text2 <- renderText("Cumulative Loss Development Triangle Projection to Ultimate")
  output$table <- renderPrint({full()}) 
  
  
  ###################################################################################################
  
  
  # Plot line graph
  plot <- reactive({
    df <- data.frame(full()) 
    claims_data_1 <- claims_data()
    
    ggplot(df, 
           aes(x = `Development.Year`, y = `value`, group = `Loss.Year`, 
               label = scales::comma(`value`, accuracy = 1))) +
      geom_line(aes(color = `Loss.Year`)) +
      geom_point(aes(color = `Loss.Year`)) +
      scale_color_manual(values=c('#69D2E6','#F58732','#A5DCD7','#FA6900','#64C864','#E1E6CD')) +
      ggtitle("Cumulative Paid Claims Projection to Ultimate \n by Loss Year") + 
      theme(plot.title = element_text(hjust = 0.5)) +
      xlab("Development Year") + ylab("Cumulative Paid Claims ($)") +
      geom_text(nudge_y = subset(claims_data_1, dev_year == "1" & 
                                   loss_year == min(claims_data_1$loss_year))$claims_paid / 30, size = 2.5) + 
      labs(col = "Loss Year") +
      theme(legend.position = "bottom")
  })
  
  
  # Print
  output$plot <- renderPlot({
    par(mar = c(5,4,3,2))
    plot()
  })
  
  
}
###################################################################################################

# Run the app
shinyApp(ui, server)
