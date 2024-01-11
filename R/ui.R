
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
             DT::DTOutput("contents")
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