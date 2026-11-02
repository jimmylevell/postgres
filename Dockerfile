###############################################################################################
###############################################################################################
# levell postgres - BASE
###############################################################################################
###############################################################################################
FROM postgres:14.7-bookworm as levell-postgres-base

RUN mkdir -p /docker

# The stock postgres:14.7 image on Bullseye includes an old pgdg apt source that
# no longer exposes a valid Release file. Remove it before refreshing package indexes.
RUN rm -f /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/pgdg.sources

# update the image
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim \
        net-tools \
        dos2unix \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

###############################################################################################
# levell postgres - PRODUCTION
###############################################################################################
FROM levell-postgres-base as levell-postgres-deploy

# Install citus
RUN apt-get -y install curl
RUN curl https://install.citusdata.com/community/deb.sh > add-citus-repo.sh
RUN bash add-citus-repo.sh
RUN apt-get -y install postgresql-13-citus-10.2

# enable citus
RUN echo "shared_preload_libraries='citus'" >> /usr/share/postgresql/13/postgresql.conf.sample

COPY docker/entrypoint_postgres.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/entrypoint_postgres.sh
RUN dos2unix /docker-entrypoint-initdb.d/entrypoint_postgres.sh

EXPOSE 5432

###############################################################################################
###############################################################################################
# levell pgadmin - BASE
###############################################################################################
###############################################################################################
FROM dpage/pgadmin4:9.17 as levell-pgadmin-base

USER root
RUN mkdir -p /docker

# update the image
RUN apk update
RUN apk add vim
RUN apk add net-tools
RUN apk add dos2unix

###############################################################################################
# levell pgadmin - PRODUCTION
###############################################################################################
FROM levell-pgadmin-base as levell-pgadmin-deploy

COPY docker/entrypoint_pgadmin.sh /docker/entrypoint.sh
COPY docker/set_env_secrets.sh /docker/

RUN chmod +x /docker/entrypoint.sh
RUN dos2unix /docker/entrypoint.sh

RUN chmod +x /docker/set_env_secrets.sh
RUN dos2unix /docker/set_env_secrets.sh

USER pgadmin

EXPOSE 80 443
ENTRYPOINT [ "/docker/entrypoint.sh" ]
