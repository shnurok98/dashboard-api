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
	connection.any(`
	SELECT 
    row_to_json(t, true) project
  FROM (
    SELECT p.*, (
      SELECT array_to_json(array_agg(row_to_json(child))) from (
        select sp.student_id
        from students_projects sp
        where sp.project_id = p.id
      ) child
    ) students
    FROM projects p 
    WHERE p.id = $1
  ) t 
;`, [+req.params.id])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

module.exports = router;