const express = require('express');
const router = express.Router();

const connection = require('../db')

const Access = require('../rights');
const message = require('../messages');
const strSet = require('../utils/db').strSet;

// function strUpdate(obj){
//   let str = '';
//   for (key in obj){
//     str += key + ' = \'' + obj[key] + '\', ';
//   }
//   str = str.substring(0, str.length - 2);
//   return str;
// }

// const message = {
//   accessDenied: 'Недостаточно прав!',
//   exist: "Данное значение уже существует!",
//   notExist: 'Такой записи не существует!'
// }


// function isOwner(teacher, method, resource){
//   if (teacher.role >= '3') return true;
//   return false;
// }

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
    if (!row) return res.json({ message: message.notExist });
    res.json(row);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /specialties/' });
  })
});

router.post('/', async (req, res) => {
  try {
    const debug = req.user;
    const access = await Access(req.user, req.method, '/specialties');
    if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

    connection.oneOrNone('insert into specialties ( ${this:name} ) values (${this:csv}) returning id;', req.body )
    .then(rows => {
      res.send(rows);
    })
    .catch(err => {
      console.error(err);
      res.json({message: message.exist});
    });
  } catch (e) {
    console.error(e);
  }
});

router.put('/:id', async (req, res) => {
  try {
    const debug = req.user;
    const access = await Access(req.user, req.method, '/specialties', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

    const str = strSet(req.body);

    connection.oneOrNone(`UPDATE specialties SET ${str} where id = ${+req.params.id} returning *;`)
    .then(rows => {
      if (!rows) return res.json({ message: message.notExist });
      res.send(rows);
    })
    .catch(err => {
      console.error(err);
    });
  } catch (e) {
    console.error(e);
  }
});

module.exports = router;