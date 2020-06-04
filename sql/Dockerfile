FROM postgres:latest

COPY dump_s.sql /docker-entrypoint-initdb.d/

ENV POSTGRES_USER diplom_user
ENV POSTGRES_PASSWORD mospolytech
ENV POSTGRES_DB diplom_database

EXPOSE 5432