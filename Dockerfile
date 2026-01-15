FROM rocker/r-ver:4.3.2

# System deps commonly needed by Bioconductor + plotting
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgit2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libcairo2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# CRAN packages
RUN R -q -e "options(repos=c(CRAN='https://cloud.r-project.org')); \
    install.packages(c('vegan','ggplot2','dplyr','tidyr','tibble','UpSetR','remotes'));"

# Bioconductor packages (phyloseq)
RUN R -q -e "options(repos=c(CRAN='https://cloud.r-project.org')); \
    if (!requireNamespace('BiocManager', quietly=TRUE)) install.packages('BiocManager'); \
    BiocManager::install(version='3.18', ask=FALSE, update=FALSE); \
    BiocManager::install(c('phyloseq'), ask=FALSE, update=FALSE);"

WORKDIR /work

COPY trana_ecology.R /usr/local/bin/trana_ecology.R
RUN chmod +x /usr/local/bin/trana_ecology.R

ENTRYPOINT ["/usr/local/bin/trana_ecology.R"]
