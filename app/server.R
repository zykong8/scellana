
server <- function(input, output, session){
  output$files <- renderTable({
    req(input$cellranger)
    input$cellranger
  })
}

shinyServer(server)