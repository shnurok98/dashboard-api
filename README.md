# Dashboard API

Пример файла config.js:
```js
const config = {};

config.connectionString = {
	host: 'localhost',
	port: 5432,
	database: 'db',
	user: 'user',
	password: '12345'
};

config.port = 3000;
config.secret = 'secret';

module.exports = config;
```