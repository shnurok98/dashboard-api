const express = require('express');
const router = express.Router();

const connection = require('../db');

router.get('/:table_name', (req, res) => {
	connection.any('SELECT * FROM ' + req.params.table_name + ' ORDER BY id DESC')
	.then(rows => {

		res.send(rows);
	})
	.catch(err => {
		// console.error(err);
		res.status(500).json(err);
	});
});

module.exports = router;