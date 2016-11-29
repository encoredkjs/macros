getOneWordFromString <- function(string, position = 1, sep = "_"){
  str_splitted <- str_split(string = string, pattern = sep, n = Inf)
  return(str_splitted[[1]][position])
}
