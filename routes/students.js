const express = require('express');
const router = express.Router();

const Student = require('../models/student');

const Access = require('../rights');
const message = require('../messages');

router.get('/:id', (req, res) => {
	Student.get(req.params.id, (err, student) => {
		if (err) console.error(err);
		if (student) {
			res.status(200).json(student);
		}else{
			res.status(200).json({ message: message.notExist });
		}
	});
});

router.post('/', async (req, res) => {
	try {
		const access = await Access(req.user, req.method, '/students');
		if ( !access ) return res.status(403).json({ message: message.accessDenied });
		
		const data = req.body;
		const student = new Student(data);
		student.save((err) => {
			if(err) {
				res.json({ message: message.emailExist });
				return ;
			};
			res.status(201).send({ message: message.createSuccess });
		});
	} catch (e) {
    console.error(e);
  }

});

router.put('/:id', async (req, res) => {
	try {
		const access = await Access(req.user, req.method, '/students', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied });

		const student = new Student(req.body);
		
		student.id = +req.params.id;
		
		student.save((err) => {
			if(err) {
				res.json({ message: message.smthWentWrong, error: err.detail });
				return ;
			};
			res.status(200).send({ message: message.updateSuccess });
		});
	} catch (e) {
    console.error(e);
  }
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