FROM node:12.18.1-alpine

# создание директории приложения
WORKDIR /usr/src/app

# ADD index.html /server/

# установка зависимостей
# символ астериск ("*") используется для того чтобы по возможности 
# скопировать оба файла: package.json и package-lock.json
COPY package*.json ./

RUN apk --no-cache add --virtual builds-deps build-base python

RUN npm install
# Если вы создаете сборку для продакшн
# RUN npm ci --only=production

# копируем исходный код
COPY . .

# говорим докеру, что приложение в контейнере слушает 3000 порт
EXPOSE 3000

# VOLUME /uploads

# CMD содерживт все необходимые переменные среды и инструкции для запуска приложения
CMD [ "node", "app.js" ]