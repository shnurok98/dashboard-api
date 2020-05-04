const express = require('express');
const router = express.Router();

const connection = require('../db');

router.get('/', (req, res) => {
	connection.any(`
	SELECT 
		L.*,
		D.name department_name,
		S.name sub_unit_name
	FROM dep_load L, sub_unit S, department D 
	WHERE L.sub_unit_id = S.id AND S.department_id = D.id
	ORDER BY L.modified_date DESC
	;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.log(err));
});

router.get('/:id', (req, res) => {
	connection.oneOrNone(`
	SELECT public.pr_depload_s(${+req.params.id}) dep_load;
	`, [])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

module.exports = router;