matR: metagenomics analysis tools for R

ABOUT
matR is an analysis client for MG-RAST (http://metagenomics.anl.gov) built as an extension package to the popular R programming language for statistics.  This package is in development.  Facilities are implemented to download annotation data from the MG-RAST metagenome analysis server.  Easy acccess to lightly structured metadata, authentication for access to private data, and customized versions of statistical and visualization tools are provided.

EXAMPLES, DOCUMENTATION, HELP
Docs and examples are directly available at http://mcs.anl.gov/~braithwaite.  In an R session with matR loaded, try:
> vignette("matR-user-manual")              # complete user manual (pdf)
> vignette("matR-quick-reference")          # summary of commands (pdf)
> vignette("matR-release-notes")            # latest updates (pdf)
> demo(package="matR")                      # list demos
> demo.step("analysis")                     # step through a demo
> data(package="matR")                      # list included datasets
> package?matR                              # integrated help homepage
> library(help="matR")                      # integrated help index
> ?collection                               # help with a particular function
> example("collection")                     # examples for a particular function

LOADING
During an R session, load matR with:
> library(matR)

INSTALLATION
Install matR within an R session:
> install.packages("matR", repo="http://mcs.anl.gov/~braithwaite/R", type="source")
> library(matR)
> dependencies()
Alternatively, download matR from GitHub (https://github.org/MG-RAST/matR).  Make sure to have a current version of the R language (http://www.r-project.org).
