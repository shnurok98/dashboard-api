const express = require('express');
const router = express.Router();

const connection = require('../db')

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
    console.error(err);
    res.json({ message: 'Error: /acad_plan/' });
  })
});

router.get('/:id', (req, res) => {
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
    SP.sub_unit_id,
    B1.*,
    B2.*,
    B3.*,
    D.*
  FROM 
    acad_plan AS A, 
    specialties AS SP, 
    acad_block AS B1,
    acad_part AS B2,
    acad_module AS B3,
    acad_discipline AS D
  WHERE 
    A.id = $1 AND
    A.specialties_id = SP.id AND
    A.id = D.acad_plan_id
  ;
  `, [+req.params.id])
  .then(rows => {
    res.json(rows);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /acad_plan/:id' });
  })
});

module.exports = router;