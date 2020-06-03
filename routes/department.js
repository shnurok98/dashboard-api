const express = require('express');
const router = express.Router();

const connection = require('../db');

const Access = require('../rights');
const message = require('../messages');

router.get('/', (req, res) => {
  connection.manyOrNone(`
  SELECT *
  FROM department
;`)
	.then(rows => {
		res.status(200).send(rows);
	})
	.catch(err => {
		res.status(500).json({ message: message.smthWentWrong, error: err });
	});
});

router.get('/:id', (req, res) => {
	connection.oneOrNone(`
    select * from department where id = $1;
  `, [+req.params.id])
	.then(rows => {
		if (!rows) return res.status(404).json({ message: message.notExist });
		res.status(200).send(rows);
	})
	.catch(err => {
		res.status(500).json({ message: message.smthWentWrong, error: err });
	});
});

router.post('/', async (req, res) => {
	try {
		const access = await Access(req.user, req.method, '/department');
		if ( !access ) return res.status(403).json({ message: message.accessDenied });

		connection.oneOrNone(`
			insert into department (name) values ($1) returning id;
		`, [req.body.name])
		.then(rows => {
			res.status(201).send(rows);
		})
		.catch(err => {
			res.status(400).json({message: message.badData, error: err});
		});
	} catch (e) {
    console.error(e);
  }
});

router.put('/:id', async (req, res) => {
	try {
		const access = await Access(req.user, req.method, '/department', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied });

		connection.oneOrNone(`
			update department set name = $1 where id = $2 returning *;
		`, [req.body.name, +req.params.id])
		.then(rows => {
			if (!rows) return res.status(404).json({ message: message.notExist });
			res.status(204).send(rows);
		})
		.catch(err => {
			res.status(500).json({ message: message.smthWentWrong, error: err });
		});
	} catch (e) {
    console.error(e);
  }
});

router.delete('/:id', async (req, res) => {
	try {
		const access = await Access(req.user, req.method, '/department', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied});

		connection.none(`
			delete from department where id = $1;
		`, [+req.params.id])
		.then( () => {
			res.status(204).json({message: message.deleteSuccess});
		})
		.catch(err => {
			res.status(500).json({ message: message.smthWentWrong, error: err });
		});
	} catch (e) {
    console.error(e);
  }
});

module.exports = router;