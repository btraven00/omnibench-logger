read_events <- function(log_file) {
  lines <- readLines(log_file, warn = FALSE)
  lapply(lines, jsonlite::fromJSON, simplifyVector = FALSE)
}

test_that("emit writes required fields in JSONL", {
  d <- file.path(tempdir(), paste0("ob-emit-", as.integer(Sys.time())))
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  log_file <- init_logger(d)

  emit("align", "start")
  emit("align", "end", attrs = list(nreads = 12345, ok = TRUE))

  ev <- read_events(log_file)
  expect_length(ev, 2)

  for (e in ev) {
    expect_true(all(c("ts", "event", "phase", "pid", "host") %in% names(e)))
    expect_match(e$ts, "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$")
    expect_equal(e$event, "align")
  }
  expect_equal(ev[[1]]$phase, "start")
  expect_equal(ev[[2]]$phase, "end")
  expect_equal(ev[[2]]$attrs$nreads, 12345)
  expect_true(ev[[2]]$attrs$ok)
})

test_that("emit validates phase", {
  d <- file.path(tempdir(), paste0("ob-phase-", as.integer(Sys.time())))
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  init_logger(d)
  expect_error(emit("x", "begin"), "start.*end")
  expect_error(emit("", "start"), "non-empty")
})

test_that("emit appends across calls (does not truncate)", {
  d <- file.path(tempdir(), paste0("ob-append-", as.integer(Sys.time())))
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  log_file <- init_logger(d)
  for (i in 1:5) emit(paste0("e", i), "start")
  expect_length(readLines(log_file), 5)
})
