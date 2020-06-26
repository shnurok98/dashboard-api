const express = require('express');
const router = express.Router();
const Formidable  = require('formidable');
const fs = require('fs');

const Upload = require('../models/upload');
const Access = require('../middleware/rights');
const message = require('../messages');
const { prefix } = require('../config').api;

const options = {
  encoding: 'utf-8',
  uploadDir: '/uploads',
  keepExtensions: false,
  multiples: false
};

router.use('*', async (req, res, next) => {
	try {
		const table = req.baseUrl.match(/ind_plan|rpd|acad_plan|dep_load|projects/)[0];

		const url = req.baseUrl.replace(prefix, '');
		const partsUrl = url.match(/\/\w+/g); // все части вида '/word'
		console.log(partsUrl);
		const parentUrl = partsUrl[0] + partsUrl[1]; // /uploads/ind_plan/1
		let resourceId = partsUrl[2];
		if ( resourceId ) resourceId = resourceId.substring(1, resourceId.length);
		
		// система прав
		const access = await Access(req.user, req.method, parentUrl, resourceId);
		if ( !access ) return res.sendStatus(403);

		res.locals.table = table;
		next();
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
})

router.get('/:table(ind_plan|rpd|acad_plan|dep_load|projects)/:id', (req, res) => {
  const table = req.params.table;
 
  Upload.getFile(table, +req.params.id, (err, file) => {
    if ( err ) return res.status(400).json(err)
    if ( file ){
      res.writeHead(200, {
        'Content-Disposition': `attachment; filename=${file.name}`
      });
      let readStream = fs.createReadStream(file.path);
      readStream.pipe(res);
    } else {
      res.sendStatus(404)
    }
  })
})

router.post('/:table(ind_plan|rpd|acad_plan|dep_load|projects)', async (req, res) => {
  try {
    const table = req.params.table;

    const form = new Formidable(options);

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.status(500).json({message: message.loadFailed});
        return console.error('Formiddable error: ', err);
      }

      if (files.file == undefined) return res.status(400).json({message: 'Не был передан файл'});

      fields.teacher_id = req.user.id;
      fields.sub_unit_id = req.user.sub_unit_id;

      Upload.saveFile(table, files.file, fields, (err, row) => {
        if (err) return res.status(400).json(err);
        if ( row ) {
          res.location(`/api/${table}/${row.id}`);
				  res.sendStatus(201)
        }
      });

    });

  } catch(e) {
    console.error(e);
    res.sendStatus(500);
  }
})

router.delete('/:table(ind_plan|rpd|acad_plan|dep_load|projects)/:id', async (req, res) => {
  try {
    const table = req.params.table;

    Upload.delete(table, +req.params.id, (err) => {
      if ( err ) return res.status(409).json(err);
			res.sendStatus(204);
    })
  } catch(e) {
    console.error(e);
    res.sendStatus(500);
  }
})

module.exports = router;