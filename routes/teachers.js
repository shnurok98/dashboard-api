const express = require('express');
const router = express.Router();

const Teacher = require('../models/teacher');

const Access = require('../rights');
const message = require('../messages');

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
			res.status(200).json({ message: message.notExist });
		}
	});
});

router.post('/', async (req, res) => {
	try {
		const debug = req.user;
		const access = await Access(req.user, req.method, '/teachers');
		if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });
		
		const data = req.body;
		Teacher.getByLogin(data.login, (err, user) => {
			if(err) return console.error(err);

			if (user) {
				res.send({ message: message.loginExist });
			}else{
				user = new Teacher(data);
				user.save((err) => {
					if(err) {
						res.json({ message: message.emailExist, error: err.detail });
						// убрать логи
						return console.error(err);
					};
					res.status(200).send({ message: message.createSuccess });
				});
			}
		});
	} catch (e) {
    console.error(e);
  }
});

router.put('/:id', async (req, res) => {
	try {
		const debug = req.user;
		const access = await Access(req.user, req.method, '/teachers', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

		const teacher = new Teacher(req.body);
		
		teacher.id = +req.params.id;
		
		teacher.save((err) => {
			if(err) {
				res.json({ message: 'Что-то пошло не так', error: err.detail });
				// убрать логи
				return console.error(err);
			};
			res.status(200).send({ message: message.updateSuccess });
		});
	} catch (e) {
    console.error(e);
  }
});

router.put('/:id/password', async (req, res) => {
	try {
		const debug = req.user;
		const access = await Access(req.user, req.method, '/teachers', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

		Teacher.get(+req.params.id, (err, teacher) => {
			if (err) console.error(err);
			if (teacher) {
				teacher.updatePass(req.body.password, (err) => {
					if(err) {
						res.json({ message: 'Что-то пошло не так', error: err.detail });
						// убрать логи
						return console.error(err);
					};
					res.status(200).json({ message: message.passwordSuccess });
				})
				
			}else{
				res.status(200).json({ message: message.notExist });
			}
		});
	} catch (e) {
    console.error(e);
  }
});

module.exports = router;