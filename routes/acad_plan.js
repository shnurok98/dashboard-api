const express = require('express');
const router = express.Router();

const connection = require('../db')

const Access = require('../rights');
const message = require('../messages');
const strSet = require('../utils/db').strSet;

router.get('/', (req, res) => {
  connection.manyOrNone(`
  SELECT 
    A.id,
    SP.id AS specialties_id,
    SP.code,
    SP.name,
    SP.profile,
    SP.educ_form,
    SP.educ_programm,
    SP.educ_years,
    SP.year_join,
    SP.sub_unit_id
  FROM acad_plan AS A, specialties AS SP 
  WHERE A.specialties_id = SP.id
  ORDER BY SP.year_join DESC;
  `)
  .then(rows => {
    res.json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/:id', (req, res) => {
  connection.oneOrNone(`
  SELECT public.pr_acadplan_s(${+req.params.id}) acad_plan;
  `)
  .then(rows => {
    res.json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/:id/files', (req, res) => {
  connection.manyOrNone(`
  SELECT id, name, ext, modified_date, teacher_id, sub_unit_id, acad_plan_id 
  FROM files_acad_plan 
  WHERE acad_plan_id = ${+req.params.id}
  ORDER BY modified_date DESC;
  `)
  .then(rows => {
    res.json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/:id/semester/:num', (req, res) => {
  connection.manyOrNone(`
  SELECT * from acad_discipline D 
  where D.acad_plan_id = ${+req.params.id} AND D.semesters[${+req.params.num}] IS NOT NULL;
  `)
  .then(rows => {
    res.status(200).json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/filter/year/:year', (req, res) => {
  connection.manyOrNone(`
  SELECT 
    A.id,
    SP.id AS specialties_id,
    SP.code,
    SP.name,
    SP.profile,
    SP.educ_form,
    SP.educ_programm,
    SP.educ_years,
    SP.year_join,
    SP.sub_unit_id
  FROM acad_plan AS A, specialties AS SP 
  WHERE A.specialties_id = SP.id and date_part('year', SP.year_join) = ${+req.params.year} 
  ORDER BY SP.year_join DESC;
  `)
  .then(rows => {
    res.status(200).json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.put('/discipline/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied});

    const str = strSet(req.body);
    
    connection.oneOrNone(`
    UPDATE acad_discipline SET ${str} where id = ${+req.params.id} returning *;
    `)
    .then(rows => {
      if (!rows) return res.json({ message: message.notExist });
      res.send(rows);
    })
    
  } catch (e) {
    console.error(e);
  }
});

router.post('/', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied});

    connection.one('SELECT public.pr_acadplan_i($1::jsonb) id;', [req.body ])
    .then(rows => {
      res.status(200).json(rows);
    })
  } catch(e) {
    res.status(500).json({ message: message.smthWentWrong, error: e });
  }
});

// Block, Part, Module

router.get('/module/:id', (req, res) => {
  connection.oneOrNone(`
  SELECT * FROM acad_module WHERE id = ${+req.params.id};
  `)
  .then(rows => {
    res.status(200).json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/block/:id', (req, res) => {
  connection.oneOrNone(`
  SELECT * FROM acad_block WHERE id = ${+req.params.id};
  `)
  .then(rows => {
    res.status(200).json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.get('/part/:id', (req, res) => {
  connection.oneOrNone(`
  SELECT * FROM acad_part WHERE id = ${+req.params.id};
  `)
  .then(rows => {
    res.status(200).json(rows);
  })
  .catch(err => {
    res.status(500).json({ message: message.smthWentWrong, error: err });
  })
});

router.put('/module/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });
    
    connection.oneOrNone(`
    insert into acad_module ("name", "code") 
		values ( $1, $2 )
		on conflict ("name", "code") do update set "name" = $1 
		returning *;
    `, [req.body.name, req.body.code])
    .then(rows => {
      res.send(rows);
    })
    .catch(e => {
      res.status(500).json({ message: message.smthWentWrong, error: e });
    })
    
  } catch (e) {
    res.status(500).json({ message: message.smthWentWrong, error: e });
    console.error(e);
  }
});

router.put('/block/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });
    
    connection.oneOrNone(`
    insert into acad_block ("name", "code") 
		values ( $1, $2 )
		on conflict ("name", "code") do update set "name" = $1 
		returning *;
    `, [req.body.name, req.body.code])
    .then(rows => {
      res.send(rows);
    })
    .catch(e => {
      res.status(500).json({ message: message.smthWentWrong, error: e });
    })
    
  } catch (e) {
    res.status(500).json({ message: message.smthWentWrong, error: err });
    console.error(e);
  }
});

router.put('/part/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied});

    connection.oneOrNone(`
    insert into acad_part ("name", "code") 
		values ( $1, $2 )
		on conflict ("name", "code") do update set "name" = $1 
		returning *;
    `, [req.body.name, req.body.code])
    .then(rows => {
      res.send(rows);
    })
    .catch(e => {
      res.status(500).json({ message: message.smthWentWrong, error: e });
    })
    
  } catch (e) {
    res.status(500).json({ message: message.smthWentWrong, error: e });
    console.error(e);
  }
});

module.exports = router;