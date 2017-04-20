#' @export
plotHousehold <- function(FILE_SEP, FILE_FIRST_WORD, FILE_TYPE, HOUSEHOLD_DIR, TIME_PERIOD, FLAG_ONLY_HOME = FALSE, COUNTRY, HOME_CHANNEL) {

  wholeFileList <- list.files(path = HOUSEHOLD_DIR, full.names = FALSE, include.dirs = FALSE)

  if (FILE_TYPE == ".feather") {
    chkWord <- sapply(wholeFileList, function(x) getOneWordFromString(string = x,
                                                                      position = 1,
                                                                      sep = FILE_SEP) == FILE_FIRST_WORD, USE.NAMES = FALSE)

  } else if (FILE_TYPE == ".csv") {
    chkWord <- sapply(wholeFileList, function(x) getMoreThanOneWordFromString(string = x,
                                                                              position_start = 1,
                                                                              position_end = 3,
                                                                              sep = FILE_SEP) == FILE_FIRST_WORD, USE.NAMES = FALSE)
  }

  chkType <- grepl(pattern = FILE_TYPE, x = wholeFileList)

  chosenFiles <- wholeFileList[chkWord & chkType]
  num_files <- length(chosenFiles)

  if(num_files == 0)
    stop("not a valid household")

  if(FLAG_ONLY_HOME) {

    if (FILE_TYPE == ".feather") {
      homeIdx <- grep(pattern = "home", x = chosenFiles)
    } else if (FILE_TYPE == ".csv") {
      homeIdx <- grep(pattern = "_00_", x = chosenFiles)
    }

    if(length(homeIdx) != 1)
      stop("not a valid home")

    print(chosenFiles[homeIdx])

    if (COUNTRY == "KR"){

      if (FILE_TYPE == ".feather") {
        meterReadings <-
          read_feather(paste0(HOUSEHOLD_DIR, chosenFiles[homeIdx]))

      } else if (FILE_TYPE == ".csv") {
        meterReadings <-
          MillenniumFalcon::loadCompactPowerData(path = paste0(HOUSEHOLD_DIR, chosenFiles[homeIdx]),
                                                 sampling_rate = 15,
                                                 human_date = TRUE,
                                                 tz = "Asia/Seoul",
                                                 cleanse = TRUE)
      }

      meterReadings %<>% filter(timestamp %within% TIME_PERIOD)

    } else if (COUNTRY == "JP") {

      if (FILE_TYPE == ".feather") {
        meterReadings <-
          read_feather(paste0(HOUSEHOLD_DIR, chosenFiles[homeIdx]))
      } else if (FILE_TYPE == ".csv") {
        meterReadings <-
          MillenniumFalcon::loadCompactPowerData(path = paste0(HOUSEHOLD_DIR, chosenFiles[homeIdx]),
                                                 sampling_rate = 10,
                                                 human_date = TRUE,
                                                 tz = "Asia/Seoul",
                                                 cleanse = TRUE)
      }

      meterReadings %<>% filter(timestamp %within% TIME_PERIOD, channel == HOME_CHANNEL)

    }

    melt.active <- data.frame(timestamp = meterReadings$timestamp, value = meterReadings$active_power, sig_type = 'active')
    melt.reactive <- data.frame(timestamp = meterReadings$timestamp, value = meterReadings$reactive_power, sig_type = 'reactive')
    melt.plot <- rbind(melt.active, melt.reactive)
    ggplot(melt.plot, aes(x = timestamp, y = value, col = sig_type)) + geom_line() + geom_point() + facet_grid(sig_type ~ ., scales='free_y')

  } else {
    # plot each file for a household
    picture_rows <- num_files + 1 # consider 2 channels at home
    par(mfrow=c(picture_rows,2), oma=c(4, 4, 4, 4), mar=rep(.1, 4), cex=1, las=1)

    for(idx in seq(num_files)){

      aFile <- chosenFiles[idx]
      print(aFile)

      if (FILE_TYPE == ".feather") {

        meterReadings <- read_feather(paste0(HOUSEHOLD_DIR, aFile))
      } else if (FILE_TYPE == ".csv") {

        if (COUNTRY == "KR") {
          meterReadings <-
            MillenniumFalcon::loadCompactPowerData(
              path = paste0(HOUSEHOLD_DIR, aFile),
              sampling_rate = 15,
              human_date = TRUE,
              tz = "Asia/Seoul",
              cleanse = TRUE
            )
        } else if (COUNTRY == "JP") {
          meterReadings <-
            MillenniumFalcon::loadCompactPowerData(
              path = paste0(HOUSEHOLD_DIR, aFile),
              sampling_rate = 10,
              human_date = TRUE,
              tz = "Asia/Seoul",
              cleanse = TRUE
            )
        }
      }

      meterReadings %<>% filter(timestamp %within% TIME_PERIOD)

      if(nrow(meterReadings) == 0){
        print("no data")
        next
      }

      if (FILE_TYPE == ".feather") {
        isHome <- grepl(pattern = "home", x = aFile)
      } else if (FILE_TYPE == ".csv") {
        isHome <- grepl(pattern = "_00_", x = aFile)
      }

      if( isHome ){

        if (COUNTRY == "JP") {
          for(idx_ch in seq(1,2)){
            tmpReadings <- meterReadings %>% filter(channel == idx_ch)
            plot(x=tmpReadings$timestamp, y=tmpReadings$active_power, type='l') # ann=FALSE, xaxt="n",
            plot(x=tmpReadings$timestamp, y=tmpReadings$reactive_power, ann=FALSE, xaxt="n", type='l', yaxt='n'); axis(side=4)
          }
        } else if (COUNTRY == "KR") {
          tmpReadings <- meterReadings
          plot(x=tmpReadings$timestamp, y=tmpReadings$active_power, type='l') # ann=FALSE, xaxt="n",
          plot(x=tmpReadings$timestamp, y=tmpReadings$reactive_power, ann=FALSE, xaxt="n", type='l', yaxt='n'); axis(side=4)
        }


      } else {
        plot(x=meterReadings$timestamp, y=meterReadings$active_power, type='l') # ann=FALSE, xaxt="n",
        plot(x=meterReadings$timestamp, y=meterReadings$reactive_power, ann=FALSE, xaxt="n", type='l', yaxt='n'); axis(side=4)
      }

    }
  }
}
