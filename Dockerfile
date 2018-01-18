# To build:
# docker build -t httpuv-debug .

FROM wch1/r-debug

RUN apt-get install -y \
    netcat \
    apache2-utils

COPY test.R /

# BH is so slow to install that it can time out when installing as a
# dependency with other packages, so we'll install it manually.
RUN RD             -e "install.packages('BH')"
RUN RD             -e "devtools::install_github('rstudio/httpuv@background-thread')"

RUN RDvalgrind     -e "install.packages('BH')"
RUN RDvalgrind     -e "devtools::install_github('rstudio/httpuv@background-thread')"

RUN RDsan          -e "install.packages('BH')"
RUN RDsan          -e "devtools::install_github('rstudio/httpuv@background-thread')"

RUN RDassertthread -e "install.packages('BH')"
RUN RDassertthread -e "devtools::install_github('rstudio/httpuv@background-thread')"
