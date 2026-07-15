#' obrasgov: acesso aos dados abertos do ObrasGov
#'
#' O pacote `obrasgov` fornece uma interface moderna e tipada para a API de
#' dados abertos do ObrasGov. Cada recurso da API é representado por uma função
#' que retorna um [tibble::tibble()], preservando relações aninhadas em colunas
#' de lista.
#'
#' As requisições usam HTTP/2 sobre TLS quando suportado pelo `libcurl`, com
#' tentativas automáticas para falhas transitórias e limitação responsável da
#' taxa de acesso. A API não exige autenticação.
#'
#' @section Opções:
#' - `obrasgov.base_url`: URL base alternativa para a API.
#' - `obrasgov.timeout`: tempo limite de cada requisição, em segundos.
#' - `obrasgov.user_agent`: identificador HTTP alternativo.
#'
#' @seealso
#' [Documentacao oficial da API][api-docs]
#'
#' [api-docs]: https://api-publica.obrasgov.gestao.gov.br/obras/docs
#'
#' @keywords internal
"_PACKAGE"
