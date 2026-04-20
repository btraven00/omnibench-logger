test_that("init_logger creates missing directory and returns log path", {
  d <- file.path(tempdir(), paste0("ob-init-", as.integer(Sys.time())))
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  expect_false(dir.exists(d))
  p <- init_logger(d)
  expect_true(dir.exists(d))
  expect_equal(basename(p), "omnibench-events.jsonl")
})

test_that("init_logger rejects bad input", {
  expect_error(init_logger(""), "non-empty")
  expect_error(init_logger(NULL), "non-empty")
  expect_error(init_logger(c("a", "b")), "non-empty")
})

test_that("emit without init warns once and no-ops", {
  st <- get(".omnibench_state", envir = asNamespace("omnibench.logger"))
  st$log_file <- NULL
  st$warned_uninit <- FALSE
  expect_warning(out <- emit("x", "start"), "before init_logger")
  expect_false(out)
  expect_silent(emit("x", "end"))
})
