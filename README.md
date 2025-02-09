Lavaca Bay nutrient loading manuscript files
================

This repo contains the rmarkdown manuscript files used to generate the
following accepted manuscript:

Schramm MP. 2023. Linking watershed nutrient loading to estuary water
quality with generalized additive models. PeerJ 11:e16073
<https://doi.org/10.7717/peerj.16073>

The rmarkdown files require LaTeX and the
[lavaca-nutrients](https://github.com/TxWRI/lavaca-nutrients) repo for
targets to work properly.

``` r
renv::diagnostics()
```

    ## Diagnostics Report [renv 0.15.5]
    ## ================================
    ## 
    ## # Session Info =======================
    ## R version 4.3.1 (2023-06-16 ucrt)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows 11 x64 (build 22621)
    ## 
    ## Matrix products: default
    ## 
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.utf8 
    ## [2] LC_CTYPE=English_United States.utf8   
    ## [3] LC_MONETARY=English_United States.utf8
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.utf8    
    ## 
    ## time zone: America/New_York
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices datasets  utils     methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] compiler_4.3.1    fastmap_1.1.1     cli_3.6.1         htmltools_0.5.5  
    ##  [5] tools_4.3.1       rstudioapi_0.15.0 yaml_2.3.7        rmarkdown_2.23   
    ##  [9] knitr_1.43        xfun_0.40         digest_0.6.33     rlang_1.1.1      
    ## [13] renv_0.15.5       evaluate_0.21    
    ## 
    ## # Project ============================
    ## Project path: "C:/Data-Analysis-Projects/lavaca-nutrient-manuscript"
    ## 
    ## # Status =============================
    ## * The project is already synchronized with the lockfile.
    ## 
    ## # Packages ===========================
    ##                      Library                         Source   Lockfile Source Path Dependency
    ## BH                  1.81.0-1                           CRAN   1.81.0-1   CRAN  [1]   indirect
    ## BiocManager          1.30.22                           CRAN       <NA>   <NA>  [2]       <NA>
    ## DBI                    1.1.3                           CRAN      1.1.3   CRAN  [2]   indirect
    ## KernSmooth           2.23-22                           CRAN    2.23-22   CRAN  [2]   indirect
    ## MASS                  7.3-60                           CRAN     7.3-60   CRAN  [2]   indirect
    ## Matrix               1.6-1.1                           CRAN    1.6-1.1   CRAN  [2]   indirect
    ## R.cache               0.16.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## R.methodsS3            1.8.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## R.oo                  1.25.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## R.utils               2.12.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## R6                     2.5.1                           CRAN      2.5.1   CRAN  [2]   indirect
    ## RColorBrewer           1.1-3                           CRAN      1.1-3   CRAN  [2]   indirect
    ## Rcpp                  1.0.11                           CRAN     1.0.11   CRAN  [2]   indirect
    ## RcppArmadillo     0.12.4.1.0                           CRAN 0.12.4.1.0   CRAN  [1]   indirect
    ## RcppEigen          0.3.3.9.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## Rttf2pt1              1.3.12                           CRAN       <NA>   <NA>  [1]       <NA>
    ## V8                     4.3.3                           CRAN      4.3.3   CRAN  [1]   indirect
    ## XML                3.99-0.14                           CRAN       <NA>   <NA>  [2]       <NA>
    ## abind                  1.4-5                           CRAN      1.4-5   CRAN  [1]   indirect
    ## arrow               12.0.1.1                           CRAN   12.0.1.1   CRAN  [1]     direct
    ## askpass                1.2.0                           RSPM      1.2.0   RSPM  [2]   indirect
    ## assertthat             0.2.1                           CRAN      0.2.1   CRAN  [1]   indirect
    ## backports              1.4.1                           CRAN      1.4.1   CRAN  [1]   indirect
    ## badger                 0.2.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## base64enc              0.1-3                           CRAN      0.1-3   CRAN  [1]   indirect
    ## base64url                1.4                           CRAN        1.4   CRAN  [1]   indirect
    ## bayestestR            0.13.1                           CRAN     0.13.1   CRAN  [1]   indirect
    ## beeswarm               0.4.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## bigD                   0.2.0                           CRAN      0.2.0   CRAN  [1]   indirect
    ## bit                    4.0.5                           CRAN      4.0.5   CRAN  [1]   indirect
    ## bit64                  4.0.5                           CRAN      4.0.5   CRAN  [1]   indirect
    ## bitops                 1.0-7                           CRAN      1.0-7   CRAN  [1]   indirect
    ## blob                   1.2.4                           CRAN      1.2.4   CRAN  [2]   indirect
    ## bookdown                0.34                           CRAN       0.34   CRAN  [1]   indirect
    ## boot                1.3-28.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## brew                   1.0-8                           CRAN       <NA>   <NA>  [2]       <NA>
    ## brio                   1.1.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## broom                  1.0.5                           CRAN      1.0.5   CRAN  [1]   indirect
    ## broom.helpers         1.14.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## bslib                  0.5.0                           CRAN      0.5.0   CRAN  [1]   indirect
    ## cachem                 1.0.8                           CRAN      1.0.8   CRAN  [1]   indirect
    ## callr                  3.7.3                           CRAN      3.7.3   CRAN  [1]   indirect
    ## cellranger             1.1.0                           CRAN      1.1.0   CRAN  [1]   indirect
    ## checkmate              2.2.0                           CRAN      2.2.0   CRAN  [1]   indirect
    ## ckanr                  0.7.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## class                 7.3-22                           CRAN     7.3-22   CRAN  [2]   indirect
    ## classInt               0.4-9                           CRAN      0.4-9   CRAN  [1]   indirect
    ## cli                    3.6.1                           CRAN      3.6.1   CRAN  [2]   indirect
    ## clipr                  0.8.0                           CRAN      0.8.0   CRAN  [2]   indirect
    ## cluster                2.1.4                           CRAN       <NA>   <NA>  [2]       <NA>
    ## codetools             0.2-19                           CRAN     0.2-19   CRAN  [2]   indirect
    ## collections            0.3.7                           CRAN       <NA>   <NA>  [2]       <NA>
    ## colorspace             2.1-0                           CRAN      2.1-0   CRAN  [2]     direct
    ## cols4all               0.6-1  https://r-tmap.r-universe.dev       <NA>   <NA>  [2]       <NA>
    ## commonmark             1.9.0                           CRAN      1.9.0   CRAN  [1]   indirect
    ## conflicted             1.2.0                           CRAN      1.2.0   CRAN  [1]   indirect
    ## cowplot                1.1.1                           CRAN      1.1.1   CRAN  [1]   indirect
    ## cpp11                  0.4.6                           CRAN      0.4.6   CRAN  [2]   indirect
    ## crayon                 1.5.2                           CRAN      1.5.2   CRAN  [2]   indirect
    ## credentials            2.0.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## crosstalk              1.2.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## crul                   1.4.0                           CRAN      1.4.0   CRAN  [2]   indirect
    ## curl                   5.0.2                           CRAN      5.0.2   CRAN  [2]   indirect
    ## cyclocomp              1.1.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## data.table            1.14.8                           CRAN     1.14.8   CRAN  [1]   indirect
    ## dataRetrieval         2.7.13                           CRAN     2.7.13   CRAN  [1]     direct
    ## datawizard             0.8.0                           CRAN      0.8.0   CRAN  [1]   indirect
    ## dbplyr                 2.3.4                           RSPM      2.3.4   RSPM  [2]   indirect
    ## desc                   1.4.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## dichromat            2.0-0.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## digest                0.6.33                           CRAN     0.6.33   CRAN  [1]   indirect
    ## distributional         0.3.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## dlstats                0.1.7                           CRAN       <NA>   <NA>  [2]       <NA>
    ## downlit                0.4.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## dplR                   1.7.5                           CRAN       <NA>   <NA>  [2]       <NA>
    ## dplyr                  1.1.3                           RSPM      1.1.3   RSPM  [2]     direct
    ## dtplyr                 1.3.1                           CRAN      1.3.1   CRAN  [1]   indirect
    ## e1071                 1.7-13                           CRAN     1.7-13   CRAN  [1]   indirect
    ## ellipsis               0.3.2                           CRAN      0.3.2   CRAN  [1]   indirect
    ## evaluate                0.21                           CRAN       0.21   CRAN  [1]   indirect
    ## extrafont               0.19                           CRAN       <NA>   <NA>  [1]       <NA>
    ## extrafontdb              1.0                           CRAN       <NA>   <NA>  [1]       <NA>
    ## fansi                  1.0.4                           CRAN      1.0.4   CRAN  [2]   indirect
    ## farver                 2.1.1                           CRAN      2.1.1   CRAN  [2]   indirect
    ## fastmap                1.1.1                           CRAN      1.1.1   CRAN  [1]   indirect
    ## flextable              0.9.3                           CRAN      0.9.3   CRAN  [2]     direct
    ## fontBitstreamVera      0.1.1                           CRAN      0.1.1   CRAN  [1]   indirect
    ## fontLiberation         0.1.0                           CRAN      0.1.0   CRAN  [1]   indirect
    ## fontawesome            0.5.1                           CRAN      0.5.1   CRAN  [1]   indirect
    ## fontquiver             0.2.1                           CRAN      0.2.1   CRAN  [1]   indirect
    ## forcats                1.0.0                           CRAN      1.0.0   CRAN  [1]     direct
    ## foreign               0.8-85                           CRAN       <NA>   <NA>  [2]       <NA>
    ## fs                     1.6.3                           CRAN      1.6.3   CRAN  [2]     direct
    ## gargle                 1.5.2                           CRAN      1.5.2   CRAN  [1]   indirect
    ## gdtools                0.3.3                           CRAN      0.3.3   CRAN  [1]   indirect
    ## generics               0.1.3                           CRAN      0.1.3   CRAN  [2]   indirect
    ## geojsonsf              2.0.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## geometries             0.2.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## gert                   2.0.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## gfonts                 0.2.0                           CRAN      0.2.0   CRAN  [1]   indirect
    ## ggbeeswarm             0.7.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## ggdist                 3.3.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## ggeffects              1.3.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## ggforce                0.4.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## ggplot2                3.4.3                           CRAN      3.4.3   CRAN  [2]   indirect
    ## ggrepel                0.9.3                           CRAN      0.9.3   CRAN  [1]     direct
    ## ggridges               0.5.4                           CRAN      0.5.4   CRAN  [1]     direct
    ## ggspatial              1.1.8                           CRAN      1.1.8   CRAN  [1]     direct
    ## ggtext                 0.1.2                           CRAN      0.1.2   CRAN  [1]     direct
    ## gh                     1.4.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## gitcreds               0.1.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## glue                   1.6.2                           CRAN      1.6.2   CRAN  [2]     direct
    ## googledrive            2.1.1                           CRAN      2.1.1   CRAN  [1]   indirect
    ## googlesheets4          1.1.1                           CRAN      1.1.1   CRAN  [1]   indirect
    ## grDevices               <NA>                           <NA>       <NA>   <NA>  [2]   indirect
    ## graphics                <NA>                           <NA>       <NA>   <NA>  [2]   indirect
    ## gratia                 0.8.1                           CRAN      0.8.1   CRAN  [1]     direct
    ## grid                    <NA>                           <NA>       <NA>   <NA>  [2]     direct
    ## gridExtra                2.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## gridtext               0.1.5                           CRAN      0.1.5   CRAN  [1]   indirect
    ## gt                     0.9.0                           CRAN      0.9.0   CRAN  [1]     direct
    ## gtable                 0.3.4                           CRAN      0.3.4   CRAN  [2]   indirect
    ## gtsummary              1.7.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## haven                  2.5.3                           CRAN      2.5.3   CRAN  [1]   indirect
    ## highr                   0.10                           CRAN       0.10   CRAN  [1]   indirect
    ## hms                    1.1.3                           CRAN      1.1.3   CRAN  [1]   indirect
    ## htmltools              0.5.5                           CRAN      0.5.5   CRAN  [1]   indirect
    ## htmlwidgets            1.6.2                           CRAN      1.6.2   CRAN  [1]   indirect
    ## httpcode               0.3.0                           CRAN      0.3.0   CRAN  [2]   indirect
    ## httpgd                 1.3.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## httpuv                1.6.11                           CRAN     1.6.11   CRAN  [1]   indirect
    ## httr                   1.4.6                           CRAN      1.4.6   CRAN  [1]   indirect
    ## httr2                  0.2.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## ids                    1.0.1                           CRAN      1.0.1   CRAN  [1]   indirect
    ## igraph               1.5.0.1                           CRAN    1.5.0.1   CRAN  [1]   indirect
    ## ini                    0.3.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## insight               0.19.3                           CRAN     0.19.3   CRAN  [1]   indirect
    ## isoband                0.2.7                           CRAN      0.2.7   CRAN  [2]   indirect
    ## janitor                2.2.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## jpeg                  0.1-10                           CRAN     0.1-10   CRAN  [1]   indirect
    ## jquerylib              0.1.4                           CRAN      0.1.4   CRAN  [1]   indirect
    ## jsonify                1.2.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## jsonlite               1.8.7                           CRAN      1.8.7   CRAN  [2]   indirect
    ## juicyjuice             0.1.0                           CRAN      0.1.0   CRAN  [1]   indirect
    ## kableExtra             1.3.4                           CRAN      1.3.4   CRAN  [1]     direct
    ## knitr                   1.43                           CRAN       1.43   CRAN  [1]     direct
    ## komaletter             0.5.0                           CRAN      0.5.0   CRAN  [1]     direct
    ## labeling               0.4.3                           CRAN      0.4.3   CRAN  [2]   indirect
    ## labelled              2.12.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## languageserver        0.3.16                           CRAN       <NA>   <NA>  [2]       <NA>
    ## later                  1.3.1                           CRAN      1.3.1   CRAN  [1]   indirect
    ## latexdiffr        0.1.0.9000                         GitHub 0.1.0.9000 GitHub  [1]     direct
    ## lattice               0.21-8                           CRAN     0.21-8   CRAN  [2]   indirect
    ## lazyeval               0.2.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## ldc                    0.1.0   https://txwri.r-universe.dev       <NA>   <NA>  [2]       <NA>
    ## leafem                 0.2.3                           RSPM       <NA>   <NA>  [2]       <NA>
    ## leafgl                 0.1.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## leaflegend             1.1.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## leaflet                2.2.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## leaflet.providers     1.13.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## leafsync               0.1.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## lifecycle              1.0.3                           CRAN      1.0.3   CRAN  [2]   indirect
    ## lintr                  3.1.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## lubridate              1.9.2                           CRAN      1.9.2   CRAN  [1]     direct
    ## lwgeom                0.2-13                           CRAN       <NA>   <NA>  [2]       <NA>
    ## magick                 2.7.5                           CRAN      2.7.5   CRAN  [1]     direct
    ## magrittr               2.0.3                           CRAN      2.0.3   CRAN  [2]   indirect
    ## maptiles               0.6.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## markdown                 1.7                           CRAN        1.7   CRAN  [1]   indirect
    ## matrixStats            1.0.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## memoise                2.0.1                           CRAN      2.0.1   CRAN  [1]   indirect
    ## methods                 <NA>                           <NA>       <NA>   <NA>  [2]   indirect
    ## mgcv                   1.9-0                           CRAN      1.9-0   CRAN  [2]     direct
    ## mime                    0.12                           CRAN       0.12   CRAN  [2]   indirect
    ## modelr                0.1.11                           CRAN     0.1.11   CRAN  [1]   indirect
    ## modelsummary           1.4.1                           CRAN      1.4.1   CRAN  [1]     direct
    ## mpsTemplates           0.2.0 https://mps9506.r-universe.dev       <NA>   <NA>  [2]       <NA>
    ## munsell                0.5.0                           CRAN      0.5.0   CRAN  [2]   indirect
    ## mvnfast                0.2.8                           CRAN      0.2.8   CRAN  [1]   indirect
    ## nlme                 3.1-163                           CRAN    3.1-163   CRAN  [2]   indirect
    ## nnet                  7.3-19                           CRAN       <NA>   <NA>  [2]       <NA>
    ## numDeriv          2016.8-1.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## officedown             0.3.0                           CRAN      0.3.0   CRAN  [1]   indirect
    ## officer                0.6.2                           CRAN      0.6.2   CRAN  [1]   indirect
    ## openssl                2.1.1                           RSPM      2.1.1   RSPM  [2]   indirect
    ## packrat                0.9.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## palmerpenguins         0.1.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## parameters            0.21.1                           CRAN     0.21.1   CRAN  [1]   indirect
    ## patchwork              1.1.2                           CRAN      1.1.2   CRAN  [1]     direct
    ## performance           0.10.4                           CRAN     0.10.4   CRAN  [1]   indirect
    ## pillar                 1.9.0                           CRAN      1.9.0   CRAN  [2]   indirect
    ## pkgbuild               1.4.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## pkgconfig              2.0.3                           CRAN      2.0.3   CRAN  [2]   indirect
    ## pkgload                1.3.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## plyr                   1.8.8                           CRAN      1.8.8   CRAN  [1]   indirect
    ## png                    0.1-8                           CRAN      0.1-8   CRAN  [1]   indirect
    ## polyclip              1.10-6                           CRAN       <NA>   <NA>  [2]       <NA>
    ## pracma                 2.4.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## prettymapr             0.2.4                           CRAN      0.2.4   CRAN  [1]   indirect
    ## prettyunits            1.1.1                           CRAN      1.1.1   CRAN  [1]   indirect
    ## processx               3.8.2                           CRAN      3.8.2   CRAN  [1]   indirect
    ## progress               1.2.2                           CRAN      1.2.2   CRAN  [1]   indirect
    ## promises             1.2.0.1                           CRAN    1.2.0.1   CRAN  [1]   indirect
    ## proxy                 0.4-27                           CRAN     0.4-27   CRAN  [1]   indirect
    ## ps                     1.7.5                           CRAN      1.7.5   CRAN  [1]   indirect
    ## purrr                  1.0.2                           CRAN      1.0.2   CRAN  [2]   indirect
    ## quadprog               1.5-8                           CRAN       <NA>   <NA>  [2]       <NA>
    ## quarto                   1.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## ragg                   1.2.5                           CRAN      1.2.5   CRAN  [1]     direct
    ## rapidjsonr             1.2.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## rappdirs               0.3.3                           CRAN      0.3.3   CRAN  [2]   indirect
    ## raster                3.6-23                           CRAN       <NA>   <NA>  [2]       <NA>
    ## rcartocolor            2.1.1                           CRAN      2.1.1   CRAN  [1]     direct
    ## reactR                 0.4.4                           CRAN      0.4.4   CRAN  [1]   indirect
    ## reactable              0.4.4                           CRAN      0.4.4   CRAN  [1]   indirect
    ## readr                  2.1.4                           CRAN      2.1.4   CRAN  [1]   indirect
    ## readxl                 1.4.3                           CRAN      1.4.3   CRAN  [1]   indirect
    ## rematch                1.0.1                           CRAN      1.0.1   CRAN  [1]   indirect
    ## rematch2               2.1.2                           CRAN      2.1.2   CRAN  [1]   indirect
    ## remotes              2.4.2.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## renv                  0.15.5                           CRAN     0.15.5   CRAN  [1]     direct
    ## reprex                 2.0.2                           CRAN      2.0.2   CRAN  [1]   indirect
    ## rex                    1.2.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## rgdal                  1.6-7                           CRAN      1.6-7   CRAN  [1]   indirect
    ## rjson                 0.2.21                           CRAN     0.2.21   CRAN  [1]   indirect
    ## rlang                  1.1.1                           CRAN      1.1.1   CRAN  [2]   indirect
    ## rmarkdown               2.23                           CRAN       2.23   CRAN  [1]     direct
    ## rosm                   0.2.6                           CRAN      0.2.6   CRAN  [1]   indirect
    ## roxygen2               7.2.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## rpart                 4.1.19                           CRAN       <NA>   <NA>  [2]       <NA>
    ## rprojroot              2.0.3                           CRAN      2.0.3   CRAN  [2]   indirect
    ## rsconnect              1.1.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## rstudioapi            0.15.0                           CRAN     0.15.0   CRAN  [2]   indirect
    ## rticles                 0.25                           CRAN       0.25   CRAN  [1]     direct
    ## rvcheck                0.2.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## rvest                  1.0.3                           CRAN      1.0.3   CRAN  [1]   indirect
    ## rvg                    0.3.3                           CRAN      0.3.3   CRAN  [1]   indirect
    ## s2                     1.1.4                           CRAN      1.1.4   CRAN  [1]   indirect
    ## sass                   0.4.7                           CRAN      0.4.7   CRAN  [1]   indirect
    ## scales                 1.2.1                           CRAN      1.2.1   CRAN  [2]     direct
    ## scico                  1.4.0                           CRAN      1.4.0   CRAN  [1]     direct
    ## selectr                0.4-2                           CRAN      0.4-2   CRAN  [1]   indirect
    ## sf                    1.0-14                           CRAN     1.0-14   CRAN  [1]     direct
    ## sfheaders              0.4.3                           CRAN       <NA>   <NA>  [2]       <NA>
    ## shiny                1.7.4.1                           CRAN    1.7.4.1   CRAN  [1]   indirect
    ## signal                 0.7-7                           CRAN       <NA>   <NA>  [2]       <NA>
    ## slippymath             0.3.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## snakecase             0.11.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## sourcetools          0.1.7-1                           CRAN    0.1.7-1   CRAN  [1]   indirect
    ## sp                     2.0-0                           CRAN      2.0-0   CRAN  [1]   indirect
    ## spatial               7.3-17                           CRAN       <NA>   <NA>  [2]       <NA>
    ## splines                 <NA>                           <NA>       <NA>   <NA>  [2]   indirect
    ## stars                  0.6-4                           CRAN       <NA>   <NA>  [2]       <NA>
    ## stats                   <NA>                           <NA>       <NA>   <NA>  [2]   indirect
    ## stringdist            0.9.10                           CRAN       <NA>   <NA>  [2]       <NA>
    ## stringi               1.7.12                           CRAN     1.7.12   CRAN  [2]   indirect
    ## stringr                1.5.0                           CRAN      1.5.0   CRAN  [2]     direct
    ## styler                1.10.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## survival               3.5-7                           CRAN       <NA>   <NA>  [2]       <NA>
    ## svglite                2.1.1                           CRAN      2.1.1   CRAN  [1]   indirect
    ## sys                    3.4.2                           CRAN      3.4.2   CRAN  [2]   indirect
    ## systemfonts            1.0.4                           CRAN      1.0.4   CRAN  [1]   indirect
    ## tables                0.9.17                           CRAN     0.9.17   CRAN  [1]   indirect
    ## targets                1.2.0                           CRAN      1.2.0   CRAN  [1]     direct
    ## terra                 1.7-46                           CRAN       <NA>   <NA>  [2]       <NA>
    ## textshaping            0.3.6                           CRAN      0.3.6   CRAN  [1]   indirect
    ## tibble                 3.2.1                           CRAN      3.2.1   CRAN  [2]   indirect
    ## tidyr                  1.3.0                           CRAN      1.3.0   CRAN  [2]     direct
    ## tidyselect             1.2.0                           CRAN      1.2.0   CRAN  [2]   indirect
    ## tidyterra              0.4.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## tidyverse              2.0.0                           CRAN      2.0.0   CRAN  [1]     direct
    ## tigris                 2.0.4                           CRAN       <NA>   <NA>  [2]       <NA>
    ## timechange             0.2.0                           CRAN      0.2.0   CRAN  [1]   indirect
    ## tinytex                 0.46                           CRAN       0.46   CRAN  [2]   indirect
    ## tmap               3.99.9000  https://r-tmap.r-universe.dev       <NA>   <NA>  [2]       <NA>
    ## tmaptools              3.1-1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## tools                   <NA>                           <NA>       <NA>   <NA>  [2]   indirect
    ## triebeard              0.4.1                           CRAN      0.4.1   CRAN  [2]   indirect
    ## tweenr                 2.0.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## twriTemplates          0.2.3                         GitHub      0.2.3 GitHub  [1]     direct
    ## tzdb                   0.4.0                           CRAN      0.4.0   CRAN  [1]   indirect
    ## units                  0.8-2                           CRAN      0.8-2   CRAN  [1]     direct
    ## urltools               1.7.3                           CRAN      1.7.3   CRAN  [2]   indirect
    ## usethis                2.2.2                           CRAN       <NA>   <NA>  [2]       <NA>
    ## utf8                   1.2.3                           CRAN      1.2.3   CRAN  [2]   indirect
    ## utils                   <NA>                           <NA>       <NA>   <NA>  [2]   indirect
    ## uuid                   1.1-0                           CRAN      1.1-0   CRAN  [1]   indirect
    ## vctrs                  0.6.3                           CRAN      0.6.3   CRAN  [2]   indirect
    ## vipor                  0.4.5                           CRAN       <NA>   <NA>  [2]       <NA>
    ## viridis                0.6.4                           CRAN       <NA>   <NA>  [2]       <NA>
    ## viridisLite            0.4.2                           CRAN      0.4.2   CRAN  [2]   indirect
    ## vroom                  1.6.3                           CRAN      1.6.3   CRAN  [1]   indirect
    ## webshot                0.5.5                           CRAN      0.5.5   CRAN  [1]   indirect
    ## whisker                0.4.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## widgetframe            0.3.1                           CRAN       <NA>   <NA>  [2]       <NA>
    ## withr                  2.5.1                           RSPM      2.5.1   RSPM  [2]   indirect
    ## wk                     0.7.3                           CRAN      0.7.3   CRAN  [1]   indirect
    ## xfun                    0.40                           CRAN       0.40   CRAN  [2]   indirect
    ## xml2                   1.3.5                           CRAN      1.3.5   CRAN  [1]   indirect
    ## xmlparsedata           1.0.5                           CRAN       <NA>   <NA>  [2]       <NA>
    ## xtable                 1.8-4                           CRAN      1.8-4   CRAN  [1]   indirect
    ## yaml                   2.3.7                           CRAN      2.3.7   CRAN  [2]   indirect
    ## yulab.utils            0.1.0                           CRAN       <NA>   <NA>  [2]       <NA>
    ## zip                    2.3.0                           CRAN      2.3.0   CRAN  [2]   indirect
    ## 
    ## [1]: C:/Data-Analysis-Projects/lavaca-nutrient-manuscript/renv/library/R-4.3/x86_64-w64-mingw32
    ## [2]: C:/Users/michael.schramm/AppData/Local/Programs/R/R-4.3.1/library                         
    ## 
    ## # ABI ================================
    ## * ABI conflict checks are not yet implemented on Windows.
    ## 
    ## # User Profile =======================
    ## [no user profile detected]
    ## 
    ## # Settings ===========================
    ## List of 10
    ##  $ bioconductor.version     : chr(0) 
    ##  $ external.libraries       : chr(0) 
    ##  $ ignored.packages         : chr(0) 
    ##  $ package.dependency.fields: chr [1:3] "Imports" "Depends" "LinkingTo"
    ##  $ r.version                : chr(0) 
    ##  $ snapshot.type            : chr "implicit"
    ##  $ use.cache                : logi TRUE
    ##  $ vcs.ignore.cellar        : logi TRUE
    ##  $ vcs.ignore.library       : logi TRUE
    ##  $ vcs.ignore.local         : logi TRUE
    ## 
    ## # Options ============================
    ## List of 9
    ##  $ defaultPackages                     : chr [1:6] "datasets" "utils" "grDevices" "graphics" ...
    ##  $ download.file.method                : NULL
    ##  $ download.file.extra                 : NULL
    ##  $ install.packages.compile.from.source: chr "interactive"
    ##  $ pkgType                             : chr "both"
    ##  $ repos                               : Named chr "https://cran.rstudio.com"
    ##   ..- attr(*, "names")= chr "CRAN"
    ##  $ renv.consent                        : logi TRUE
    ##  $ renv.project.path                   : chr "C:/Data-Analysis-Projects/lavaca-nutrient-manuscript"
    ##  $ renv.verbose                        : logi TRUE
    ## 
    ## # Environment Variables ==============
    ## HOME                        = C:/Users/michael.schramm/Documents
    ## LANG                        = <NA>
    ## MAKE                        = <NA>
    ## R_LIBS                      = C:/Data-Analysis-Projects/lavaca-nutrient-manuscript/renv/library/R-4.3/x86_64-w64-mingw32;C:/Users/michael.schramm/AppData/Local/Programs/R/R-4.3.1/library
    ## R_LIBS_SITE                 = C:/Users/michael.schramm/AppData/Local/Programs/R/R-4.3.1/site-library
    ## R_LIBS_USER                 = C:/Data-Analysis-Projects/lavaca-nutrient-manuscript/renv/library/R-4.3/x86_64-w64-mingw32;C:/Users/michael.schramm/AppData/Local/Programs/R/R-4.3.1/library
    ## RENV_DEFAULT_R_ENVIRON      = <NA>
    ## RENV_DEFAULT_R_ENVIRON_USER = <NA>
    ## RENV_DEFAULT_R_LIBS         = <NA>
    ## RENV_DEFAULT_R_LIBS_SITE    = C:/Users/michael.schramm/AppData/Local/Programs/R/R-4.3.1/site-library
    ## RENV_DEFAULT_R_LIBS_USER    = C:\Users\michael.schramm\AppData\Local/R/win-library/4.3
    ## RENV_DEFAULT_R_PROFILE      = <NA>
    ## RENV_DEFAULT_R_PROFILE_USER = <NA>
    ## RENV_PROJECT                = C:/Data-Analysis-Projects/lavaca-nutrient-manuscript
    ## 
    ## # PATH ===============================
    ## - C:\rtools43/x86_64-w64-mingw32.static.posix/bin
    ## - C:\rtools43/usr/bin
    ## - C:\rtools43\x86_64-w64-mingw32.static.posix\bin
    ## - C:\rtools43\usr\bin
    ## - C:\Users\michael.schramm\AppData\Local\Programs\R\R-4.3.1\bin\x64
    ## - C:\Windows\system32
    ## - C:\Windows
    ## - C:\Windows\System32\Wbem
    ## - C:\Windows\System32\WindowsPowerShell\v1.0\
    ## - C:\Windows\System32\OpenSSH\
    ## - C:\Program Files\dotnet\
    ## - C:\Users\michael.schramm\AppData\Local\Programs\Quarto\bin
    ## - C:\Users\michael.schramm\AppData\Local\Microsoft\WindowsApps
    ## - C:\Users\michael.schramm\AppData\Local\Programs\Git\cmd
    ## - C:\Users\michael.schramm\AppData\Roaming\TinyTeX\bin\windows
    ## - C:\MyPerl\c\bin
    ## - C:\MyPerl\perl\site\bin
    ## - C:\MyPerl\perl\bin
    ## - C:\Program Files\RStudio\resources\app\bin\quarto\bin\tools
    ## - C:\Users\michael.schramm\AppData\Local\Programs\Microsoft VS Code\bin
    ## - C:\Users\michael.schramm\AppData\Local\Programs\R\R-4.3.1
    ## - C:\Users\michael.schramm\AppData\Local\Programs\Quarto\bin
    ## - C:\Program Files\RStudio\resources\app\bin\postback
    ## 
    ## # Cache ==============================
    ## There are a total of 659 package(s) installed in the renv cache.
    ## Cache path: "C:/Users/michael.schramm/AppData/Local/R/cache/R/renv/cache/v5/R-4.3/x86_64-w64-mingw32"
