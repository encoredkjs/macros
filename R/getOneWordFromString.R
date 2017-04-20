getOneWordFromString <- function(string, position = 1, sep = "_"){
  str_splitted <- str_split(string = string, pattern = sep, n = Inf)
  return(str_splitted[[1]][position])
}

getMoreThanOneWordFromString <- function(string, position_start = 1,
                                         position_end, sep = "_"){
  str_splitted <- str_split(string = string, pattern = sep, n = Inf)
  return(paste(str_splitted[[1]][position_start:position_end], collapse = "_"))
}
