Package: matR
Type: Package
Title: metagenomics analysis tools for R
Version: 1.0.0
Depends: R (>= 2.10), methods, utils
Imports: stats
Suggests: Matrix, RJSONIO, ecodist, gplots, scatterplot3d
URL: https://github.com/MG-RAST/matR/
Date: 2013-01-05
Author: Daniel T. Braithwaite and Kevin P. Keegan
Maintainer: Daniel T. Braithwaite <braithwaite@cels.anl.gov>
Authors@R: c (person ("Daniel", "Braithwaite", role = c ("aut", "cre"), email = "braithwaite@uchicago.edu"),
              person ("Kevin", "Keegan", role = "aut", email = "keegan@mcs.anl.gov"))
Description: matR is an analysis module, extending the MG-RAST metagenome annotation pipeline.  Customized versions of statistical and visualization tools access metagenome annotations and metadata transparently, with authentication for private data.  As an add-on package to the popular R programming language for statistics, matR enables analysis to use the complete functionality of that environment and its extensions.
License: file LICENSE
LazyLoad: yes
LazyData: yes
LazyDataCompression: xz
Collate: utils.R class-headers.R selections.R collections.R class-coercions.R analysis-utils.R analysis.R render.R init.R API-layer.R
