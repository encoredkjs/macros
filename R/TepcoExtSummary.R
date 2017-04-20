#' @export
TepcoExtSummary <- function(){

  siteID <- c("F3020064",
              "F3020065",
              "F3020066",
              "F3020067",
              "F3020068",
              "F3020069",
              "F302006A",
              "F302006B",
              "F302006C",
              "F302006D",
              "F302006E",
              "F302006F",
              "F3020070",
              "F3020071",
              "F3020072",
              "F3020073",
              "F3020074",
              "F3020075",
              "F3020076",
              "F3020077",
              "F3020078",
              "F3020079",
              "F302007A",
              "F302007B",
              "F302007C",
              "F302007D",
              "F302007E",
              "F302007F",
              "F30200F5",
              "F3020081",
              "F3020082",
              "F3020083",
              "F3020084",
              "F3020085")

  getTepcoNilmFileDetailsInFolder()

}


getTepcoNilmFileDetailsInFolder <- function(folderPath = "/disk1/tepco_export/") {

  files <- list.files(folderPath, pattern = '.csv')
  lapply(files, function(f) {
    print(f)
    str_split_output <- stringr::str_split(f, pattern = '_')[[1L]]
    data.frame(
      sn = str_split_output[1],
      samplingRate = str_split_output[3],
      appCode = str_split_output[4],
      appName = str_split_output[5],
      file = f
    )
  }) %>% bind_rows() -> nilmResults
  return(nilmResults)
}

getTepcoPlugFileDetailsInFolder <- function(folderPath = "/disk3/raw_data_with_plug/jp-201612/") {

  files <- list.files(folderPath, pattern = '.csv')
  lapply(files, function(f) {
    print(f)
    str_split_output <- stringr::str_split(f, pattern = '_')[[1L]]
    data.frame(
      sn = str_split_output[2],
      appCode = str_split_output[4],
      devSn = str_split_output[5],
      file = f
    )
  }) %>% bind_rows() -> plugResults
  return(plugResults)
}


