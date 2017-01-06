#' @export
loadReportFiles <- function(USER_LIST,
                           SOURCE_DIR,
                           DATA_DIR,
                           OBJ,
                           CHOSEN_SITE_DEC,
                           CHOSEN_SITE_HEX,
                           CHOSEN_APP,
                           ID_START,
                           ID_END,
                           IGNORE_EXIST_DATA = TRUE){

  if(!dir.exists(DATA_DIR)) {
    dir.create(DATA_DIR)
  }

  if(OBJ == "home"){
    # DATA_1HZ_DIR <- paste0(DATA_DIR, "1hz/")
    # if(!dir.exists(DATA_1HZ_DIR)) {
    #   dir.create(DATA_1HZ_DIR)
    # }
  }

  if(length(CHOSEN_SITE_DEC) != 0)
    CHOSEN_SITE <- c(convertDec2Hex(CHOSEN_SITE_DEC), CHOSEN_SITE_HEX)
  else
    CHOSEN_SITE <- CHOSEN_SITE_HEX

  CHOSEN_SITE <- CHOSEN_SITE %>% unique(.)

  enertalkDevice <- USER_LIST %>% filter(division == "총량") %>%
    select(user, skey = sn.dev, pid = sn.parent, code) %>% unique(.) %>%
    mutate(class = "home") %>% mutate(division = class) %>%
    mutate(division = paste(convertHex2Dec(skey), division, sep='_'))


  if(length(CHOSEN_APP) != 0)
    plugDevice <- USER_LIST %>% filter(division %in% CHOSEN_APP)
  else
    plugDevice <- USER_LIST %>% filter(division != "총량")

  plugDevice <- plugDevice %>%
                select(user,
                       skey = sn.dev,
                       pid = sn.parent,
                       code,
                       division) %>%
                unique(.) %>%
                mutate(class = "plug",
                       division = paste(
                                  convertHex2Dec(pid),
                                  division, sep='_'))

  if(length(CHOSEN_SITE) != 0) {
    plugDevice <- plugDevice %>% filter(pid %in% CHOSEN_SITE)
    enertalkDevice <- enertalkDevice %>% filter(skey %in% CHOSEN_SITE)
  }

  if(length(CHOSEN_APP) != 0)
    enertalkDevice <- enertalkDevice %>% filter(skey %in% unique(plugDevice$pid))

  deviceLists <- bind_rows(enertalkDevice, plugDevice) %>%
                 mutate(fname = paste0(DATA_DIR, paste(division,
                                                       skey,
                                                       pid,
                                                       sep = '_',
                                                       ID_START,
                                                       ID_END),
                                                       '.feather')) %>%
                 mutate(fname = gsub(" ","", fname))

  # check duplication
  # deviceLists <- deviceLists[!duplicated(deviceLists$skey), ]

  # for loop to obtain raw data
  validOBJInfo <- deviceLists %>% filter(class == OBJ)

  sourceFiles <- list.files(path = SOURCE_DIR, full.names = FALSE, include.dirs = FALSE)
  sourceFiles <- sourceFiles[grep(".csv", sourceFiles)]
  skeyInSourceFileName <- sapply(sourceFiles, function(x){ vec <- str_split(x, "_", n = Inf)
  return(substr(vec[[1]][5],1, 8))}, USE.NAMES = FALSE)
  subGroupsOfFiles <- data.frame(file = sourceFiles, skey = skeyInSourceFileName)

  if(IGNORE_EXIST_DATA) {
    existDataFiles <- list.files(path = DATA_DIR, full.names = FALSE, include.dirs = FALSE)
    existDataFiles <- paste0(DATA_DIR, existDataFiles[grep(".feather", existDataFiles)])
  }

  for(Idx in 1:nrow(validOBJInfo)) {

    # accumulate csv files
    serialKey <- validOBJInfo$skey[Idx]
    print(serialKey)
    cat("progress :", round(Idx/nrow(validOBJInfo)*100, digits = 1), "%;", nrow(validOBJInfo) - Idx +1, OBJ, "left \n")
    chosenFiles <- subGroupsOfFiles %>% filter(skey == serialKey)
    fileName <- validOBJInfo$fname[Idx]

    if(!IGNORE_EXIST_DATA)
      EXECUTE_DATA_READ <- (nrow(chosenFiles) != 0)
    else
      EXECUTE_DATA_READ <- (nrow(chosenFiles) != 0) &
                          !(fileName %in% existDataFiles)

    if(EXECUTE_DATA_READ){

      csvFile <- fileName %>% gsub(".feather",".csv", .)
      system(command = paste("cat", paste( paste0(SOURCE_DIR,chosenFiles$file), collapse = " "), ">", csvFile, sep = " "))
      wholeData <- loadCompactPowerData(path = csvFile, sampling_rate = 10, human_date = TRUE, tz = "Asia/Tokyo", cleanse = TRUE)

      if(!is.null(wholeData)) {

        if(OBJ == "home") {
          # wholeData1Hz <- wholeData %>%
          #   group_by(channel, timestamp = lubridate::floor_date(timestamp, 'second')) %>%
          #   summarize( active_power = median(active_power), reactive_power = median(reactive_power))
          # fileName1Hz <- fileName %>% gsub(DATA_DIR, paste0(DATA_DIR,"1hz/"), .) %>% gsub(".feather", "-1Hz.feather", .)
          # write_feather(wholeData1Hz, path = fileName1Hz)
          # rm(wholeData1Hz)
        }

        # save data frame
        write_feather(wholeData, path = fileName)

      } else {
        print("null file exists")
        saveRDS(serialKey, file = (fileName %>% gsub(".feather", ".rds", .)))
        print(serialKey)
      }

      system(command = paste("rm", csvFile, sep = " "))
      rm(wholeData)
    }

  }











































}

