const express = require('express');
const router = express.Router();

const connection = require('../db');

router.get('/', (req, res) => {
	connection.any(`
	SELECT 
		l.*,
		d.name
	FROM dep_load l, department d 
	WHERE l.department_id = d.id
	ORDER BY l.modified_date DESC
	;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.log(err));
});

// Затирает id
router.get('/:id', (req, res) => {
	connection.any(`
	SELECT 
		l.*,
		d.name department_name,
		di.*
	FROM dep_load l, department d, disciplines di 
	WHERE l.id = $1 AND l.department_id = d.id AND l.id = di.dep_load_id
	;`, [+req.params.id])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

module.exports = router;