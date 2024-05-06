FROM --platform=linux/amd64 rocker/tidyverse:latest
WORKDIR /srv/www
COPY . ./server
CMD ["Rscript", "server/rserve.R"]
EXPOSE 8080
