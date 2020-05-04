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
  connection.oneOrNone(`
  SELECT public.pr_acadplan_s(${+req.params.id}) acad_plan;
  `, [])
  .then(rows => {
    res.json(rows);
  })
  .catch(err => {
    console.error(err);
    res.json({ message: 'Error: /acad_plan/:id' });
  })
});

module.exports = router;