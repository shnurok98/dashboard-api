# Docker

Проект разделен на 3 контейнера: БД, API и NGINX вместе с фронтендом.

## Требования

Установленный [Docker Engine](https://docs.docker.com/get-docker/) (или Docker client) и [Docker Compose](https://docs.docker.com/compose/install/).

## Инструкция для запуска
Для запуска через Docker надо сначала сделать билд двух образов:

0. В папке sql/: `sudo docker build -t shnurok/dash-db .`
0. В папке dashboard-api/: `sudo docker build -t shnurok/dash-api .`

После их создания нужно перенести default.conf и docker-compose.yml из папки /Docker на уровень выше папки /dashboard-api. Также, рядом c /dashboard-api должна быть папка /client с билдом фронтенда.

Далее выполнить в папке с файлом docker-compose.yml след команду: `sudo docker-compose up`

По адресу http://localhost доступен фронт. Все остальные части приложения соотв тоже работают.

Созданные папки pg_data и uploads предназначены для хранения данных БД и хранения файлов на сервере соответственно. (Потому что при перезапуске контейнеров все данные теряются. Поэтому необходимо монтировать для них внешний источник)