#' @export
modifyFilesUsingSysCommand <- function(SOURCE_DIR,
                                       FILE_KEYWORD,
                                       DATA_DIR,
                                       DO_FUNCTION) {

  ### Please see this system command if you need to modify the contents in a file
  # sed -i.bak "1s/applianceTypeId/typeid/" F30200F5_NILM_1s_12_tv_1480518001-1483541976.csv
  ### meaning: original file is changed to "~.bak", and a new file is created with the name "~.csv"

  if(!dir.exists(DATA_DIR)) {
    dir.create(DATA_DIR)
  }

  wholeFile <- list.files(path = SOURCE_DIR, full.names = FALSE, include.dirs = FALSE)
  chosenFileNames <- wholeFile[grep(FILE_KEYWORD, wholeFile)]
  for (Idx in 1:length(chosenFileNames)){
    print(Idx)
    splittedName <- str_split(chosenFileNames[Idx], "_", n = Inf)[[1]]
    timeRemovedName <- splittedName[-length(splittedName)]
    newProperName <- paste(paste(timeRemovedName, collapse = "_"), "2016-12.csv", sep = "_")


    system(paste0("cp ",SOURCE_DIR,chosenFileNames[Idx]," ", DATA_DIR, newProperName))
  }
}

