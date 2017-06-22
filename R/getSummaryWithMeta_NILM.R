#' @export
getSummaryWithMeta_NILM <- function(DATA_DIR,
                                    CHOSEN_APP,
                                    COUNTRY,
                                    startTimestampForMeta,
                                    endTimestampForMeta,
                                    startTimestampForSummary = NULL,
                                    endTimestampForSummary = NULL,
                                    POWER_THRES,
                                    CHOSEN_SITE_DEC,
                                    CHOSEN_SITE_HEX,
                                    EXCLUDE_ID_DEC,
                                    EXCLUDE_ID_HEX
                                    ) {

  splittedDirName <- str_split(DATA_DIR, "/", n = Inf)

  META_DIR <- splittedDirName[[1]]
  NILM_SUMMARY_DIR <- splittedDirName[[1]]
  ORG_FOLDER <- META_DIR[length(META_DIR) -1]

  META_DIR[length(META_DIR) -1] <- paste0("meta_",CHOSEN_APP,"_",ORG_FOLDER)
  NILM_SUMMARY_DIR[length(NILM_SUMMARY_DIR) -1] <- paste0("summary_",CHOSEN_APP,"_",ORG_FOLDER)
  META_DIR <- paste(META_DIR, collapse = "/")
  NILM_SUMMARY_DIR <- paste(NILM_SUMMARY_DIR, collapse = "/")

  if(!dir.exists(META_DIR)) {
    dir.create(META_DIR)
  }

  if(!dir.exists(NILM_SUMMARY_DIR)) {
    dir.create(NILM_SUMMARY_DIR)
  }

  if(length(CHOSEN_SITE_HEX) != 0)
    CHOSEN_SITE <- c(convertHex2Dec(CHOSEN_SITE_HEX), CHOSEN_SITE_DEC)
  else
    CHOSEN_SITE <- CHOSEN_SITE_DEC

  CHOSEN_SITE <- CHOSEN_SITE %>% unique(.)

  ### -------------------------------------------------

  if(length(EXCLUDE_ID_HEX) != 0)
    EXCLUDE_ID <- c(convertHex2Dec(EXCLUDE_ID_HEX), EXCLUDE_ID_DEC)
  else
    EXCLUDE_ID <- EXCLUDE_ID_DEC

  EXCLUDE_ID <- EXCLUDE_ID %>% unique(.)

  # load entire files
  wholeFileList <- list.files(path = DATA_DIR, full.names = FALSE, include.dirs = FALSE)
  wholeFileList <- wholeFileList[grep("feather", wholeFileList)]

  # indicator for each file
  siteIdx <- sapply(wholeFileList, function(x){ vec <- str_split(x, "_", n = Inf)
                    return(vec[[1]][1])}, USE.NAMES = FALSE)

  # build home & plug set
  if(length(CHOSEN_SITE) != 0){
    pairsForHomePlug <-
      data.frame(fileName = wholeFileList, indicator = siteIdx) %>%
      filter(indicator %in% CHOSEN_SITE) %>%
      filter(!(indicator %in% EXCLUDE_ID)) %>%
      group_by(indicator) %>%
      do( matchHomePlugFile(data = ., plug = CHOSEN_APP) )
  } else {
    pairsForHomePlug <-
      data.frame(fileName = wholeFileList, indicator = siteIdx) %>%
      filter(!(indicator %in% EXCLUDE_ID)) %>%
      group_by(indicator) %>%
      do( matchHomePlugFile(data = ., plug = CHOSEN_APP) )
  }

  # split data frame
  groupedPairsForMoreThanOneApplianceCase <- split(pairsForHomePlug, pairsForHomePlug$indicator)
  # remove NAs
  groupedPairsForMoreThanOneApplianceCase <- groupedPairsForMoreThanOneApplianceCase[sapply(groupedPairsForMoreThanOneApplianceCase, function(x) nrow(x) != 0)]

  #generate NILM Summary
  lapply(groupedPairsForMoreThanOneApplianceCase, function(x){

    homeFile <- paste0(DATA_DIR, x$home)
    indicator <- str_split(x$home, "_", n = Inf)
    print(indicator[[1]][1])
    rawPowerData <- read_feather(homeFile[1])

    # get result
    consideredTimePeriod <- as.POSIXct(startTimestampForMeta, tz = 'Asia/Seoul') %--% as.POSIXct(endTimestampForMeta, tz = 'Asia/Seoul')
    householdPower <- rawPowerData %>% filter(timestamp %within% consideredTimePeriod)

    if(nrow(householdPower) != 0){

      indicator <- paste(indicator[[1]][1],indicator[[1]][3], sep = "_")
      if (CHOSEN_APP == "세탁기")
        meta <- forceWasher(X = householdPower, country = toupper(COUNTRY), debug = FALSE)
      else if (CHOSEN_APP == "전기밥솥")
        meta <- forceRiceCooker(data = householdPower, country = toupper(COUNTRY))
      else if (CHOSEN_APP == "에어컨")
        meta <- 0.0
      else
        stop("invalid appliance")

      meta$siteId <- indicator
      saveRDS(meta, paste0(META_DIR,indicator,"_",CHOSEN_APP,".rds"))

      if( (length(startTimestampForSummary) != 0) && (length(endTimestampForSummary) != 0) ){

        consideredTimePeriod <- as.POSIXct(startTimestampForSummary, tz = 'Asia/Seoul') %--% as.POSIXct(endTimestampForSummary, tz = 'Asia/Seoul')
        householdPower <- rawPowerData %>% filter(timestamp %within% consideredTimePeriod)

      }

      if (CHOSEN_APP == "세탁기")
        NILM_result <- predict.forceWasher(meta = meta, data = householdPower, country = toupper(COUNTRY), debug = FALSE)
      else if (CHOSEN_APP == "전기밥솥")
        NILM_result <- predict.forceRiceCooker(object = householdPower, meta = meta, country = toupper(COUNTRY))
      else if (CHOSEN_APP == "에어컨")
        NILM_result <- predict.forceAirConditioner(data = householdPower, debug = TRUE)
      else
        stop("invalid appliance")

      # plug data
      plugFile <- paste0(DATA_DIR, x$plug[1])
      plug_result <- read_feather(plugFile) %>% filter(timestamp %within% consideredTimePeriod) %>%
                     mutate(active_power = abs(active_power)) %>% arrange(timestamp)
      plug_result <- plug_result[!duplicated(plug_result$timestamp), ]


      if (nrow(x) >= 2){

        for(plugIdx in 2:nrow(x)) {

          plugFile <- paste0(DATA_DIR, x$plug[plugIdx])
          another_plug_result <- read_feather(plugFile) %>% filter(timestamp %within% consideredTimePeriod) %>%
                                 mutate(active_power = abs(active_power)) %>% arrange(timestamp)

          another_plug_result <- another_plug_result[!duplicated(another_plug_result$timestamp), ]

          tmp_combined_result <- full_join(plug_result, another_plug_result, by = "timestamp")

          plug_result <- data.frame(timestamp = tmp_combined_result$timestamp, active_power = rowSums(tmp_combined_result %>% select(active_power.x,active_power.y), na.rm = TRUE),
                                    reactive_power = rowSums(tmp_combined_result %>% select(reactive_power.x,reactive_power.y), na.rm = TRUE)) %>% arrange(timestamp)
        }

      }

      result <- summary.acc(NILM_result$usage, plug_result, threshold = c(POWER_THRES,POWER_THRES), time_unit = "15 mins")
      result$siteId <- indicator
      saveRDS(result, paste0(NILM_SUMMARY_DIR,indicator,"_",CHOSEN_APP,".rds"))
      print(result)
    }

    return(NULL)
  })

}
