# List available ObrasGov API resources

List available ObrasGov API resources

## Usage

``` r
list_resources()

obrasgov_recursos()
```

## Value

A tibble containing each resource name, its corresponding function, API
endpoint, and whether it is paginated.

## Examples

``` r
list_resources()
#> # A tibble: 8 × 4
#>   resource            function_name           endpoint                 paginated
#>   <chr>               <chr>                   <chr>                    <lgl>    
#> 1 projects            get_projects            projeto-investimento     TRUE     
#> 2 commitments         get_commitments         empenho                  TRUE     
#> 3 physical_execution  get_physical_execution  execucao-fisica          TRUE     
#> 4 contracts           get_contracts           contrato                 TRUE     
#> 5 geometries          get_geometries          geometria                TRUE     
#> 6 status_history      get_status_history      historico-situacao-canc… TRUE     
#> 7 feasibility_studies get_feasibility_studies estudo-viabilidade       TRUE     
#> 8 last_update         get_last_update         data-atualizacao         FALSE    
```
