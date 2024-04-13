library(shiny)

options(shiny.maxRequestSize = 100 * 1024^2)

ui <- fluidPage(
  titlePanel("Single Cell Analysis"),
  
  navlistPanel(
    widths = c(2, 10),
    fluid = TRUE,
    "Setup the Seurat Object",
    tabPanel(
      "Step 1. Loading data",
      includeMarkdown("Welcome.Rmd"),
      fluidRow(
        column(
          width = 5,
          p(""),
          includeMarkdown("upload.Rmd"),
          fileInput("cellranger", label = "Upload files"),
          tableOutput("files")
        ),
        column(
          width = 5,
          includeMarkdown("filterCellsFeatures.Rmd"),
          sliderInput("slider", label = "Gene filtering: How many cells are identified at least.", min = 1, max = 5, value = 3, step = 1),
          numericInput("cls", label = "Cell filtering: How many genes are identified at least.", value = 200),
          actionButton("loading", label = "Loading... ")
        )
      )
    ),
    tabPanel(
      "Heatmap",
      column(
        width = 4,
        textInput("Gene1", label = "Gene", value = NULL),
        textAreaInput("GL", label = "Gene list", value = NULL)
      )
    )
  )
  
)

shinyUI(ui)