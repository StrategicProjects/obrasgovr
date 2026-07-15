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
