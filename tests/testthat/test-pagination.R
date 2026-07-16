test_that("multiple pages are combined into a typed tibble", {
  recorded <- local_recorded_requests(function(req, n) {
    url <- httr2::req_get_url(req)

    if (grepl("pagina=1", url, fixed = TRUE)) {
      return(mock_paginated_response(
        data = list(list(
          id_projeto_investimento = "1.00-00",
          dt_cadastro = "2026-01-02",
          executores = list(
            list(nome = "Orgao A"),
            list(nome = "Orgao B")
          )
        )),
        total_pages = 2L
      ))
    }

    mock_paginated_response(
      data = list(list(
        id_projeto_investimento = "2.00-00",
        dt_cadastro = "2026-02-03",
        executores = list()
      )),
      total_pages = 2L
    )
  })

  result <- get_projects(
    uf_principal = "PE",
    page_size = 1L,
    all_pages = TRUE,
    base_url = "https://example.test/obras"
  )

  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 2L)
  expect_s3_class(result$dt_cadastro, "Date")
  expect_type(result$executores, "list")
  expect_length(result$executores[[1]], 2L)
  expect_length(recorded$requests, 2L)

  metadata <- result_metadata(result)
  expect_identical(metadata$total_pages, 2L)
  expect_identical(metadata$pages_retrieved, 2L)
  expect_identical(metadata$resource, "projects")
})

test_that("page limits are respected", {
  recorded <- local_recorded_requests(function(req, n) {
    mock_paginated_response(
      data = list(list(id_projeto_investimento = as.character(n))),
      total_pages = 10L
    )
  })

  result <- get_projects(
    all_pages = TRUE,
    page_limit = 3L,
    base_url = "https://example.test/obras"
  )

  expect_identical(nrow(result), 3L)
  expect_length(recorded$requests, 3L)
  expect_identical(result_metadata(result)$pages_retrieved, 3L)
})

test_that("empty API pages return an empty tibble", {
  httr2::local_mocked_responses(list(mock_paginated_response()))

  result <- get_contracts(base_url = "https://example.test/obras")

  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 0L)
  expect_identical(result_metadata(result)$total_items, 0L)
})

test_that("Portuguese pagination arguments remain compatible", {
  httr2::local_mocked_responses(list(mock_paginated_response()))

  result <- obter_projetos(
    pagina = 1L,
    tamanho_da_pagina = 25L,
    todas_paginas = FALSE,
    limite_paginas = 1L,
    base_url = "https://example.test/obras"
  )

  expect_identical(result_metadata(result)$page_size, 25L)
})
