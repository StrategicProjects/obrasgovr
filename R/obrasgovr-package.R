#' obrasgovr: Access ObrasGov open data
#'
#' `obrasgovr` provides a modern, typed interface to the ObrasGov open data
#' API. Each API resource is represented by a function that returns a
#' [tibble::tibble()], preserving nested relationships in list-columns.
#'
#' Requests use HTTP/2 over TLS when supported by `libcurl`, with automatic
#' retries for transient failures and responsible request throttling. The API
#' does not require authentication.
#'
#' @section Options:
#' - `obrasgovr.base_url`: alternative API base URL.
#' - `obrasgovr.timeout`: timeout for each request, in seconds.
#' - `obrasgovr.user_agent`: alternative HTTP user agent.
#'
#' @seealso
#' [Official API documentation][api-docs]
#'
#' [api-docs]: https://api-publica.obrasgov.gestao.gov.br/obras/docs
#'
#' @importFrom rlang %||%
#' @keywords internal
"_PACKAGE"
