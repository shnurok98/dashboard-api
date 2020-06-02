const express = require('express');
const router = express.Router();

const connection = require('../db');

const Access = require('../rights');
const message = require('../messages');
const strSet = require('../utils/db').strSet;

router.get('/', (req, res) => {
  connection.manyOrNone(`
  SELECT 
    p.*,
    count(sp.id) students_count 
  FROM projects p  
  LEFT JOIN students_projects sp ON p.id = sp.project_id 
  GROUP BY p.id
;`)
	.then(rows => {
		res.status(200).send(rows);
	})
	.catch(err => {
    console.log(err);
    res.status(500).json({ message: message.smthWentWrong, error: err });
  });
});

router.get('/:id', (req, res) => {
	connection.oneOrNone(`
    select public.pr_projects_s($1) as project;
  `, [+req.params.id])
	.then(rows => {
    if (!rows) return res.status(404).json({ message: message.notExist });
		res.status(200).send(rows);
	})
	.catch(err => {
    console.error(err);
    res.status(500).json({ message: message.smthWentWrong, error: err });
  });
});

router.get('/:id/files', (req, res) => {
  connection.manyOrNone(`
  SELECT id, name, ext, modified_date, teacher_id, sub_unit_id, project_id
  FROM files_projects
  WHERE project_id = ${+req.params.id}
  ORDER BY modified_date DESC;
  `)
  .then(rows => {
    res.status(200).json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/teacher/:teacher_id', (req, res) => {
  connection.manyOrNone(`
  SELECT p.*
  FROM projects p
  WHERE p.teacher_id = ${+req.params.teacher_id}
;`)
	.then(rows => {
		res.status(200).send(rows);
	})
	.catch(err => {
    console.log(err);
    res.status(500).json({ message: message.smthWentWrong, error: err });
  });
});

router.post('/', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    connection.oneOrNone('insert into projects ( ${this:name} ) values (${this:csv}) returning id;', req.body )
    .then(rows => {
      res.status(201).send(rows);
    })
    .catch(err => {
      console.error(err);
      res.status(400).json({message: message.badData});
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: message.smthWentWrong, error: e });
  }
  
});

router.put('/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const str = strSet(req.body);

    connection.oneOrNone(`UPDATE projects SET ${str} where id = ${+req.params.id} returning *;`)
    .then(rows => {
      if (!rows) return res.status(404).json({ message: message.notExist });
      res.status(204).send(rows);
    })
    
  } catch (e) {
    console.error(e);
  }
});

router.put('/:id/students', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    connection.one(`SELECT public.pr_projects_students_i(${+req.params.id}, $1)`, [req.body])
    .then(rows => {
      if (!rows) return res.status(400).json({ message: message.badData });
      res.status(204).send(rows);
    })
    .catch(e => res.status(500).json({ message: message.smthWentWrong, error: e }))
    
  } catch (e) {
    console.error(e);
  }
});

module.exports = router;