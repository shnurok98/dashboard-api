const express = require('express');
const router = express.Router();

const connection = require('../db')

router.get('/', (req, res) => {
  connection.manyOrNone(`
  SELECT 
    A.id,
    SP.id AS specialty_id,
    SP.code,
    SP.name,
    SP.profile,
    SP.educ_form,
    SP.educ_programm,
    SP.educ_years,
    SP.year_join,
    SP.sub_unit_id
  FROM academic_plan AS A, specialties AS SP 
  WHERE A.id = SP.acad_plan_id
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
    SP.id AS specialty_id,
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
    D.*,
    S.*
  FROM 
    academic_plan AS A, 
    specialties AS SP, 
    blocks_for_acad_plan AS B1,
    discip_blocks AS B2,
    discip_modules AS B3,
    disciplines AS D,
    semestr AS S 
  WHERE 
    A.id = $1 AND
    A.id = SP.acad_plan_id AND
    A.id = B1.acad_plan_id AND
    B1.discip_blocks_id = B2.id AND
    B2.id = B3.block_id AND
    B3.id = D.module_id AND
    D.id = S.discipline_id
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