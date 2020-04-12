const express = require('express');
const router = express.Router();

const Student = require('../models/student');

const accessDenied = 'Недостаточно прав!';

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

router.post('/', (req, res) => {
	const debug = req.user;
	if ( !Student.isOwner(req.user, req.method, req.params) ) return res.status(403).json({ message: accessDenied, debug: debug });
	
	const data = req.body;
	const student = new Student(data);
	student.save((err) => {
		if(err) {
			res.json({ message: 'Аккаунт с данным email уже существует' });
			// убрать логи
			return console.error(err);
		};
		res.status(200).send({ message: 'Студент успешно создан!' });
	});
	

});

router.put('/:id', (req, res) => {
	const debug = req.user;
	if ( !Student.isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: accessDenied, debug: debug });

	const student = new Student(req.body);
	
	student.id = +req.params.id;
	
	student.save((err) => {
		if(err) {
			res.json({ message: 'Что-то пошло не так' });
			// убрать логи
			return console.error(err);
		};
		res.status(200).send({ message: 'Student успешно обновлен!' });
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