FROM --platform=linux/amd64 rocker/tidyverse:latest
WORKDIR /srv/www
COPY . .
CMD ["Rscript", "rserve.R"]
EXPOSE 8080
