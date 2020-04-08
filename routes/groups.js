const express = require('express');
const router = express.Router();

const connection = require('../db')

function strUpdate(obj){
  let str = '';
  for (key in obj){
    str += key + ' = \'' + obj[key] + '\', ';
  }
  str = str.substring(0, str.length - 2);
  return str;
}

const message = {
  accessDenied: 'Недостаточно прав!',
  exist: "Данное значение уже существует!",
  notExist: 'Такой записи не существует!'
}

function isOwner(teacher, method, resource){
  if (teacher.role >= '3') return true;
  return false;
}


router.get('/', (req, res) => {
  connection.manyOrNone(`
  SELECT 
    g.*, 
    sp.name specialties_name, 
    sp.code specialties_code, 
    su.name sub_unit_name 
  FROM "groups" g
  left join specialties sp on g.specialties_id = sp.id
  LEFT JOIN sub_unit su ON sp.sub_unit_id = su.id
  ORDER BY g.id DESC
  `)
  .then(rows => {
    res.json(rows);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /groups/' });
  })
});

router.get('/:id', (req, res) => {
  connection.oneOrNone(`
  SELECT 
    g.*, 
    sp.name specialties_name, 
    sp.code specialties_code, 
    su.name sub_unit_name 
  FROM "groups" g
  left join specialties sp on g.specialties_id = sp.id 
  LEFT JOIN sub_unit su ON sp.sub_unit_id = su.id
  where g.id = $1
  `, [+req.params.id])
  .then(row => {
    if (!row) return res.json({ message: message.notExist });
    res.json(row);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /groups/:id' });
  })
});

router.post('/', (req, res) => {
  const debug = req.user;
	if ( !isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: message.accessDenied, debug: debug });

  connection.oneOrNone('insert into groups ( ${this:name} ) values (${this:csv}) returning id;', req.body )
	.then(rows => {
		res.send(rows);
	})
	.catch(err => {
    console.error(err);
    res.json({message: message.exist});
  });
});

router.put('/:id', (req, res) => {
  const debug = req.user;
	if ( !isOwner(req.user, req.method, req.params.id) ) return res.status(403).json({ message: message.accessDenied, debug: debug });

  const str = strUpdate(req.body);

  connection.oneOrNone(`UPDATE groups SET ${str} where id = ${+req.params.id} returning *;`)
	.then(rows => {
    if (!rows) return res.json({ message: message.notExist });
		res.send(rows);
	})
	.catch(err => {
    console.error(err);
  });
});

module.exports = router;