const express = require('express');
const router = express.Router();

const connection = require('../db')

router.get('/', (req, res) => {
	connection.manyOrNone(`SELECT * FROM specialties ORDER BY id`)
  .then(row => {
    res.json(row);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /specialties/' });
  })
});


module.exports = router;