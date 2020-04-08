const express = require('express');
const router = express.Router();

const connection = require('../db')

function strUpdate(obj){
  let str = '';
  for (key in obj){
    str += key + ' = \'' + obj[key] + '\',';
  }
  str = str.substring(0, str.length - 1);
  return str;
}

const accessDenied = 'Недостаточно прав!';

function isOwner(teacher, method, resource){
  if (teacher.role >= '3') return true;
  return false;
}

router.get('/', (req, res) => {
  connection.manyOrNone(`
  SELECT sp.*, su.name sub_unit_name 
  FROM specialties sp 
  LEFT JOIN sub_unit su
  ON sp.sub_unit_id = su.id
  ORDER BY id
  `)
  .then(row => {
    res.json(row);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /specialties/' });
  })
});

router.get('/:id', (req, res) => {
  connection.oneOrNone(`
  SELECT sp.*, su.name sub_unit_name 
  FROM specialties sp, sub_unit su
  WHERE sp.sub_unit_id = su.id AND sp.id = $1
  `, [+req.params.id])
  .then(row => {
    res.json(row);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /specialties/' });
  })
});

router.post('/', (req, res) => {
  const debug = req.user;
	if ( !isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: accessDenied, debug: debug });

  connection.oneOrNone('insert into specialties ( ${this:name} ) values (${this:csv}) returning id;', req.body )
	.then(rows => {
		res.send(rows);
	})
	.catch(err => {
    console.error(err);
    res.json({message: "Данное значение уже существует"});
  });
});

router.put('/:id', (req, res) => {
  const debug = req.user;
	if ( !isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: accessDenied, debug: debug });

  const str = strUpdate(req.body);

  connection.oneOrNone(`UPDATE specialties SET ${str} where id = ${+req.params.id} returning *;`)
	.then(rows => {
    if (!rows) return res.json({ message: 'Такой записи не существует' });
		res.send(rows);
	})
	.catch(err => {
    console.error(err);
    res.json({message: "Данное значение уже существует"});
  });
});

module.exports = router;