append_file <- function(directory = NA, pattern = NA, sep = "auto", encoding = "UTF-8", label = T, colClasses = "character", select = NULL, ...){
  tables <- list.files(directory, pattern = pattern, full.names = T)
  result <- data.table()
  for (i in tables) {
    t <- fread(file = i, sep = sep, encoding = encoding, colClasses = colClasses, select = select)
    
    if(!is.null(label)){
      if(label == T){t[, label_file := gsub("^.*_|\\.csv$","", i)]}
      else{
        t[, label_file := label]
      }
      
    }
    

    result <- rbindlist(list(result, t), fill = T)
  }
  return(result)
}