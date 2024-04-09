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
          fileInput("cellranger", label = "Upload files"),
          tableOutput("files")
        ),
        column(
          width = 5,
          sliderInput("slider", label = "Test", min = 1, max = 5, value = 3, step = 1),
          numericInput("cls", label = "Number", value = 5),
          actionButton("loading", label = "Loading... ", class = "btn-block")
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