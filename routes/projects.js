const express = require('express');
const router = express.Router();

const connection = require('../db');

// Затирает id
router.get('/', (req, res) => {
  connection.any(`
  SELECT 
    p.*,
    count(sp.id) students_count 
  FROM projects p, students_projects sp 
  WHERE p.id = sp.project_id 
  GROUP BY p.id
;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.log(err));
});

// Затирает id
router.get('/:id', (req, res) => {
	connection.oneOrNone(`
    select public.pr_projects_s($1) as project;
  `, [+req.params.id])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

module.exports = router;