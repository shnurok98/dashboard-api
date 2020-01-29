const express = require('express');
const router = express.Router();

const Formidable = require('formidable');

const form = new Formidable();
form.encoding = 'utf-8';
// form.uploadDir = __dirname + "/uploads";
form.uploadDir = 'C:\\Uploads';
form.keepExtensions = true; // сохранять с исходным расшерением

router.post('/', (req, res) => {
	form.parse(req, (err, fields, files) => {
    if (err) {
      console.error('Error', err)
      throw err
    }
    console.log('Fields', fields)
    console.log('Files', files)
    for (const file of Object.entries(files)) {
      console.log(file)
    }
  })
})

module.exports = router;