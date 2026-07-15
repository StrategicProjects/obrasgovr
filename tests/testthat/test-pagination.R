test_that("multiple pages are combined into a typed tibble", {
  requests <- list()
  mock <- function(req) {
    requests[[length(requests) + 1L]] <<- req
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
  }
  httr2::local_mocked_responses(mock)

  result <- obter_projetos(
    uf_principal = "PE",
    tamanho_da_pagina = 1L,
    todas_paginas = TRUE,
    base_url = "https://example.test/obras"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2L)
  expect_s3_class(result$dt_cadastro, "Date")
  expect_type(result$executores, "list")
  expect_length(result$executores[[1]], 2L)
  expect_length(requests, 2L)

  metadata <- obrasgov_metadados(result)
  expect_equal(metadata$total_paginas, 2L)
  expect_equal(metadata$paginas_coletadas, 2L)
  expect_equal(metadata$recurso, "projetos")
})

test_that("page limits are respected", {
  count <- 0L
  mock <- function(req) {
    count <<- count + 1L
    mock_paginated_response(
      data = list(list(id_projeto_investimento = as.character(count))),
      total_pages = 10L
    )
  }
  httr2::local_mocked_responses(mock)

  result <- obter_projetos(
    todas_paginas = TRUE,
    limite_paginas = 3L,
    base_url = "https://example.test/obras"
  )

  expect_equal(nrow(result), 3L)
  expect_equal(count, 3L)
  expect_equal(obrasgov_metadados(result)$paginas_coletadas, 3L)
})

test_that("empty API pages return an empty tibble", {
  httr2::local_mocked_responses(list(mock_paginated_response()))

  result <- obter_contratos(base_url = "https://example.test/obras")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
  expect_equal(obrasgov_metadados(result)$total_itens, 0L)
})
