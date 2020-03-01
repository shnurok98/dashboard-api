const express = require('express');
const router = express.Router();

const connection = require('../db');

const Teacher = require('../models/teacher');

router.get('/', (req, res) => {
	// console.log(req.user);
	Teacher.getAll((err, teachers) => {
		if (err) console.error(err);
		if (teachers) {
			res.status(200).json(teachers);
		}else{
			res.status(200).json({ message: 'server: Teachers.getAll(err)' });
		}
	});
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