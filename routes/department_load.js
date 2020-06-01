const express = require('express');
const router = express.Router();

const connection = require('../db');

const Access = require('../rights');
const message = require('../messages');

router.get('/', (req, res) => {
	connection.any(`
	SELECT 
		L.*,
		D.name department_name
	FROM dep_load L, department D 
	WHERE L.department_id = D.id
	ORDER BY L.modified_date DESC
	;`)
	.then(rows => {
		res.status(200).send(rows);
	})
	.catch(err => {
		res.status(500).json({ message: message.smthWentWrong, error: err });
	});
});

router.get('/:id', (req, res) => {
	connection.oneOrNone(`
	SELECT public.pr_depload_s(${+req.params.id}) dep_load;
	`)
	.then(rows => {
		res.status(200).send(rows);
	})
	.catch(err => {
		res.status(500).json({ message: message.smthWentWrong, error: err });
	});
});

router.get('/:id/files', (req, res) => {
  connection.manyOrNone(`
  SELECT id, name, ext, modified_date, teacher_id, sub_unit_id, dep_load_id
  FROM files_dep_load 
  WHERE dep_load_id = ${+req.params.id}
  ORDER BY modified_date DESC;
  `)
  .then(rows => {
    res.json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

/* Not worked */ 
router.get('/group/:group_id/semester/:semester_num', (req, res) => {
	// тут нужно подхватывать год или dep_load_id
	connection.any(`
	SELECT 
		L.*,
		D.name department_name
	FROM dep_load L, department D 
	WHERE L.department_id = D.id
	ORDER BY L.modified_date DESC
	;`)
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.log(err));
});

router.post('/', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/dep_load');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    connection.one('SELECT public.pr_depload_i($1::jsonb) id;', [req.body ])
    .then(rows => {
      res.status(200).json(rows);
		})
		.catch(e => {
			// if e.table ...
			res.json({message: message.smthWentWrong, error: e});
		})
  } catch(e) {
    console.error(e);
    res.status(500).json({ message: message.smthWentWrong, error: e });
  }
});

router.put('/discipline/:discipline_id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied});

    connection.oneOrNone(`SELECT public.pr_discipline_u($1, $2) id;`, [+req.params.discipline_id, req.body])
    .then(rows => {
      if (!rows) return res.json({ message: message.notExist });
      res.send(rows);
		})
		.catch(e => {
			console.error(e);
			res.json({ message: message.smthWentWrong });
		});
    
  } catch (e) {
		console.error(e);
		res.status(500).json({ message: message.smthWentWrong });
  }
});

router.post('/discipline/teacher', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/dep_load');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    connection.one('INSERT INTO disciplines_teachers (discipline_id, teacher_id) VALUES ($1, $2);', [+req.body.discipline_id, +req.body.teacher_id ])
    .then(rows => {
      res.status(201).json(rows);
		})
		.catch(e => {
			res.status(500).json({message: message.smthWentWrong, error: e});
		})
  } catch(e) {
    console.error(e);
    res.status(500).json({ message: message.smthWentWrong, error: e });
  }
});

router.get('/discipline/teacher/:teacher_id', (req, res) => {
  connection.manyOrNone(`
	SELECT D.*
	FROM disciplines D, disciplines_teachers DT
	WHERE DT.teacher_id = ${+req.params.teacher_id} AND DT.discipline_id = D.id
	ORDER BY D.id DESC;
  `)
  .then(rows => {
    res.status(200).json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

module.exports = router;