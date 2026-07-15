# Retrieve pagination metadata

Retrieve pagination metadata

## Usage

``` r
result_metadata(x)

obrasgov_metadados(x)
```

## Arguments

- x:

  A tibble returned by a paginated package function.

## Value

A list containing the resource, totals reported by the API, and
retrieved pages; `NULL` for other objects.

## Examples

``` r
result_metadata(tibble::tibble())
#> NULL
```
