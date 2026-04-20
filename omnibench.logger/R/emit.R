.iso_ts <- function(t = Sys.time()) {
  ms <- sprintf("%03d", as.integer((as.numeric(t) %% 1) * 1000))
  paste0(format(t, "%Y-%m-%dT%H:%M:%S", tz = "UTC"), ".", ms, "Z")
}

#' Emit a lifecycle event.
#'
#' Appends a single JSON-lines record to the configured log file. See
#' `SPEC.md` (omnibench-events 0.1) for the wire format.
#'
#' @param event Caller-supplied event name.
#' @param phase Either `"start"` or `"end"`.
#' @param attrs Optional named list of scalar attributes.
#' @return `TRUE` if written, `FALSE` if the logger was not initialized
#'   or the write failed. Returned invisibly.
#' @export
emit <- function(event, phase, attrs = NULL) {
  if (!is.character(event) || length(event) != 1L || !nzchar(event)) {
    stop("emit(): 'event' must be a non-empty string")
  }
  if (!identical(phase, "start") && !identical(phase, "end")) {
    stop("emit(): 'phase' must be \"start\" or \"end\"")
  }
  log_file <- .omnibench_state$log_file
  if (is.null(log_file)) {
    if (!isTRUE(.omnibench_state$warned_uninit)) {
      warning("omnibenchR: emit() called before init_logger(); events discarded.")
      .omnibench_state$warned_uninit <- TRUE
    }
    return(invisible(FALSE))
  }

  rec <- list(
    ts    = .iso_ts(),
    event = event,
    phase = phase,
    pid   = Sys.getpid(),
    host  = as.character(Sys.info()[["nodename"]])
  )
  if (!is.null(attrs)) {
    if (!is.list(attrs) || (length(attrs) > 0 && is.null(names(attrs)))) {
      stop("emit(): 'attrs' must be a named list")
    }
    rec$attrs <- attrs
  }

  line <- jsonlite::toJSON(rec, auto_unbox = TRUE, null = "null")
  ok <- tryCatch({
    con <- file(log_file, open = "a")
    on.exit(close(con), add = TRUE)
    writeLines(line, con, sep = "\n", useBytes = TRUE)
    TRUE
  }, error = function(e) {
    message("omnibenchR: emit() write failed: ", conditionMessage(e))
    FALSE
  })
  invisible(ok)
}
