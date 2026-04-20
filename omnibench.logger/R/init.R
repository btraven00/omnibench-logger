.omnibench_state <- new.env(parent = emptyenv())
.omnibench_state$log_file <- NULL
.omnibench_state$warned_uninit <- FALSE

#' Initialize the omnibench event logger.
#'
#' Creates `path` if it does not exist and configures subsequent
#' `emit()` calls to append to `<path>/omnibench-events.jsonl`.
#'
#' @param path Directory that will hold the event log.
#' @return The resolved log file path, invisibly.
#' @export
init_logger <- function(path) {
  if (!is.character(path) || length(path) != 1L || !nzchar(path)) {
    stop("init_logger(): 'path' must be a non-empty string")
  }
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
  log_file <- file.path(normalizePath(path, mustWork = TRUE),
                        "omnibench-events.jsonl")
  .omnibench_state$log_file <- log_file
  .omnibench_state$warned_uninit <- FALSE
  invisible(log_file)
}
