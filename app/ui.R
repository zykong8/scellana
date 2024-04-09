library(shiny)

ui <- fluidPage(
  titlePanel("Single Cell Analysis"),
  
  navlistPanel(
    widths = c(4, 8),
    "Setup the Seurat Object",
    tabPanel(
      "Step 1. Loading data",
      column(
        width = 4,
        fileInput(),
        sliderInput("slider", label = "Test", min = 1, max = 5, value = 3, step = 1),
        numericInput("cls", label = "Number", value = 5)
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