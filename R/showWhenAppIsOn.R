#' @export
showWhenAppIsOn <- function(METHOD = "plot",
                            HOUSEHOLD_DIR,
                            RESULT_DIR,
                            CHOSEN_APP,
                            PLOT_NUM_MAX,
                            AP_THRES_MIN,
                            AP_CONSIDERED_MAX) {

  if(!dir.exists(HOUSEHOLD_DIR)) {
    dir.create(HOUSEHOLD_DIR)
  }

  if(!dir.exists(RESULT_DIR)) {
    dir.create(RESULT_DIR)
  }

  # load entire files
  wholeFileList <- list.files(path = HOUSEHOLD_DIR, full.names = FALSE, include.dirs = FALSE)
  wholeFileList <- wholeFileList[grep("feather", wholeFileList)]

  # indicator for each file
  siteIdx <- sapply(wholeFileList, function(x){ vec <- str_split(x, "_", n = Inf)
                    return(vec[[1]][1])}, USE.NAMES = FALSE)

  # build home & plug set
  pairsForHomePlug <- data.frame(fileName = wholeFileList, indicator = siteIdx) %>% group_by(indicator) %>%
                      do( matchHomePlugFile(data = ., plug = CHOSEN_APP) )

  if(nrow(pairsForHomePlug) == 0)
    return(NULL)

  for( onePairIdx in seq(nrow(pairsForHomePlug)) ){

    onePair <- pairsForHomePlug[onePairIdx,]
    filePath <- HOUSEHOLD_DIR

    home <- read_feather(paste0( filePath, onePair$home )) %>% filter( channel > 0 )
    plug <- read_feather(paste0( filePath, onePair$plug )) # %>% mutate(serial_key = i$indicator)

    home <- home %>% select( timestamp, active_power, reactive_power, channel )
    plug <- plug %>% select( timestamp, active_power, reactive_power )

    home <- home %>% filter( active_power > 0, active_power < AP_CONSIDERED_MAX)
    plug <- plug %>% filter( active_power > 0, active_power < AP_CONSIDERED_MAX)

    if(METHOD == "plot" || METHOD == "both") {

      print(gsub('.feather',".png", onePair$plug ))

      # 그림 파일 저장
      fig <- jpTest::showActivePartOfPlugWithEnertalk( plug, home, nCol = PLOT_NUM_MAX)

      # plotly::ggplotly(fig)
      if(!is.null(fig)){

        png( paste0( RESULT_DIR, gsub('.feather',".png",onePair$plug )), width=3000)
        print(fig)
        dev.off()
        print('done')
      }
    }

    if(METHOD == "file" || METHOD == "both") {

      print(gsub('.feather',".rds",onePair$plug ))

      if (!("active_power" %in% names(plug)) && ("p" %in% names(plug)))
        plug <- plug %>% rename(active_power = p)
      activeRange <- jpTest::activePartOfData(plug)

      saveRDS( activeRange, paste0(RESULT_DIR, gsub('.feather',".rds",onePair$plug )) )

    }

  }

}
