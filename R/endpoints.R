#' Consultar projetos de investimento
#'
#' Recupera projetos de infraestrutura e suas relacoes aninhadas, como
#' executores, tomadores, fontes de recurso, eixos e geometrias pontuais.
#'
#' @param ... Filtros nomeados aceitos pelo recurso. Consulte a lista completa
#'   com `obrasgov_filtros("projetos")`.
#' @param pagina Pagina inicial, a partir de 1.
#' @param tamanho_da_pagina Numero de registros por pagina, entre 1 e 200.
#' @param todas_paginas Se `TRUE`, coleta paginas sucessivas a partir de
#'   `pagina`.
#' @param limite_paginas Limite de paginas coletadas quando `todas_paginas` e
#'   `TRUE`. Use `Inf` para coletar todas as paginas disponiveis.
#' @param base_url URL base HTTPS. Por padrao, usa a opcao
#'   `obrasgov.base_url` ou o ambiente oficial da API.
#'
#' @return Um tibble. Relacoes um-para-muitos sao preservadas em colunas de
#'   lista. Use [obrasgov_metadados()] para consultar a paginacao.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_projetos(uf_principal = "PE", tamanho_da_pagina = 10)
#' }
obter_projetos <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "projetos",
    rlang::list2(...),
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )
}
#' Consultar empenhos
#'
#' @inheritParams obter_projetos
#' @param ... Filtros nomeados. Consulte `obrasgov_filtros("empenhos")`.
#'
#' @return Um tibble com empenhos e valores de execucao financeira.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_empenhos(id_projeto_investimento = "134851.26-07")
#' }
obter_empenhos <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "empenhos",
    rlang::list2(...),
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )
}

#' Consultar execucao fisica
#'
#' @inheritParams obter_projetos
#' @param ... Filtros nomeados. Consulte
#'   `obrasgov_filtros("execucao_fisica")`.
#'
#' @return Um tibble com percentuais, instrumentos e datas de execucao.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_execucao_fisica(id_projeto_investimento = "134851.26-07")
#' }
obter_execucao_fisica <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "execucao_fisica",
    rlang::list2(...),
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )
}

#' Consultar contratos
#'
#' @inheritParams obter_projetos
#' @param ... Filtros nomeados. Consulte `obrasgov_filtros("contratos")`.
#'
#' @return Um tibble com contratos vinculados aos projetos.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_contratos(id_projeto_investimento = "134851.26-07")
#' }
obter_contratos <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "contratos",
    rlang::list2(...),
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )
}

#' Consultar geometrias
#'
#' @inheritParams obter_projetos
#' @param ... Filtros nomeados. Consulte `obrasgov_filtros("geometrias")`.
#'
#' @return Um tibble com geometrias e identificadores territoriais.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_geometrias(sg_uf = "PE", tamanho_da_pagina = 10)
#' }
obter_geometrias <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "geometrias",
    rlang::list2(...),
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )
}

#' Consultar historico de situacoes
#'
#' Recupera historicos de projetos cancelados ou paralisados e suas
#' justificativas e tratativas.
#'
#' @inheritParams obter_projetos
#' @param ... Filtros nomeados. Consulte
#'   `obrasgov_filtros("historico_situacao")`.
#'
#' @return Um tibble com historicos de situacao.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_historico_situacao(
#'     id_projeto_investimento = "134851.26-07"
#'   )
#' }
obter_historico_situacao <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "historico_situacao",
    rlang::list2(...),
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )
}

#' Consultar estudos de viabilidade
#'
#' @inheritParams obter_projetos
#' @param ... Filtros nomeados. Consulte
#'   `obrasgov_filtros("estudos_viabilidade")`.
#'
#' @return Um tibble com os estudos de viabilidade vinculados aos projetos.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_estudos_viabilidade(
#'     id_projeto_investimento = "134851.26-07"
#'   )
#' }
obter_estudos_viabilidade <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "estudos_viabilidade",
    rlang::list2(...),
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url
  )
}

#' Consultar a data de atualizacao dos dados
#'
#' @param base_url URL base HTTPS. Por padrao, usa a opcao
#'   `obrasgov.base_url` ou o ambiente oficial da API.
#'
#' @return Um valor `POSIXct` no fuso horario UTC.
#' @export
#' @family recursos
#' @examples
#' if (interactive()) {
#'   obter_data_atualizacao()
#' }
obter_data_atualizacao <- function(base_url = .obrasgov_base_url()) {
  body <- .obrasgov_perform("data-atualizacao", base_url = base_url)
  value <- body$data_ultima_atualizacao

  if (!is.character(value) || length(value) != 1L) {
    cli::cli_abort(
      "A resposta de data de atualizacao possui formato inesperado.",
      class = "obrasgov_response_error"
    )
  }

  as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
}

.endpoint_query <- function(
    resource,
    filters,
    pagina,
    tamanho_da_pagina,
    todas_paginas,
    limite_paginas,
    base_url) {
  .obrasgov_get_paginated(
    resource = resource,
    filters = filters,
    pagina = pagina,
    tamanho_da_pagina = tamanho_da_pagina,
    todas_paginas = todas_paginas,
    limite_paginas = limite_paginas,
    base_url = base_url
  )
}
