test_that("the official API reports its update timestamp", {
  testthat::skip_on_cran()
  testthat::skip_if(
    Sys.getenv("OBRASGOVR_LIVE_TESTS") != "true",
    "Set OBRASGOVR_LIVE_TESTS=true to run integration tests"
  )

  expect_s3_class(get_last_update(), "POSIXct")
})
