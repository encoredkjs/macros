#' @export
getReport_NILM <- function(SUMMARY_DIR, FIGURE_FILE, APP_NAME){
  # read nilm summary
  wholeFileList <- list.files(path = SUMMARY_DIR, full.names = FALSE, include.dirs = FALSE)

  summaryResults <- lapply(wholeFileList, function(x){
    return(readRDS(paste0(SUMMARY_DIR, x)))
  })

  summaryResults <- summaryResults[sapply(summaryResults, function(x) {
    return(!is.null(x$summary) & !is.null(x$details))
  })]

  siteIndicator <- sapply( summaryResults, function(x) return(x$siteId))
  names(summaryResults) <- siteIndicator

  accuracyTable <- lapply(summaryResults, function(x)
    x$summary) %>% bind_rows(., .id = 'sn')

  # =========================================================================================================
  # option 1) usage based result
  # apply LOG function
  # logUsage <- lapply(cumResult, function(x){
  #   return(x$details %>% rowwise() %>% mutate(plugUsage = ifelse(!is.finite(plugUsage), NA, log(1+plugUsage))) %>%
  #            mutate(nilmUsage = ifelse(!is.finite(nilmUsage), NA, log(1+nilmUsage)) ) )
  # })
  #
  # heatMapFig <- destroyForce::ggplot_onoff_tile(logUsage,type ="usage", colorLevel = 8)
  # png( 'heatMapFig_cooker.png', width=3000, height = 1000)
  # print(heatMapFig)
  # dev.off()
  # print('done')
  # figureLists <- list()
  # figureLists[[1]] <- 'heatMapFig_cooker.png'
  # =========================================================================================================

  # =========================================================================================================
  # option 2) onoff based result
  fig <-
    ggplot_onoff_tile(lapply(summaryResults, function(x)
      x$details))
  png(FIGURE_FILE, width = 3000, height = 1200)
  print(fig)
  dev.off()

  figsOutput <- list()
  figsOutput[[1]] <- FIGURE_FILE
  options(digits=3)

  comment = c()
  version = "aaa"
  generateReportCore(appliance = APP_NAME, accuracyTable = accuracyTable, figureLists = figsOutput, version = version, comment = comment, format = "pdf-landscape" )
}
