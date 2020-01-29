const pgp = require('pg-promise')();
const connectionString = require('./config').connectionString;
const connection = pgp(connectionString);

connection.connect()
	.then(obj => obj.done())
	.catch(err => console.error(err));

module.exports = connection;