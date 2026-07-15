.obrasgov_default_url <- "https://api-publica.obrasgov.gestao.gov.br/obras"

.obrasgov_base_url <- function() {
  getOption("obrasgov.base_url", .obrasgov_default_url)
}

.obrasgov_timeout <- function() {
  getOption("obrasgov.timeout", 30)
}

.obrasgov_user_agent <- function() {
  getOption(
    "obrasgov.user_agent",
    paste0(
      "obrasgov/0.1.0 ",
      "(https://api-publica.obrasgov.gestao.gov.br/obras/docs)"
    )
  )
}

.obrasgov_request <- function(endpoint, query = list(), base_url) {
  .check_base_url(base_url)

  base_url <- sub("/+$", "", base_url)
  endpoint <- sub("^/+", "", endpoint)

  req <- httr2::request(base_url) |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_user_agent(.obrasgov_user_agent()) |>
    httr2::req_options(http_version = 4L) |>
    httr2::req_timeout(seconds = .obrasgov_timeout()) |>
    httr2::req_throttle(
      rate = 60,
      fill_time_s = 60,
      realm = "obrasgov"
    ) |>
    httr2::req_retry(max_tries = 4, retry_on_failure = TRUE) |>
    httr2::req_error(is_error = function(resp) FALSE)

  if (length(query) > 0L) {
    req <- httr2::req_url_query(req, !!!query)
  }

  req
}

.obrasgov_perform <- function(endpoint, query = list(), base_url) {
  response <- .obrasgov_request(endpoint, query, base_url) |>
    httr2::req_perform()

  .abort_for_status(response)

  tryCatch(
    httr2::resp_body_json(response, simplifyVector = FALSE),
    error = function(error) {
      cli::cli_abort(
        "A API ObrasGov retornou JSON invalido.",
        class = "obrasgov_response_error",
        parent = error
      )
    }
  )
}

.abort_for_status <- function(response) {
  status <- httr2::resp_status(response)

  if (status < 400L) {
    return(invisible(response))
  }

  detail <- .response_error_detail(response)
  message <- paste0(
    "A API ObrasGov retornou HTTP ", status, " (",
    httr2::resp_status_desc(response), ")."
  )

  if (nzchar(detail)) {
    message <- paste(message, detail)
  }

  cli::cli_abort(
    message,
    class = c("obrasgov_http_error", paste0("obrasgov_http_", status))
  )
}

.response_error_detail <- function(response) {
  body <- tryCatch(
    httr2::resp_body_json(response, simplifyVector = FALSE),
    error = function(error) NULL
  )

  if (is.null(body$detail)) {
    return("")
  }

  if (is.character(body$detail)) {
    return(paste(body$detail, collapse = "; "))
  }

  if (is.list(body$detail)) {
    messages <- purrr::map_chr(body$detail, function(item) {
      if (is.list(item) && is.character(item$msg)) {
        return(item$msg[[1]])
      }
      "Erro de validacao"
    })
    return(paste(unique(messages), collapse = "; "))
  }

  ""
}

.obrasgov_get_paginated <- function(
    resource,
    filters,
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url) {
  resource <- .match_resource(resource)
  metadata <- .obrasgov_resources[[resource]]

  filters <- .validate_filters(filters, metadata$filters)
  .check_pagination(
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas
  )

  bodies <- .obrasgov_collect_pages(
    metadata,
    filters,
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )

  records <- purrr::map(bodies, "data") |>
    unlist(recursive = FALSE)
  result <- .records_to_tibble(records)

  .add_result_metadata(
    result,
    resource,
    metadata,
    bodies,
    pagina,
    tamanho_da_pagina
  )
}

.obrasgov_collect_pages <- function(
    metadata,
    filters,
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url) {
  first <- .obrasgov_fetch_page(
    metadata$endpoint,
    filters,
    pagina,
    tamanho_da_pagina,
    base_url
  )
  total_pages <- as.integer(.or_default(first$total_pages, 0L))
  bodies <- list(first)

  if (!isTRUE(todas_paginas) || total_pages <= pagina) {
    return(bodies)
  }

  last_page <- total_pages
  if (is.finite(limite_paginas)) {
    last_page <- min(last_page, pagina + as.integer(limite_paginas) - 1L)
  }

  pages <- seq.int(pagina + 1L, last_page)
  remaining <- purrr::map(pages, function(page) {
    .obrasgov_fetch_page(
      metadata$endpoint,
      filters,
      page,
      tamanho_da_pagina,
      base_url
    )
  })

  c(bodies, remaining)
}

.add_result_metadata <- function(
    result,
    resource,
    metadata,
    bodies,
    pagina,
    tamanho_da_pagina) {
  first <- bodies[[1L]]
  attr(result, "obrasgov_metadata") <- list(
    recurso = resource,
    endpoint = metadata$endpoint,
    total_paginas = as.integer(.or_default(first$total_pages, 0L)),
    total_itens = as.integer(.or_default(first$total_items, 0L)),
    pagina_inicial = as.integer(pagina),
    paginas_coletadas = length(bodies),
    tamanho_da_pagina = as.integer(tamanho_da_pagina),
    coletado_em = Sys.time()
  )

  result
}

.obrasgov_fetch_page <- function(
    endpoint,
    filters,
    pagina,
    tamanho_da_pagina,
    base_url) {
  query <- c(
    filters,
    list(
      pagina = as.integer(pagina),
      tamanho_da_pagina = as.integer(tamanho_da_pagina)
    )
  )
  body <- .obrasgov_perform(endpoint, query, base_url)

  if (!is.list(body) || is.null(body$data) || !is.list(body$data)) {
    cli::cli_abort(
      "A resposta paginada da API possui formato inesperado.",
      class = "obrasgov_response_error"
    )
  }

  body
}

.records_to_tibble <- function(records) {
  if (length(records) == 0L) {
    return(tibble::tibble())
  }

  rows <- purrr::map(records, .record_to_tibble)
  result <- purrr::list_rbind(rows)

  date_columns <- names(result)[grepl("^(dt_|data_)", names(result))]

  for (column in date_columns) {
    value <- result[[column]]
    present <- !is.na(value)

    if (
      is.character(value) &&
        any(present) &&
        all(grepl("^\\d{4}-\\d{2}-\\d{2}$", value[present]))
    ) {
      result[[column]] <- as.Date(value)
    }
  }

  result
}

.record_to_tibble <- function(record) {
  if (!is.list(record) || is.null(names(record))) {
    cli::cli_abort(
      "Um registro da API possui formato inesperado.",
      class = "obrasgov_response_error"
    )
  }

  row <- purrr::map(record, function(value) {
    if (is.null(value) || length(value) == 0L) {
      return(NA)
    }
    if (is.list(value)) {
      return(list(value))
    }
    value
  })

  tibble::as_tibble(row, .name_repair = "minimal")
}

.validate_filters <- function(filters, allowed) {
  if (length(filters) == 0L) {
    return(list())
  }

  filter_names <- names(filters)
  if (is.null(filter_names) || !all(nzchar(filter_names))) {
    cli::cli_abort("Todos os filtros em {.arg ...} devem ter nome.")
  }

  unknown <- setdiff(filter_names, names(allowed))
  if (length(unknown) > 0L) {
    cli::cli_abort(c(
      "Filtro{?s} desconhecido{?s}: {.val {unknown}}.",
      "i" = "Consulte os filtros com {.fn obrasgov_filtros}."
    ))
  }

  filters <- filters[!purrr::map_lgl(filters, is.null)]

  purrr::imap(filters, function(value, name) {
    if (length(value) != 1L || is.list(value) || is.na(value)) {
      cli::cli_abort(
        "O filtro {.arg {name}} deve conter um unico valor nao ausente."
      )
    }
    if (inherits(value, "Date")) {
      return(format(value, "%Y-%m-%d"))
    }
    value
  })
}

.check_pagination <- function(
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas) {
  .check_positive_integer(pagina, "pagina")
  .check_positive_integer(tamanho_da_pagina, "tamanho_da_pagina")

  if (tamanho_da_pagina > 200L) {
    cli::cli_abort("{.arg tamanho_da_pagina} nao pode ser maior que 200.")
  }

  if (
    !is.logical(todas_paginas) ||
      length(todas_paginas) != 1L ||
      is.na(todas_paginas)
  ) {
    cli::cli_abort("{.arg todas_paginas} deve ser `TRUE` ou `FALSE`.")
  }

  if (
    !is.numeric(limite_paginas) ||
      length(limite_paginas) != 1L ||
      is.na(limite_paginas) ||
      limite_paginas <= 0 ||
      (!is.infinite(limite_paginas) && limite_paginas %% 1 != 0)
  ) {
    cli::cli_abort(
      "{.arg limite_paginas} deve ser um inteiro positivo ou `Inf`."
    )
  }

  invisible(NULL)
}

.check_positive_integer <- function(value, argument) {
  if (
    !is.numeric(value) ||
      length(value) != 1L ||
      is.na(value) ||
      value < 1 ||
      value %% 1 != 0
  ) {
    cli::cli_abort("{.arg {argument}} deve ser um inteiro positivo.")
  }
  invisible(NULL)
}

.check_base_url <- function(base_url) {
  if (
    !is.character(base_url) ||
      length(base_url) != 1L ||
      is.na(base_url) ||
      !grepl("^https://", base_url)
  ) {
    cli::cli_abort(
      "{.arg base_url} deve ser uma URL HTTPS unica.",
      class = "obrasgov_url_error"
    )
  }
  invisible(NULL)
}

#' Metadados de paginacao de um resultado
#'
#' @param x Tibble retornado por uma funcao paginada do pacote.
#'
#' @return Uma lista com o recurso, o total informado pela API e as paginas
#'   coletadas; `NULL` para outros objetos.
#' @export
#' @examples
#' obrasgov_metadados(tibble::tibble())
obrasgov_metadados <- function(x) {
  attr(x, "obrasgov_metadata", exact = TRUE)
}

.or_default <- function(x, y) {
  if (is.null(x)) y else x
}
