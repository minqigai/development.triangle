# This file is to store codes which could be used for downloading the results 
# from the R shiny app
# Previously tested but failed to download as pdf
# It downloaded the whole website as html




# ui <- fluidPage(
# tabsetPanel(
# # Panel 4
# tabPanel("Download result",
#          # Download file
#          downloadButton("download","Download Result")
# )


# server <- function(input, output, session) {
# # Download
# tail_text <- reactive({
#   paste0("Tail factor is ", LDF_tail())
#   })

# Print

# # Method 1
# output$download <- downloadHandler(
#   filename = function() { "Report.pdf" },
#   content = function(file) {
#     pdf(file, onefile = TRUE)
#     
#     # Create table and plot objects from the rendered outputs
#     tail_obj <- renderText(output$tail)
#     table_obj <- renderTable(output$table)
#     plot_obj <- renderPlot(output$plot, res = 96)
#     
#     grid.arrange(tail_obj, table_obj, plot_obj)
#     dev.off()
#   }
# )
# 
# 

# # Method 2
# output$download <- downloadHandler(
#   filename = function() { "Report.pdf" },
#   content = function(file) {
#     pdf(file, width = 8, height = 6)
#     
#     # Create table and plot objects from the rendered outputs
#     tail_text <- renderText(output$tail)()
#     table_obj <- renderTable(output$table)()
#     plot_obj <- renderPlot(output$plot, res = 96)()
#     
#     # Arrange elements on a single PDF page
#     grid.arrange(
#       textGrob(tail_text, gp = gpar(fontsize = 12)),
#       table_obj,
#       plot_obj,
#       ncol = 1
#     )
#     
#     dev.off()
#   }
# )

# 
# # Method 3 - not working, downloaded html
# ## vals will contain all plot and table grobs
# vals <- reactiveValues(t1=NULL,t2=NULL,p1=NULL)
# 
# ## Note that we store the plot before returning it 
# output$t1 <- renderText({
#   vals$t1 <- paste0("Tail Factor: ", LDF_tail())
#   vals$t1
# })
# 
# output$t2 <- renderPrint({
#   dx <- full()
#   vals$t2 <- tableGrob(dx)
#   dx
# })
# 
# output$p1 <- renderPlot({
#   dp <- plot()
#   vals$p1 <- dp
#   vals$p1
# })
# 
# 
# ## clicking on the export button will generate a pdf file 
# ## containing all grobs
# output$export = downloadHandler(
#   filename = function() {"Result.pdf"},
#   content = function(file) {
#     pdf(file, onefile = TRUE)
#     grid.arrange(vals$t1,vals$t2,vals$p1) 
#     dev.off()
#   }
# )

# output$download <- downloadHandler(
#   filename = function() { "Report.pdf" },
#   content = function(file) {
#     # Use webshot to capture the Shiny app's current state and save as a PDF
#     webshot::webshot(session$token, file, vwidth = 800, vheight = 600)
#   }
# )
#}
