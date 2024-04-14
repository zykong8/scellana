library(shiny)

options(shiny.maxRequestSize = 100 * 1024^2)

ui <- fluidPage(
  titlePanel("Single Cell Analysis"),
  
  navlistPanel(
    widths = c(2, 10),
    fluid = TRUE,
    "Setup the Seurat Object",
    br(),
    tabPanel(
      "Step 1. Loading data",
      includeMarkdown("Welcome.Rmd"),
      fluidRow(
        column(
          width = 5,
          p(""),
          includeMarkdown("upload.Rmd"),
          fileInput("cellranger", label = "Upload files"),
          verbatimTextOutput("files")
        ),
        column(
          width = 5,
          includeMarkdown("filterCellsFeatures.Rmd"),
          sliderInput("minCells", label = "Include features detected in at least this many cells.", min = 1, max = 5, value = 3, step = 1),
          numericInput("minFeatures", label = "Include cells where at least this many features are detected.", value = 200),
          actionButton("loading", label = "Loading... ", class = "btn-success")
        )
      )
    ),
    br(),
    tabPanel(
      "Step 2. Standard pre-processing workflow",
      includeMarkdown("QC.Rmd"),
      column(
        width = 4,
        helpText("Please choose the filtering method!"),
        selectInput("Type", label = "Filtering methods", choices = c("Customize", "SelfAdaption")),
        uiOutput("filtering")
      ),
      column(
        width = 6,
        plotOutput("vln")
      )
    ),
    br(),
    tabPanel(
      "Step 3. Normalizing and scaling the data",
      includeMarkdown("Norm.Rmd"),
      column(
        width = 4,
        numericInput("sf", label = "Sets the scale factor for cell-level normalization", value = 10000),
        numericInput("hvg", label = "Identification of highly variable features", value = 2000),
        selectInput("sg", label = "Sets the genes for Scaling the data", choices = c("Highly variable genes"='sghvg', "All genes"='sgag'))
      )
    )
  )
  
)

shinyUI(ui)