FROM --platform=linux/amd64 rocker/tidyverse:latest
WORKDIR /srv/www
COPY . ./server
RUN apt-get -y update && \
    apt-get install -y  libudunits2-dev libgdal-dev libgeos-dev libproj-dev
CMD ["Rscript", "server/rserve.R"]
EXPOSE 8080
