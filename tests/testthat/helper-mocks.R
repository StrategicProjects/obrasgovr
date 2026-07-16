# Mocks the HTTP transport and records every request the package sends, so that
# tests can assert on what was actually asked of the API.
#
# `handler` receives the request and the 1-based number of the call, and returns
# the response to reply with; by default it replies with an empty page. The mock
# is torn down when the calling test exits, hence `env = parent.frame()`.
local_recorded_requests <- function(handler = NULL, env = parent.frame()) {
  recorded <- new.env(parent = emptyenv())
  recorded$requests <- list()

  httr2::local_mocked_responses(
    function(req) {
      recorded$requests <- c(recorded$requests, list(req))
      if (is.null(handler)) {
        mock_paginated_response()
      } else {
        handler(req, length(recorded$requests))
      }
    },
    env = env
  )

  recorded
}

mock_paginated_response <- function(data = list(), total_pages = 1L) {
  httr2::response_json(
    status_code = 200L,
    body = list(
      data = data,
      total_pages = total_pages,
      total_items = length(data),
      page_number = 1L,
      page_size = 50L
    )
  )
}
