
# Cell-level filtering
## filtering by nCount and nFeatures per individual
filterCell <- function(obj, minFeatures, mtPct, minUMI=NULL, maxFeatures=NULL){
  ## calculate the mitochondrion
  obj[["percent.mt"]] <- PercentageFeatureSet(obj, pattern = "^MT-")
  
  ## calculate the quantile range
  count.feature.ls <- obj@meta.data[, c("nCount_RNA", "nFeature_RNA")]
  count.feature.ls %<>% map(log10) %>% map(~c(10^(mean(.x) + 3*sd(.x)), 10^(mean(.x) - 3*sd(.x))))
  
  ## filter cells
  if (is.null(minUMI) & is.null(maxFeatures)){
    obj <- subset(
      obj, subset = nFeature_RNA > minFeatures & 
        nFeature_RNA < count.feature.ls[[2]][1] & 
        nCount_RNA < count.feature.ls[[1]][1] &
        percent.mt < mtPct
    )
  }else{
    obj <- subset(
      obj, subset = nFeature_RNA > minFeatures & 
        nFeature_RNA < maxFeatures & 
        nCount_RNA > minUMI &
        percent.mt < mtPct
    )
  }

  return(obj)
}
