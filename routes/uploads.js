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

router.post('/ind_plan', (req, res) => {
  const form = new Formidable(options);

  // form.on('error', (err) => {
  //   res.status(500);
  //   console.error(err);
  // });

  form.parse(req, (err, fields, files) => {
    if (err) {
      res.status(500).json({message: 'Загрузка не удалась'});
      console.error('Error', err)
      throw err
    }
    // console.log(fields)
    // console.log(files.file);
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

    // console.log(files.file.name);
    // console.log(files.file.path);
    // console.log(path.extname(files.file.name));
    // console.log(files.file.lastModifiedDate);
    // console.log('tech id:' + req.user.id);
    // res.status(200).json({message: 'Load success!'});
  });
  
})

module.exports = router;