# To build:
# docker build -t httpuv-debug .

FROM wch1/r-debug

RUN apt-get install -y \
    netcat \
    apache2-utils

COPY test.R /

RUN RD             -e "devtools::install_github('rstudio/httpuv@background-thread')"
RUN RDvalgrind2    -e "devtools::install_github('rstudio/httpuv@background-thread')"
# RUN RDsan          -e "devtools::install_github('rstudio/httpuv@background-thread')"
RUN RDassertthread -e "devtools::install_github('rstudio/httpuv@background-thread')"
