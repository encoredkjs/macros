#' @export
convertNILMResultToTepcoSTD <- function(SOURCE_DIR,
                                        SOURCE_FILE_TYPE,
                                        DATA_DIR,
                                        DATA_SUFFIX) {

  typeIdTbl <- data.frame(typeid = c(12, 62, 67, 66, 68, 65),
                          app_name = c("tv","refrigerator","washer","ricecooker","microwave","aircon"))

  if(!dir.exists(DATA_DIR)) {
    dir.create(DATA_DIR)
  }

  # [ORIGINAL COLUMN NAMES]
  # site_id, virtual_appliance_id, appliance_type_id,
  # unit_period[raw, qhourly, hourly, daily], timestamp[datetime class], usage_Wh

  # load entire files
  wholeFileList <- list.files(path = SOURCE_DIR, full.names = FALSE, include.dirs = FALSE)
  wholeFileList <- wholeFileList[grep(SOURCE_FILE_TYPE, wholeFileList)]

  for(Idx in 1:length(wholeFileList)) {

    fileNameWithPath <- paste0(SOURCE_DIR, wholeFileList[Idx])
    if(SOURCE_FILE_TYPE == "csv")
      rawNILMUsage <- fread(fileNameWithPath)
    else if(SOURCE_FILE_TYPE == "rds")
      rawNILMUsage <- readRDS(fileNameWithPath)
    else
      stop("invalid file type")

    serialNum <- JediETL::convertKey(rawNILMUsage$site_id[1], "site_id", "serial_number") %>% baseEncored::convertDec2Hex()

    appTypeIDs <- unique(rawNILMUsage$appliance_type_id)
    appTypeIDs <- appTypeIDs[which(appTypeIDs %in% typeIdTbl$typeid)]

    if(length(appTypeIDs) == 0){
      rm(rawNILMUsage)
      next
    }

    for(Idx_validAppType in 1:length(appTypeIDs)) {

      oneAppTypeID <- appTypeIDs[Idx_validAppType]
      oneAppTypeUsage <- rawNILMUsage %>% filter(appliance_type_id == oneAppTypeID)

      saveApplianceUsage_TepcoStd(nameTable = typeIdTbl,
                                  saveDIR = DATA_DIR,
                                  file_suffix = DATA_SUFFIX,
                                  sn = serialNum,
                                  ID = oneAppTypeID,
                                  usage = oneAppTypeUsage)
      rm(oneAppTypeUsage)
    }
    rm(rawNILMUsage)
  }
}

saveApplianceUsage_TepcoStd <- function(nameTable, saveDIR, file_suffix, sn, ID, usage){

  appName <- nameTable$app_name[which(ID == nameTable$typeid)]

  virtualAppIDs <- unique(usage$virtual_appliance_id)

  if(length(virtualAppIDs) == 1) {

    # process 1 sec. usage data
    usage_1s <- convertNILMResultToTepcoSTD_core(orgUsage = usage, period_ID = "raw", sn = sn)
    fwrite(usage_1s, paste0(saveDIR, sn,"_NILM_1s_",ID, "_", appName, "_", file_suffix) )

    # process 15 min. usage data
    usage_15m <- convertNILMResultToTepcoSTD_core(orgUsage = usage, period_ID = "qhourly", sn = sn)
    fwrite(usage_15m, paste0(saveDIR, sn,"_NILM_15m_",ID, "_", appName, "_", file_suffix) )

    rm(usage_1s)
    rm(usage_15m)

  } else if(length(virtualAppIDs) > 1) {

    for(virtualIdIdx in 1:length(virtualAppIDs)){

      oneVirtualAppID <- virtualAppIDs[virtualIdIdx]
      VirtualAppUsage <- usage %>% filter( virtual_appliance_id == oneVirtualAppID)

      # process 1 sec. usage data
      usage_1s <- convertNILMResultToTepcoSTD_core(orgUsage = VirtualAppUsage, period_ID = "raw", sn = sn)
      fwrite(usage_1s, paste0(saveDIR, sn,"_NILM_1s_",ID, "_", appName, virtualIdIdx, "_", file_suffix) )

      # process 15 min. usage data
      usage_15m <- convertNILMResultToTepcoSTD_core(orgUsage = VirtualAppUsage, period_ID = "qhourly", sn = sn)
      fwrite(usage_15m, paste0(saveDIR, sn,"_NILM_15m_",ID, "_", appName, virtualIdIdx, "_", file_suffix) )

      rm(usage_1s)
      rm(usage_15m)
    }
  }
}

convertNILMResultToTepcoSTD_core <- function(orgUsage, period_ID, sn){

  return(orgUsage %>% filter(unit_period == period_ID, !is.na(usage_Wh)) %>%
    mutate(serialNumber = sn, unitPeriodUsage = usage_Wh, timestamp = as.numeric(timestamp) * 1000, typeid = appliance_type_id) %>%
    select(serialNumber, timestamp, unitPeriodUsage, typeid)) %>% arrange(timestamp)
}
