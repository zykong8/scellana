library(tools)
library(R.utils)
library(Seurat)

# wk <- "D:\\JobManagement\\2024 年工作\\浙一单细胞数据分析\\SeuratApp\\heatmap\\test"
wk <- "/Users/xiaofei/Desktop/SingleCell/scellana"

server <- function(input, output, session){

  
  minCells <- reactive({
    input$minCells
  })
  minFeatures <- reactive({
    input$minFeatures
  })
  
  rdx <- reactive({
    
    req(input$cellranger)
    file.rename(input$cellranger$datapath, paste0(wk , "/test/", input$cellranger$name))
    unzip(zipfile = paste0(wk , "/test/", input$cellranger$name), exdir = paste0(wk , "/test/"))
    mtx <- file_path_sans_ext(paste0(wk , "/test/", input$cellranger$name))
    rdx <- Read10X(data.dir = mtx)
    rdx
    
  })
  
  # Loading data
  seu <- eventReactive(input$loading, {
    obj <- CreateSeuratObject(counts = rdx(), min.cells = minCells(), min.features = minFeatures())
    updateActionButton(session, "loading", label = "Reruning...")
    obj
  })
  
  output$files <- renderPrint({
    seu()
  })
  
  # QC
  mt <- reactive({
    input$MT
  })
  
  output$filtering <- renderUI({
    if (input$Type == "Customize"){
      list(
        sliderInput("MT", label = "Filtering cells that have > N% mitochondrial counts.", min = 5, max = 50, step = 5, value = 30),
        numericInput("UMI", label = "Filtering cells that have < N UMI counts.", value = 400),
        numericInput("nFeaturesOver", label = "Filtering cells that have unique feature counts over N", value = 20000),
        numericInput("nFeauresLess", label = "Filtering cells that have unique feature counts less than N", value = 200),
        actionButton("qc_btn", label = "Run QC", class = "btn-success")
      )
      
    }else if (input$Type == "SelfAdaption"){
      list(
        sliderInput("MT", label = "Filtering cells that have > N% mitochondrial counts.", min = 5, max = 50, step = 5, value = 30),
        numericInput("nFeauresLess", label = "Filtering cells that have unique feature counts less than N", value = 200),
        actionButton("qc_btn", label = "Run QC", class = "btn-success")
      )

    }
  })
  
  cln <- eventReactive(input$qc_btn, {
    if(input$Type == "Customize"){
      obj <- filterCell(seu(), minFeatures(), mt(), minUMI = input$UMI, maxFeatures=input$nFeaturesOver)
    }else{
      obj <- filterCell(seu(), minFeatures(), mt())
    }
    updateActionButton(session, "qc_btn", label = "Reruning...")
    obj
  })
  output$vln <- renderPlot({
    # Visualize QC metrics as a violin plot
    VlnPlot(cln(), features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
  })
  
}

shinyServer(server)