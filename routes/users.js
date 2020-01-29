const express = require('express');
const router = express.Router();

const connection = require('../db');

router.get('/', (req, res) => {
	connection.any(`SELECT * FROM personalities;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

module.exports = router;