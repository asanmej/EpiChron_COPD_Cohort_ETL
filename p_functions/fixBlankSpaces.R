fixBlankSpaces <- function(dataTable = NULL, cols = NA){
  
  if(!any(is.null(dataTable))){
    
    setDT(dataTable)
    if(is.na(cols)){cols <- colnames(dataTable)}
    dataTable[, (cols) := lapply(.SD, function(x){ifelse(x == "" | x == "NA", NA, x)}), .SDcols = cols]
    
    message("Fixing blank spaces was successful")
    
  }else{ warning("Missing data table to fix.")}
  
}