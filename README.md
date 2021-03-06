# Dashboard API

Данный программный продукт разработан для упрощения взаимодействия руководителя образовательной программы с информацией, необходимой для учебного процесса. Преподаватели тоже имеют доступ к системе. Они могут загружать документы учебного плана в систему и видеть закрепленные за ними дисциплины и проекты.

Система «Аналитическая панель руководителя образовательной программы» разделена на клиентскую и серверную часть. Данная работа посвящена созданию серверной части, которая включает в себя:
*	базу данных, созданную с помощью PostgreSQL - объектно-реляционной системы управления базами данных на языке SQL;
*	REST API (Representational State Transfer Application Programming Interface), созданную на языке JavaScript с помощью библиотеки express.js на платформе Node.js, для организации взаимодействия клиентской части c базой данных посредством HTTP запросов.

Для развертывания системы можно использовать готовые образы Docker доступные на DockerHub, либо настроить все вручную.

>Клиентская часть была разработана [Игорем Степаненко](https://github.com/Pailon) в рамках данной дипломной работы.

## Ссылки

* [Рабочее API и документация](http://dashboard.kholodov.xyz/api/)
* [Репозиторий на github](https://github.com/shnurok98/dashboard-api)
* [Контейнеры на DockerHub](https://hub.docker.com/u/shnurok)
* [Видео защиты проекта](https://youtu.be/-Ve0hGcb5U4)
***
* [Клиентская часть](http://dashboard.kholodov.xyz/)
* [Репозиторий клиентской части](https://github.com/Pailon/dash)

## Доступ к демоверсии
http://dashboard.kholodov.xyz/

Пользователь: view

Пароль: root

Данный пользователь имеет ограничения на действия в системе. Такие же данные используются для доступа к API. Взаимодействие с API подробно описано в генерируемой с помощью Insomnia [документации](http://dashboard.kholodov.xyz/api/).

## Настройка и запуск 

Разработанное программное обеспечение можно развернуть несколькими способами. Полностью настроить сервер и запустить приложение с помощью [pm2](https://github.com/Unitech/pm2) или развернуть контейнер [Docker](https://www.docker.com/). Для первого способа необходимы специальные навыки, тогда как для второго достаточно установить Docker Engine на сервер и запустить подготовленные контейнеры одной командой.

### Требования

**Для запуска из исходников:** 

Node.js v12, PostgreSQL v9.6 или выше.

**Для запуска с помощью Docker:**

Установленный [Docker Engine](https://docs.docker.com/get-docker/) (или Docker client для Windows) и [Docker Compose](https://docs.docker.com/compose/install/).

### Запуск с помощью Docker

Проект разделен на 3 контейнера: БД, API и NGINX вместе с фронтендом.

Проект имеет 3 настроенных образа для работы всей системы: nginx (вместе с фронтендом), postgres, node.js. Данный способ требует от пользователя открыть необходимый порт на сервере (80 порт), установить Docker Engine и Docker Compose.

Для запуска через Docker нужно перенести default.conf и docker-compose.yml из папки */Docker* на уровень выше папки */dashboard-api*. Также, рядом c /dashboard-api должна быть папка */client* с собранным фронтендом.
Далее выполнить в папке с файлом docker-compose.yml следующую команду: `sudo docker-compose up`. Она запустит все необходимые контейнеры.

После этого будут доступны nginx, postgres и node.js. По адресу http://localhost и http://localhost/api будут доступны фронтенд и API. Все остальные части приложения соответственно тоже работают локально.

Автоматически созданные папки pg_data и uploads предназначены для хранения данных БД и хранения файлов на сервере соответственно. (Потому что при перезапуске контейнеров все данные теряются. Поэтому необходимо монтировать для них внешний источник).

### Запуск из исходников

Надо войти в интерфейс командной строки PostgreSQL с помощью команды `psql –U postgres –h localhost`. Необходимо создать пользователя и базу данных для аналитической панели.
```sql
CREATE USER diplom_user WITH PASSWORD '12345';
CREATE DATABASE diplom_database OWNER diplom_user;
```
Для выхода из командного интерфейса psql введите команду \q.

Перейдите в папку */sql* в проекте и выполните в консоли: `psql –d diplom_database –U diplom_user –h localhost < dump.sql`

Для размещения файлов нужно создать папку */uploads* в корне системы от того пользователя, от которого будет запущено приложение node.

Для подключения к БД приложению node.js необходим *config.js* в корне проекта:
```js
const config = {};

config.connectionString = {
	host: process.env.POSTGRES_HOST || 'localhost',
	port: 5432,
	database: 'db',
	user: 'diplom_user',
	password: '12345'
};

config.port = 3000;
config.secret = 'secret';
config.api = {
	prefix: '/api'
}

module.exports = config;
```

Перейдите в папку проекта и поочередно выполните: 
```bash
npm install
npm start
```

После этого API будет запущено на http://localhost/api:3000