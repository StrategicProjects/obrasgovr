test_that("each public function targets its documented endpoint", {
  recorded <- local_recorded_requests()

  get_projects(base_url = "https://example.test/obras")
  get_commitments(base_url = "https://example.test/obras")
  get_physical_execution(base_url = "https://example.test/obras")
  get_contracts(base_url = "https://example.test/obras")
  get_geometries(base_url = "https://example.test/obras")
  get_status_history(base_url = "https://example.test/obras")
  get_feasibility_studies(base_url = "https://example.test/obras")

  urls <- purrr::map_chr(recorded$requests, httr2::req_get_url)
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

  result <- get_last_update(base_url = "https://example.test/obras")

  expect_s3_class(result, "POSIXct")
  expect_identical(format(result, tz = "UTC"), "2026-07-15")
})

test_that("resource and filter metadata are discoverable", {
  resources <- list_resources()
  filters <- list_filters("geometries")

  expect_identical(nrow(resources), 8L)
  expect_true("get_projects" %in% resources$function_name)
  expect_true("sg_uf" %in% filters$filter)
  expect_identical(filters$type[filters$filter == "cod_ibge"], "integer")
  expect_error(list_filters("missing"), "Unknown resource")
})

test_that("Portuguese compatibility aliases remain available", {
  response <- httr2::response_json(
    status_code = 200L,
    body = list(data_ultima_atualizacao = "2026-07-15T00:00:00")
  )
  httr2::local_mocked_responses(list(response))

  expect_s3_class(
    obter_data_atualizacao(base_url = "https://example.test/obras"),
    "POSIXct"
  )
  expect_identical(nrow(obrasgov_filtros("geometrias")), 6L)
  expect_identical(nrow(obrasgov_recursos()), 8L)
})

test_that("enum filters expose the values the OpenAPI contract declares", {
  allowed <- function(resource, filter) {
    filters <- list_filters(resource)
    filters$allowed_values[[match(filter, filters$filter)]]
  }

  expect_true("Obra" %in% allowed("projects", "natureza_intervencao"))
  expect_true(
    "Construção" %in% allowed("projects", "especie_intervencao")
  )
  expect_true(
    "Serviços de Engenharia" %in%
      allowed("contracts", "categoria_contrato")
  )
  expect_true(
    "Par de Lat/Long" %in% allowed("geometries", "origem_geometria")
  )
  expect_true(
    "Técnica" %in%
      allowed("feasibility_studies", "tipo_estudo_viabilidade")
  )
})
