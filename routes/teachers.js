const express = require('express');
const router = express.Router();

const Teacher = require('../models/teacher');

const accessDenied = 'Недостаточно прав!';

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

router.post('/', (req, res) => {
	const debug = req.user;
	if ( !Teacher.isOwner(req.user, req.method, req.params) ) return res.status(403).json({ message: accessDenied, debug: debug });
	
	const data = req.body;
	Teacher.getByLogin(data.login, (err, user) => {
		if(err) return console.error(err);

		if (user) {
			res.send({ message: 'Пользователь с данным login уже существует' });
		}else{
			user = new Teacher(data);
			user.save((err) => {
				if(err) {
					res.json({ message: 'Пользователь с данными реквизитами уже существует' });
					// убрать логи
					return console.error(err);
				};
				res.status(200).send({ message: 'Пользователь успешно создан!' });
			});
		}
	});

});

router.put('/:id', (req, res) => {
	const debug = req.user;
	if ( !Teacher.isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: accessDenied, debug: debug });

	const teacher = new Teacher(req.body);
	
	teacher.id = +req.params.id;
	
	teacher.save((err) => {
		if(err) {
			res.json({ message: 'Что-то пошло не так' });
			// убрать логи
			return console.error(err);
		};
		res.status(200).send({ message: 'Пользователь успешно обновлен!' });
	});

});
module.exports = router;