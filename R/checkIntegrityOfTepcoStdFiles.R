#' @export
checkIntegrityOfTepcoStdFiles <- function(DATA_DIR,
                                          WRITE_OUTPUT_FILE,
                                          SAVED_OUTPUT_FILE_WITH_PATH) {

  wholeFileList <- list.files(path = DATA_DIR, full.names = FALSE, include.dirs = FALSE)
  wholeFileList <- wholeFileList[grep("NILM", wholeFileList)]

  if(WRITE_OUTPUT_FILE)
    sink(SAVED_OUTPUT_FILE_WITH_PATH)

  for(Idx in 1:length(wholeFileList)) {

    if(Idx %/% round(length(wholeFileList)/100) == 0)
      cat("current progress:", round(Idx * 100 / length(wholeFileList), digits = 2)  ,"% \n\n")

    fileNameWithPath <- paste0(DATA_DIR, wholeFileList[Idx])
    NILMRefinedUsage <- read.csv(fileNameWithPath, colClasses = 'character', header = TRUE)

    if( ncol(NILMRefinedUsage) != 4 ){
      print( wholeFileList[Idx] )
      print("not proper column number \n\n")
    }

    if(length(grep("NA",NILMRefinedUsage)) + length(grep("na",NILMRefinedUsage)) != 0 ){
      print( wholeFileList[Idx] )
      print("NA exists \n\n")
    }

    if(length(grep(NILMRefinedUsage$serialNumber[1], fileNameWithPath)) == 0){
      print( wholeFileList[Idx] )
      print("incorrect serial number \n\n")
    }

    if(min(NILMRefinedUsage$timestamp) != NILMRefinedUsage$timestamp[1]){
      print( wholeFileList[Idx] )
      print("not arranged file: min \n\n")
    }

    if(max(NILMRefinedUsage$timestamp) != NILMRefinedUsage$timestamp[nrow(NILMRefinedUsage)]){
      print( wholeFileList[Idx] )
      print("not arranged file: max \n\n")
    }

    if(length(grep("e", NILMRefinedUsage$timestamp)) + length(grep("E", as.character(NILMRefinedUsage$timestamp))) != 0 ){
      print( wholeFileList[Idx] )
      print("scientific notation exists \n\n")
    }

    if(any(is.na(NILMRefinedUsage$unitPeriodUsage))) {
      print( wholeFileList[Idx] )
      print("NA exists: unitPeriodUsage \n\n")
    }

    if(!identical(as.character(round(as.numeric(NILMRefinedUsage$unitPeriodUsage),digits = 2)), NILMRefinedUsage$unitPeriodUsage) ){
      print( wholeFileList[Idx] )
      print("not proper digits for unitPeriodUsage \n\n")
    }

    if(length(grep(NILMRefinedUsage$typeid[1], fileNameWithPath)) == 0){
      print( wholeFileList[Idx] )
      print("incorrect type id \n\n")
    }

    rm(NILMRefinedUsage)
  }

  if(WRITE_OUTPUT_FILE)
    sink()
}




