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

# `page_number` must reflect the page actually being answered: hardcoding it to
# 1 made every multi-page fixture claim to be page 1, which is exactly the
# inconsistency the client now rejects.
mock_paginated_response <- function(data = list(),
                                    total_pages = 1L,
                                    page_number = 1L) {
  httr2::response_json(
    status_code = 200L,
    body = list(
      data = data,
      total_pages = total_pages,
      total_items = length(data),
      page_number = page_number,
      page_size = 50L
    )
  )
}

# Builds a response from literal JSON, so that fixtures can express what the API
# actually sends. `httr2::response_json()` round-trips through jsonlite, which
# turns R `NULL` into `{}` and cannot represent a JSON `null`.
mock_json_response <- function(json, status_code = 200L) {
  httr2::response(
    status_code = status_code,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(json)
  )
}
