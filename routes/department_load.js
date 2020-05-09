const express = require('express');
const router = express.Router();

const connection = require('../db');

const Access = require('../rights');
const message = require('../messages');
const strSet = require('../utils/db').strSet;

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

router.post('/', async (req, res) => {
  try {
    const debug = req.user;
    const access = await Access(req.user, req.method, '/dep_load', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

    connection.one('SELECT public.pr_depload_i($1::jsonb) id;', [req.body ])
    .then(rows => {
      res.status(200).json(rows);
		})
		.catch(e => {
			// if e.table ...
			res.json({message: 'Oops!', error: e});
		})
  } catch(e) {
    console.error(e);
    res.json(e);
  }
});

module.exports = router;