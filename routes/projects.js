const express = require('express');
const router = express.Router();

const connection = require('../db');

function strUpdate(obj){
  let str = '';
  for (key in obj){
    str += key + ' = \'' + obj[key] + '\', ';
  }
  str = str.substring(0, str.length - 2);
  return str;
}

const message = {
  accessDenied: 'Недостаточно прав!',
  exist: "Данное значение уже существует!",
  notExist: 'Такой записи не существует!'
}

function getRights(teacher, resource_id){
  return new Promise((resolve, reject) => { 
    connection.one(`select (select 1 from projects p where p.id = ${resource_id} and p.teacher_id = ${teacher.id}) is not null exist`)
    .then(row => {
      resolve(row.exist);
    })
    .catch(err => {
      console.log(err)
      reject(false);
    });
  })
}

async function isOwner(teacher, method, resource_id){
  if (teacher.role >= '3') return true;
  if (teacher.role == '2' && method == 'PUT') {

    return await getRights(teacher, resource_id);
  } else {
    return false;
  }
}


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
		res.send(rows);
	})
	.catch(err => console.log(err));
});

router.get('/:id', (req, res) => {
	connection.oneOrNone(`
    select public.pr_projects_s($1) as project;
  `, [+req.params.id])
	.then(rows => {
		res.send(rows);
	})
	.catch(err => console.error(err));
});

router.post('/', async (req, res) => {
  try {
    const debug = req.user;
    const access = await isOwner(req.user, req.method, req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

    connection.oneOrNone('insert into projects ( ${this:name} ) values (${this:csv}) returning id;', req.body )
    .then(rows => {
      res.send(rows);
    })
    .catch(err => {
      console.error(err);
      res.json({message: message.exist});
    });
  } catch (e) {
    console.error(e);
  }
  
});

router.put('/:id', async (req, res) => {
  try {
    const debug = req.user;
    const access =  await isOwner(req.user, req.method, req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

    const str = strUpdate(req.body);

    connection.oneOrNone(`UPDATE projects SET ${str} where id = ${+req.params.id} returning *;`)
    .then(rows => {
      if (!rows) return res.json({ message: message.notExist });
      res.send(rows);
    })
    
  } catch (e) {
    console.error(e);
  }
});

module.exports = router;