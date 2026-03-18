fixFechas <- function(dataTable = NULL, type = "ymd", cols = NULL){
  
  if(is.null(cols)){cols <- grep("^fec", colnames(dataTable), value = T)}
  
  switch (type,
          ymd = {dataTable[, (cols) := lapply(.SD, ymd), .SDcols = cols]},
          ydm = {dataTable[, (cols) := lapply(.SD, ydm), .SDcols = cols]},
          mdy = {dataTable[, (cols) := lapply(.SD, mdy), .SDcols = cols]},
          myd = {dataTable[, (cols) := lapply(.SD, myd), .SDcols = cols]},
          dmy = {dataTable[, (cols) := lapply(.SD, dmy), .SDcols = cols]},
          dym = {dataTable[, (cols) := lapply(.SD, dym), .SDcols = cols]},
          as.Date = {dataTable[, (cols) := lapply(.SD, as.Date), .SDcols = cols]},
          stop("Enter a valid date format!")
  )
  message("Fixing dates was successful")
  
}