#' @export
packageFunctionLengths <- function(package)
  vapply(package.functions(package), function.length, integer(1))

package.functions <- function(package) {
  pkg <- sprintf("package:%s", package)
  object.names <- ls(name = pkg)
  objects <- lapply(object.names, get, pkg)
  names(objects) <- object.names
  objects[sapply(objects, is.function)]
}

function.length <- function(f) {
  if (is.character(f))
    f <- match.fun(f)
  length(deparse(f))
}
