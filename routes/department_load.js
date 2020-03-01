const express = require('express');
const router = express.Router();

const connection = require('../db');

router.get('/', (req, res) => {
	connection.any(`SELECT * FROM disciplines_year;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.log(err));
});

router.get('/:id', (req, res) => {
	connection.any(`SELECT * FROM disciplines_year WHERE id_department = $1 ORDER BY title;`, [req.params.id])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

module.exports = router;