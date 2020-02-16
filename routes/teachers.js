const express = require('express');
const router = express.Router();

const connection = require('../db');

const Teacher = require('../models/teacher');

router.get('/', (req, res) => {
	// console.log(req.user);
	connection.any(`SELECT * FROM teachers;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

router.get('/:id', (req, res) => {
	Teacher.get(req.params.id, (err, teacher) => {
		if (err) console.error(err);
		if (teacher) {
			res.status(200).json(teacher);
		}else{
			res.status(200).json({ message: 'Такого преподавателя нету' });
		}
	});
});

module.exports = router;