const express = require('express');
const router = express.Router();

const connection = require('../db');

const accessDenied = 'Недостаточно прав!';

function isOwner(teacher, method, resource){
  if (teacher.role > '2') return true;
  return false;
}

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

router.post('/', (req, res) => {
  const debug = req.user;
	if ( !isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: accessDenied, debug: debug });

  connection.oneOrNone(`
    insert into department (name) values ($1) returning id;
  `, [req.body.name])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => {
    res.json({message: "Данное значение уже существует"});
  });
});

router.put('/:id', (req, res) => {
  const debug = req.user;
	if ( !isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: accessDenied, debug: debug });

	connection.oneOrNone(`
    update department set name = $1 where id = $2 returning *;
  `, [req.body.name, +req.params.id])
	.then(rows => {
		if (!rows) return res.json({ message: 'Такой записи не существует' });
		res.send(rows);
	})
	.catch(err => console.error(err));
});

router.delete('/:id', (req, res) => {
  const debug = req.user;
	if ( !isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: accessDenied, debug: debug });

	connection.none(`
    delete from department where id = $1;
  `, [+req.params.id])
	.then( () => {
		res.status(200).json({message: "Успешное удаление"});
	})
	.catch(err => console.error(err));
});

module.exports = router;