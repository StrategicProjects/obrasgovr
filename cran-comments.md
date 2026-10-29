# obrasgovr 0.1.1

## R CMD check results

0 errors | 0 warnings | 1 note

The note is local-toolchain-specific: HTML manual validation is skipped
because the installed HTML Tidy is older than the version expected by R-devel.
It does not concern package code or documentation.

## Submission

This is the first update since 0.1.0 (published 2026-07-24). It is a small
maintenance release:

- `list_filters()` now reports the allowed values that the upstream OpenAPI
  contract declares for five additional filters.
- The default user agent derives its version from the installed package
  instead of a hard-coded string.
- Author metadata was aligned across registries: the maintainer's name now
  carries its accent (Andre -> André; the maintainer email is unchanged), one
  author's contact address was updated, and ORCID iDs were added.
- Documentation updates (README).

The package accesses a public Brazilian government API. Examples and vignettes
do not require network access during checks. Network behavior is covered by
mocked unit tests; an opt-in live integration test is skipped on CRAN.

## Reverse dependencies

There are no reverse dependencies on CRAN.
