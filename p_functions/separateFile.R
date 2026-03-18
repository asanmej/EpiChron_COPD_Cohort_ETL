separateFiles <- function(dataSetLabel = "NA.csv", path = ".", fileSize = 2*1024**3){
  
  if(file.size( paste0(path, dataSetLabel)) > 2*1024**3){
    ind <- as.integer(ceiling(file.size( paste0(path, dataSetLabel))/(2*1024**3)))
    n_row <- nrow(fread(file = paste0(path, dataSetLabel), select = 1L))+1
    t <- as.integer(floor(sum(n_row)/ind))
    
    for (i in 0L:(ind-1)) {
      fwrite(fread( paste0(path, dataSetLabel), nrows = t, skip = (t*i)+1, header = F, col.names = colnames(fread( paste0(path, dataSetLabel), nrow = 0))), 
             paste0(path, gsub("\\.csv$", "", dataSetLabel), "_", (i+1), ".csv"))
      gc()
    }
    
  }
  
}