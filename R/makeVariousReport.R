#' @export
makeVariousReport <- function(SUMMARY_DIR, APP_TYPE) {

  listOfJpGroup <- list(
    "wholeSet" = list(),
    'yazaki' = list(
      "F3020022",
      "F302002C",
      "F302002D",
      "F3020045",
      "F302004A",
      "F3020021",
      "F3020055",
      "F3020056",
      "F3020058",
      "F302005F",
      "F3020060",
      "F3020061",
      "F302002E",
      "F3020053",
      "F3020026"
    ),
    # 'tepco' = list(
    #   "F3020064",
    #   "F3020065",
    #   "F3020066",
    #   "F3020067",
    #   "F3020068",
    #   "F3020069",
    #   "F302006A",
    #   "F302006B",
    #   "F302006C",
    #   "F302006D",
    #   "F302006E",
    #   "F302006F",
    #   "F3020070",
    #   "F3020071",
    #   "F3020072",
    #   "F3020073",
    #   "F3020074",
    #   "F30200B1",
    #   "F30200B2",
    #   "F30200B6"
    # ),
    'tohokue' = list(
      "F30200C8",
      "F30200C9",
      "F30200CA",
      "F30200CB",
      "F30200CC",
      "F30200CD",
      "F30200CE",
      "F30200CF",
      "F30200D0",
      "F30200D1",
      "F30200D2",
      "F30200D3",
      "F30200D4",
      "F30200D5"
    )
  )

  docDirectory <- SUMMARY_DIR %>% sprintf('%s/doc', .)
  rmdScript <- readLines(list.files(docDirectory, pattern = '.Rmd', full.names = TRUE))

  noMeta <- rmdScript[grepl("- No meta is generated : ", rmdScript)]
  noMeta <-
    gsub("- No meta is generated : ", "", noMeta) %>%
    stringr::str_split(., ",") %>%
    unlist()

  strLine <- grepl("### Accuracy table", rmdScript) %>% which(.) + 4
  meta <- rmdScript[-(1:strLine - 1)]
  meta <- sapply(strsplit(meta, "\\|"), function(x) {
    x <- x[grepl("F|A", x)]
    x[str_length(x) < 10]
  }) %>% unlist

  siteIds <- c(noMeta, meta) %>% gsub(" ", "", .)

  siteIdsOfJpGroup <- sapply(listOfJpGroup, function(x){
    if(NROW(x) == 0){
      return(siteIds)
    }
    siteIds[siteIds %in% x]
  }, USE.NAMES = TRUE)

  lapply(siteIdsOfJpGroup, function(sites){
    tmpDir <- tempdir()

    print(tmpDir)
    if(!dir.exists(tmpDir)) {
      dir.create(tmpDir)
    }

    tmpDir <- tempfile()

    system(sprintf("cp -r %s %s", SUMMARY_DIR, tmpDir))
    files <- list.files(tmpDir, recursive = TRUE, full.names = TRUE)
    removeFiles <- setdiff(files, sapply(sites, function(x) files[grepl(x, files)]) %>% unlist(.))
    sapply(removeFiles, function(f) sprintf("rm %s", f) %>% system(.))
    paste(
      "/home/kjs/Encored/pyennilmdata/evalnilm/data/rscripts/make_report.R ",
      "-s %s",
      "-d %s",
      "-v %s",
      paste("-a", APP_TYPE),
      "-r %s",
      "-e %s",
      "-f %s"
    ) %>% sprintf(
      .,
      baseEncored::convertHex2Dec(sites) %>% paste(., collapse = ','),
      tmpDir,
      rmdScript[grepl("package versions", rmdScript)] %>% gsub("- package versions  ", "", .),
      rmdScript[grepl("- Training Data : ", rmdScript)] %>%
        gsub("- Training Data : ", "", .) %>%
        gsub(" -- ", "--", .) %>%
        gsub(" ", "", .),
      rmdScript[grepl("- Test Data : ", rmdScript)] %>%
        gsub("- Test Data : ", "", .) %>%
        gsub(" -- ", "--", .) %>%
        gsub(" ", "", .),
      docDirectory
    )
  })

  # system(sprintf("rm -r %s", tempdir()))


}
