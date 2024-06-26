# ENV
rm(list = ls())
gc()

# wk <- "D:\\JobManagement\\2024 年工作\\浙一单细胞数据分析\\SeuratApp\\heatmap"
wk <- "/Users/xiaofei/Desktop/SingleCell/scellana/"
setwd(wk)

library(shiny)
library(Seurat)
library(tidyverse)
library(presto) # devtools::install_github("immunogenomics/presto")
library(ComplexHeatmap)
library(circlize)

# Step 1. Loading dataset
pbmc.data <- Read10X(data.dir = "filtered_gene_bc_matrices/hg19/")
pbmc <- CreateSeuratObject(counts = pbmc.data, project = "pbmc3k", min.cells = 3, min.features = 200)

# Step 2. Standard analysis
pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")

## ScaleData uses top variable genes only
pbmc<- pbmc %>% 
  NormalizeData(normalization.method = "LogNormalize", scale.factor = 10000) %>%
  FindVariableFeatures(selection.method = "vst", nfeatures = 2000) %>%
  ScaleData() %>%
  RunPCA() %>%
  FindNeighbors(dims = 1:10) %>%
  FindClusters(resolution = 0.5) %>%
  RunUMAP(dims = 1:10)

## Visualization
DimPlot(pbmc, reduction = "umap")

## Annotation
new.cluster.ids <- c("Naive CD4 T", "CD14+ Mono", "Memory CD4 T", "B", "CD8 T", "FCGR3A+ Mono", 
                     "NK", "DC", "Platelet")
names(new.cluster.ids) <- levels(pbmc)
pbmc <- RenameIdents(pbmc, new.cluster.ids)
DimPlot(pbmc, reduction = "umap", label = TRUE, pt.size = 0.5) + NoLegend()

saveRDS(pbmc, file = "pbmc_anno.rds")

## Find markers
markers<- presto::wilcoxauc(pbmc, 'seurat_clusters', assay = 'data')
markers<- top_markers(markers, n = 10, auc_min = 0.5, pct_in_min = 20, pct_out_max = 20)

markers

all_markers<- markers %>%
  select(-rank) %>% 
  unclass() %>% 
  stack() %>%
  pull(values) %>%
  unique() %>%
  .[!is.na(.)]

## Seurat’s dot plot
dot <- DotPlot(object = pbmc, features = all_markers)

# Step 3. ComplexHeatmap
df <- dot$data

## the matrix for the scaled expression 
exp_mat<-df %>% 
  select(-pct.exp, -avg.exp) %>%  
  pivot_wider(names_from = id, values_from = avg.exp.scaled) %>% 
  as.data.frame() 

row.names(exp_mat) <- exp_mat$features.plot  
exp_mat <- exp_mat[,-1] %>% as.matrix()

## the matrix for the percentage of cells express a gene
percent_mat<-df %>% 
  select(-avg.exp, -avg.exp.scaled) %>%  
  pivot_wider(names_from = id, values_from = pct.exp) %>% 
  as.data.frame() 

row.names(percent_mat) <- percent_mat$features.plot  
percent_mat <- percent_mat[,-1] %>% as.matrix()

## any value that is greater than 2 will be mapped to yellow
library(viridis)
library(Polychrome)
col_fun = circlize::colorRamp2(c(-2, 0, 2), viridis(20)[c(1, 10, 20)])

cell_fun = function(j, i, x, y, w, h, fill){
  grid.rect(x = x, y = y, width = w, height = h,
            gp = gpar(col = NA, fill = NA))
  grid.circle(x=x,y=y,r= percent_mat[i, j]/100 * min(unit.c(w, h)),
              gp = gpar(fill = col_fun(exp_mat[i, j]), col = NA))
}

## also do a kmeans clustering for the genes with k = 4
Heatmap(exp_mat,
        heatmap_legend_param=list(title="expression"),
        column_title = "clustered dotplot", 
        col=col_fun,
        rect_gp = gpar(type = "none"),
        cell_fun = cell_fun,
        row_names_gp = gpar(fontsize = 5),
        row_km = 4,
        row_title = NULL,
        border = "black")

## also do heatmap using ggplot
library(aplot)
exp_longer <- as.data.frame(exp_mat) %>%
  mutate(
    Gene = rownames(exp_mat),
    .before = "Naive CD4 T"
  ) %>%
  pivot_longer(
    !Gene,
    names_to = "CellType",
    values_to = "ScaleExpr"
  )

pht <- ggplot(data = exp_longer, aes(x = CellType, y = Gene, fill = ScaleExpr)) +
  geom_tile(aes(width = 1, height = 1), color = "grey") +
  scale_fill_gradient2(
    limits = c(-3,3),
    low = "blue",
    mid = "white",
    high = "red",
    guide = guide_colorbar(
      barwidth = unit(0.3, "cm"),
      barheight = unit(5, "cm")
    )
  ) +
  theme(
    panel.background = element_blank(),
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.ticks = element_blank()
  )

library(magrittr)
library(ggtree)
rowTree <- hclust(dist(exp_mat)) %>%
  ggtree(branch.length = 'none') + 
  layout_rectangular()

rowTree$data %<>%
  mutate(
    x = case_when(
      isTip == TRUE ~ max(x),
      .default = x
    )
  )
## Add lebels
# rowTree + geom_tiplab()


colTree <- hclust(dist(t(exp_mat))) %>%
  ggtree() +
  layout_dendrogram()
colTree$data %<>%
  mutate(
    x = case_when(
      isTip == TRUE ~ max(x),
      .default = x
    )
  )

colTree

library(aplot)

pht %>% insert_left(rowTree, width = 0.1) %>%
  insert_top(colTree, height = 0.05)


# ------------ Ridges ---------------- #
library(ggridges)
gmat <- as.data.frame(exp_mat) %>%
  mutate(
    Gene = rownames(exp_mat),
    .before = "Naive CD4 T"
  ) %>%
  pivot_longer(
    !Gene,
    names_to = "CellType",
    values_to = "ScaleExpr"
  )

ggplot(gmat, aes(y = CellType, x = ScaleExpr, fill=..x..))+
  geom_density_ridges_gradient(scale=3, rel_min_height=0.01, gradient_lwd = 1.)





tmp <- as.data.frame(exp_mat)[1:2,]

htmp <- hclust(dist(tmp)) %>%
  ggtree(branch.length = 'none') + 
  layout_rectangular()





ui<-fluidPage(
  actionButton(inputId ="unif", label ="Uniform"),
  
  #Normal
  plotOutput("hist")
)

server <- function(input, output) {

  dunif <- eventReactive(input$unif, {
    message("tt")
    runif(100)
  })

  
  output$hist <- renderPlot({
    hist(dunif())
  })
}

shinyApp(ui, server)








