library(tools)
library(R.utils)
library(Seurat)

wk <- "D:\\JobManagement\\2024 年工作\\浙一单细胞数据分析\\SeuratApp\\heatmap\\test"

server <- function(input, output, session){
  output$files <- renderTable({
    req(input$cellranger)
    print(input$cellranger)
    df <- data.frame(
      "Filename" = input$cellranger$name,
      "Path" = input$cellranger$datapath
    )
    df
  })
  
  observeEvent(input$loading, {
    print(seu())
  })
  
  seu <- eventReactive(input$loading, {
    message(input$cellranger$datapath)
    message(file.exists(input$cellranger$datapath))
    
    file.rename(input$cellranger$datapath, paste0(wk , "\\", input$cellranger$name))
    message(paste0(wk , "\\", input$cellranger$name))
    message(getwd())
    tryCatch({
      unzip(paste0(wk , "\\", input$cellranger$name))
      message("tryCatch!!!")
    },error = function(e){
      print(e)
    },
    warning = function(w){
      print(w)
    }
    )
    
    return(rnorm(12))
  })
  
  
}

shinyServer(server)