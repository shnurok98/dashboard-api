const express = require('express');
const router = express.Router();

const connection = require('../db');

router.get('/', (req, res) => {
	// console.log(req.user);
	connection.any(`SELECT * FROM teachers;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

module.exports = router;