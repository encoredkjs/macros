matchHomePlugFile <- function( data, plug){
  existance <- grep(plug, data$fileName)

  if (length(existance) != 0 ){
    plug_fname <- data$fileName[existance]
    home_fname <- data$fileName[grep("home", data$fileName)]

    if (length(home_fname) != 0 ){
      return(data.frame(home = home_fname, plug = plug_fname))
    }
  }
  return(data.frame(home = NULL, plug = NULL))
}
