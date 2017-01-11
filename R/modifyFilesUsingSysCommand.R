#' @export
modifyFilesUsingSysCommand <- function(SOURCE_DIR,
                                       FILE_KEYWORD,
                                       DATA_DIR,
                                       DO_FUNCTION) {

  ### Please take a look at this system command if you need to modify the contents in a file
  # sed -i.bak "1s/applianceTypeId/typeid/" F30200F5_NILM_1s_12_tv_1480518001-1483541976.csv
  ### meaning: original file is changed to "~.bak", and a new file is created with the name "~.csv"

  wholeFile <- list.files(path = SOURCE_DIR, full.names = FALSE, include.dirs = FALSE)
  chosenFileNames <- wholeFile[grep(FILE_KEYWORD, wholeFile)]

  if(DO_FUNCTION == "MODIFY_FILE_NAME_FOR_TEPCO" || DO_FUNCTION == "MODIFY_COLUMN_FOR_TEPCO") {

    if(!dir.exists(DATA_DIR)) {
      dir.create(DATA_DIR)
    }

  } else if(DO_FUNCTION == "DISTRIBUTE_FILES_TO_EACH_FOLDER_FOR_TEPCO") {

    wholeFolder <- list.files(path = DATA_DIR, full.names = FALSE, include.dirs = FALSE)

    folder_ID <- sapply(wholeFolder, function(x) return(str_split(x, "_", n = Inf)[[1]][2]))
    matchFolderWithID <- data.frame(folder = wholeFolder, id = folder_ID)

    file_ID <- sapply(wholeFile, function(x) return(str_split(x, "_", n = Inf)[[1]][1]))
    matchFileWithID <- data.frame(file = wholeFile, id = file_ID)

  }

  if(DO_FUNCTION == "MODIFY_FILE_NAME_FOR_TEPCO") {

    for (Idx in 1:length(chosenFileNames)){
      print(Idx)

      splittedName <- str_split(chosenFileNames[Idx], "_", n = Inf)[[1]]
      timeRemovedName <- splittedName[-length(splittedName)]
      newProperName <- paste(paste(timeRemovedName, collapse = "_"), "2016-12.csv", sep = "_")
      system(paste0("cp ",SOURCE_DIR,chosenFileNames[Idx]," ", DATA_DIR, newProperName))

    }

  } else if(DO_FUNCTION == "DISTRIBUTE_FILES_TO_EACH_FOLDER_FOR_TEPCO") {

    for (folderIdx in 1:nrow(matchFolderWithID)){

      print(matchFolderWithID$id[folderIdx])

      chosenOneFolder <- matchFolderWithID$folder[folderIdx]
      chosenFilesWithID <- matchFileWithID %>% filter(id == as.character(matchFolderWithID$id[folderIdx]))

      if(nrow(chosenFilesWithID) == 0){
        print("no file exists")
        next
      }

      for (chosenFileIdx in 1:nrow(chosenFilesWithID)) {

        chosenOneFile <- chosenFilesWithID$file[chosenFileIdx]

        if( length(grep("_1s_", chosenOneFile)) == 1) { # 1 sec

          system(paste0("cp ",SOURCE_DIR,chosenOneFile," ", DATA_DIR, chosenOneFolder, "/3_NILM_1s/"))

        } else if( length(grep("_15m_", chosenOneFile)) == 1) { # 15 min

          system(paste0("cp ",SOURCE_DIR,chosenOneFile," ", DATA_DIR, chosenOneFolder, "/4_NILM_15m/"))

        } else {
          print("redundant file exists")
          print(chosenOneFile)
        }

      }
    }
  }
}


