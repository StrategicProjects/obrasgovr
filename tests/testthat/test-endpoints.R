test_that("each public function targets its documented endpoint", {
  seen <- list()
  mock <- function(req) {
    seen[[length(seen) + 1L]] <<- req
    mock_paginated_response()
  }
  httr2::local_mocked_responses(mock)

  obter_projetos(base_url = "https://example.test/obras")
  obter_empenhos(base_url = "https://example.test/obras")
  obter_execucao_fisica(base_url = "https://example.test/obras")
  obter_contratos(base_url = "https://example.test/obras")
  obter_geometrias(base_url = "https://example.test/obras")
  obter_historico_situacao(base_url = "https://example.test/obras")
  obter_estudos_viabilidade(base_url = "https://example.test/obras")

  urls <- purrr::map_chr(seen, httr2::req_get_url)
  expected <- c(
    "projeto-investimento",
    "empenho",
    "execucao-fisica",
    "contrato",
    "geometria",
    "historico-situacao-cancelada-paralisada",
    "estudo-viabilidade"
  )

  expect_true(all(purrr::map2_lgl(urls, expected, function(url, endpoint) {
    grepl(endpoint, url, fixed = TRUE)
  })))
})

test_that("the update timestamp is parsed in UTC", {
  response <- httr2::response_json(
    status_code = 200L,
    body = list(data_ultima_atualizacao = "2026-07-15T00:00:00")
  )
  httr2::local_mocked_responses(list(response))

  result <- obter_data_atualizacao(base_url = "https://example.test/obras")

  expect_s3_class(result, "POSIXct")
  expect_equal(format(result, tz = "UTC"), "2026-07-15")
})

test_that("resource and filter metadata are discoverable", {
  resources <- obrasgov_recursos()
  filters <- obrasgov_filtros("geometrias")

  expect_equal(nrow(resources), 8L)
  expect_true("obter_projetos" %in% resources$funcao)
  expect_true("sg_uf" %in% filters$filtro)
  expect_equal(filters$tipo[filters$filtro == "cod_ibge"], "integer")
  expect_error(obrasgov_filtros("inexistente"), "Recurso desconhecido")
})
