const express = require('express');
const router = express.Router();

const connection = require('../db')

const Access = require('../rights');
const message = require('../messages');
const strSet = require('../utils/db').strSet;

router.get('/', (req, res) => {
  connection.manyOrNone(`
  SELECT sp.*, su.name sub_unit_name 
  FROM specialties sp 
  LEFT JOIN sub_unit su
  ON sp.sub_unit_id = su.id
  ORDER BY id
  `)
  .then(row => {
    res.status(200).json(row);
  })
  .catch(err => {
    console.error(err);
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/:id', (req, res) => {
  connection.oneOrNone(`
  SELECT sp.*, su.name sub_unit_name 
  FROM specialties sp, sub_unit su
  WHERE sp.sub_unit_id = su.id AND sp.id = $1
  `, [+req.params.id])
  .then(row => {
    if (!row) return res.status(404).json({ message: message.notExist });
    res.status(200).json(row);
  })
  .catch(err => {
    console.error(err);
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.post('/', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/specialties');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    connection.oneOrNone('insert into specialties ( ${this:name} ) values (${this:csv}) returning id;', req.body )
    .then(rows => {
      res.status(200).send(rows);
    })
    .catch(err => {
      console.error(err);
      res.status(400).json({message: message.badData});
    });
  } catch (e) {
    console.error(e);
  }
});

router.put('/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/specialties', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const str = strSet(req.body);

    connection.oneOrNone(`UPDATE specialties SET ${str} where id = ${+req.params.id} returning *;`)
    .then(rows => {
      if (!rows) return res.status(404).json({ message: message.notExist });
      res.status(204).send(rows);
    })
    .catch(err => {
      console.error(err);
      res.status(500).json({ message: message.smthWentWrong, error: err });
    });
  } catch (e) {
    console.error(e);
  }
});

module.exports = router;