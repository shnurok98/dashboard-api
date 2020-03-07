const express = require('express');
const router = express.Router();

const connection = require('../db')

router.get('/:id', (req, res) => {
  connection.one(`SELECT * FROM groups WHERE id = $1`, [+req.params.id])
  .then(row => {
    res.json(row);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /groups/:id' });
  })
});

router.get('/', (req, res) => {
	connection.manyOrNone(`SELECT * FROM groups ORDER BY id`)
  .then(row => {
    res.json(row);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /groups/' });
  })
});


module.exports = router;