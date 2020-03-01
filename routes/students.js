const express = require('express');
const router = express.Router();

const Student = require('../models/student');

router.get('/:id', (req, res) => {
	Student.get(req.params.id, (err, student) => {
		if (err) console.error(err);
		if (student) {
			res.status(200).json(student);
		}else{
			res.status(200).json({ message: 'Такого студента нету' });
		}
	});
});

router.get('/group/:group_id', (req, res) => {
	Student.getByGroup(req.params.group_id, (err, students) => {
		if (err) console.error(err);
		// Потому что это массив
		if (students.length) {
			res.status(200).json(students);
		}else{
			res.status(200).json({ message: 'Такой группы нету, либо в ней нету студентов' });
		}
	});
});

router.get('/specialty/:specialty_id', (req, res) => {
	Student.getBySpecialty(req.params.specialty_id, (err, students) => {
		if (err) console.error(err);
		// Потому что это массив
		if (students.length) {
			res.status(200).json(students);
		}else{
			res.status(200).json({ message: 'Такой спец нету, либо в ней нету студентов' });
		}
	});
});

module.exports = router;