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
		res.send(rows);
	})
	.catch(err => console.log(err));
});

router.get('/:id', (req, res) => {
	connection.oneOrNone(`
    select * from department where id = $1;
  `, [+req.params.id])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

router.post('/', async (req, res) => {
	try {
		const debug = req.user;
		const access = await Access(req.user, req.method, '/department');
		if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

		connection.oneOrNone(`
			insert into department (name) values ($1) returning id;
		`, [req.body.name])
		.then(rows => {
			res.send(rows);
		})
		.catch(err => {
			res.json({message: message.exist});
		});
	} catch (e) {
    console.error(e);
  }
});

router.put('/:id', async (req, res) => {
	try {
		const debug = req.user;
		const access = await Access(req.user, req.method, '/department', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

		connection.oneOrNone(`
			update department set name = $1 where id = $2 returning *;
		`, [req.body.name, +req.params.id])
		.then(rows => {
			if (!rows) return res.json({ message: message.notExist });
			res.send(rows);
		})
		.catch(err => console.error(err));
	} catch (e) {
    console.error(e);
  }
});

router.delete('/:id', async (req, res) => {
	try {
		const debug = req.user;
		const access = await Access(req.user, req.method, '/department', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

		connection.none(`
			delete from department where id = $1;
		`, [+req.params.id])
		.then( () => {
			res.status(200).json({message: message.deleteSuccess});
		})
		.catch(err => console.error(err));
	} catch (e) {
    console.error(e);
  }
});

module.exports = router;