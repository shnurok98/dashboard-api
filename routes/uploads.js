const express = require('express');
const router = express.Router();

// const path = require('path');
const Formidable  = require('formidable');

const Upload = require('../models/upload');

const options = {
  encoding: 'utf-8',
  uploadDir: '/uploads',
  keepExtensions: false,
  multiples: false
};
// uploadDir: path.join(__dirname, '/..', '/uploads'),

// console.log(options);

const fs = require('fs');



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
  if (teacher.role == '4') return true;
  if (teacher.role == '2' || teacher.role == '3') {
    return true;
    // return await getRights(teacher, resource_id);
  };
}





router.get('/ind_plan/:id', (req, res) => {
  Upload.getFile('ind_plan', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: 'Не удалась'});
      return
    }
    // let path = '/uploads/upload_dd1dde8c46fd112bb5c7551d09a3b813';
    res.writeHead(200, {
      'Content-Type': 'text/plain'
    });
    let readStream = fs.createReadStream(file.path);
    readStream.pipe(res);
  })
  
});

router.get('/rpd/:id', (req, res) => {
  Upload.getFile('rpd', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: 'Не удалась'});
      return
    }
    // let path = '/uploads/upload_dd1dde8c46fd112bb5c7551d09a3b813';
    res.writeHead(200, {
      'Content-Type': 'text/plain'
    });
    let readStream = fs.createReadStream(file.path);
    readStream.pipe(res);
  })
  
});

router.get('/acad_plan/:id', (req, res) => {
  Upload.getFile('acad_plan', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: 'Не удалась'});
      return
    }
    // let path = '/uploads/upload_dd1dde8c46fd112bb5c7551d09a3b813';
    res.writeHead(200, {
      'Content-Type': 'text/plain'
    });
    let readStream = fs.createReadStream(file.path);
    readStream.pipe(res);
  })
  
});

router.get('/projects/:id', (req, res) => {
  Upload.getFile('projects', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: 'Не удалась'});
      return
    }
    // let path = '/uploads/upload_dd1dde8c46fd112bb5c7551d09a3b813';
    res.writeHead(200, {
      'Content-Type': 'text/plain'
    });
    let readStream = fs.createReadStream(file.path);
    readStream.pipe(res);
  })
  
});

router.post('/ind_plan', async (req, res) => {
  try {
    const debug = req.user;
    const access = await isOwner(req.user, req.method, req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied, debug: debug });

    const form = new Formidable(options);

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.status(500).json({message: 'Загрузка не удалась'});
        console.error('Error', err)
        throw err
      }

      if (files.file == undefined) {
        res.status(200).json({message: 'Where is my file Lebowski?'});
        return
      }
      Upload.ind_plan(files.file, req.user.id, (err, row) => {
        if (err) {
          console.error(err);
          res.status(500).json({message: 'Загрузка в бд не удалась'});
          return
        }
        res.status(200).json(row)
      });

    });
  } catch (e) {
    console.error(e);
  }
})

router.post('/projects', (req, res) => {
  const form = new Formidable(options);

  form.parse(req, (err, fields, files) => {
    if (err) {
      res.status(500).json({message: 'Загрузка не удалась'});
      console.error('Error', err)
      throw err
    }

    if (files.file == undefined) {
      res.status(200).json({message: 'Where is my file Lebowski?'});
      return
    } else if (fields.project_id == undefined){
      res.status(200).json({message: 'Where is my project_id Lebowski?'});
      return
    }
    Upload.projects(files.file, req.user.id, fields.project_id, (err, row) => {
      if (err) {
        console.error(err);
        res.status(500).json({message: 'Загрузка в бд не удалась'});
        return
      }
      res.status(200).json(row)
    });
  });
  
})

router.post('/rpd', (req, res) => {
  const form = new Formidable(options);

  form.parse(req, (err, fields, files) => {
    if (err) {
      res.status(500).json({message: 'Загрузка не удалась'});
      console.error('Error', err)
      throw err
    }

    if (files.file == undefined) {
      res.status(200).json({message: 'Where is my file Lebowski?'});
      return
    } else if (fields.discipline_id == undefined){
      res.status(200).json({message: 'Where is my discipline_id Lebowski?'});
      return
    }
    Upload.rpd(files.file, req.user.id, fields.discipline_id, (err, row) => {
      if (err) {
        console.error(err);
        res.status(500).json({message: 'Загрузка в бд не удалась'});
        return
      }
      res.status(200).json(row)
    });
  });
  
})

router.post('/acad_plan', (req, res) => {
  const form = new Formidable(options);

  form.parse(req, (err, fields, files) => {
    if (err) {
      res.status(500).json({message: 'Загрузка не удалась'});
      console.error('Error', err)
      throw err
    }

    if (files.file == undefined) {
      res.status(200).json({message: 'Where is my file Lebowski?'});
      return
    } else if (fields.acad_plan_id == undefined){
      res.status(200).json({message: 'Where is my acad_plan_id Lebowski?'});
      return
    }
    Upload.acad_plan(files.file, req.user.id, fields.acad_plan_id, (err, row) => {
      if (err) {
        console.error(err);
        res.status(500).json({message: 'Загрузка в бд не удалась'});
        return
      }
      res.status(200).json(row)
    });
  });
  
})

module.exports = router;