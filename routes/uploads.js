const express = require('express');
const router = express.Router();
const Formidable  = require('formidable');
const fs = require('fs');

const Upload = require('../models/upload');
const Access = require('../rights');
const message = require('../messages');

const options = {
  encoding: 'utf-8',
  uploadDir: '/uploads',
  keepExtensions: false,
  multiples: false
};

router.get('/ind_plan/:id', (req, res) => {
  Upload.getFile('ind_plan', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: message.smthWentWrong});
      return
    }
    if (file){
      res.writeHead(200, {
        'Content-Disposition': `attachment; filename=${file.name}`
      });
      let readStream = fs.createReadStream(file.path);
      readStream.pipe(res);
    } else {
      res.json({ message: message.notExist });
    }
  })
});

router.get('/rpd/:id', (req, res) => {
  Upload.getFile('rpd', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: message.smthWentWrong});
      return
    }
    if (file){
      res.writeHead(200, {
        'Content-Disposition': `attachment; filename=${file.name}`
      });
      let readStream = fs.createReadStream(file.path);
      readStream.pipe(res);
    } else {
      res.json({ message: message.notExist });
    }
  })
});

router.get('/acad_plan/:id', (req, res) => {
  Upload.getFile('acad_plan', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: message.smthWentWrong});
      return
    }
    if (file){
      res.writeHead(200, {
        'Content-Disposition': `attachment; filename=${file.name}`
      });
      let readStream = fs.createReadStream(file.path);
      readStream.pipe(res);
    } else {
      res.json({ message: message.notExist });
    }
  })
});

router.get('/dep_load/:id', (req, res) => {
  Upload.getFile('dep_load', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: message.smthWentWrong});
      return
    }
    if (file){
      res.writeHead(200, {
        'Content-Disposition': `attachment; filename=${file.name}`
      });
      let readStream = fs.createReadStream(file.path);
      readStream.pipe(res);
    } else {
      res.json({ message: message.notExist });
    }
  })
});

router.get('/projects/:id', (req, res) => {
  Upload.getFile('projects', +req.params.id, (err, file) => {
    if (err) {
      console.error(err);
      res.status(500).json({message: message.smthWentWrong});
      return
    }
    if (file){
      res.writeHead(200, {
        'Content-Disposition': `attachment; filename=${file.name}`
      });
      let readStream = fs.createReadStream(file.path);
      readStream.pipe(res);
    } else {
      res.json({ message: message.notExist });
    }
  })
});

router.post('/ind_plan', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/uploads/ind_plan');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const form = new Formidable(options);

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.status(500).json({message: message.loadFailed});
        console.error('Error', err)
        throw err
      }

      if (files.file == undefined) {
        res.status(200).json({message: 'Не был передан файл'});
        return
      }

      fields.teacher_id = req.user.id;
      fields.sub_unit_id = req.user.sub_unit_id;

      Upload.saveFile('ind_plan', files.file, fields, (err, row) => {
        if (err) {
          console.error(err);
          res.status(500).json({message: message.loadFailed});
          return
        }
        res.status(200).json(row)
      });

    });
  } catch (e) {
    console.error(e);
  }
})

router.post('/projects', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/uploads/projects');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const form = new Formidable(options);

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.status(500).json({message: message.loadFailed});
        console.error('Error', err)
        throw err
      }

      if (files.file == undefined) {
        res.status(200).json({message: 'Не был передан файл'});
        return
      } else if (fields.project_id == undefined){
        res.status(200).json({message: 'Не был передан project_id'});
        return
      }
      fields.teacher_id = req.user.id;
      fields.sub_unit_id = req.user.sub_unit_id;
      
      Upload.saveFile('projects', files.file, fields, (err, row) => {
        if (err) {
          console.error(err);
          res.status(500).json({message: message.loadFailed});
          return
        }
        res.status(200).json(row)
      });

    });
  } catch (e) {
    console.error(e);
  }
})

router.post('/rpd', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/uploads/rpd');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });
    
    const form = new Formidable(options);

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.status(500).json({message: message.loadFailed});
        console.error('Error', err)
        throw err
      }

      if (files.file == undefined) {
        res.status(200).json({message: 'Не был передан файл'});
        return
      } else if (fields.discipline_id == undefined){
        res.status(200).json({message: 'Не был передан discipline_id'});
        return
      }
      fields.teacher_id = req.user.id;
      fields.sub_unit_id = req.user.sub_unit_id;
      
      Upload.saveFile('rpd', files.file, fields, (err, row) => {
        if (err) {
          console.error(err);
          res.status(500).json({message: message.loadFailed});
          return
        }
        res.status(200).json(row)
      });

    });

  } catch (e) {
    console.error(e);
  }
})

router.post('/acad_plan', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/uploads/acad_plan');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const form = new Formidable(options);

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.status(500).json({message: message.loadFailed});
        console.error('Error', err)
        throw err
      }

      if (files.file == undefined) {
        res.status(200).json({message: 'Не был передан файл'});
        return
      } else if (fields.acad_plan_id == undefined){
        res.status(200).json({message: 'Не был передан acad_plan_id'});
        return
      }
      fields.teacher_id = req.user.id;
      fields.sub_unit_id = req.user.sub_unit_id;
      
      Upload.saveFile('acad_plan', files.file, fields, (err, row) => {
        if (err) {
          console.error(err);
          res.status(500).json({message: message.loadFailed});
          return
        }
        res.status(200).json(row)
      });

    });
  } catch (e) {
    console.error(e);
  }
})

router.post('/dep_load', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/uploads/dep_load');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const form = new Formidable(options);

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.status(500).json({message: message.loadFailed});
        console.error('Error', err)
        throw err
      }

      if (files.file == undefined) {
        res.status(200).json({message: 'Не был передан файл'});
        return
      } else if (fields.dep_load_id == undefined){
        res.status(200).json({message: 'Не был передан dep_load_id'});
        return
      }
      fields.teacher_id = req.user.id;
      fields.sub_unit_id = req.user.sub_unit_id;
      
      Upload.saveFile('dep_load', files.file, fields, (err, row) => {
        if (err) {
          console.error(err);
          res.status(500).json({message: message.loadFailed});
          return
        }
        res.status(200).json(row)
      });

    });
  } catch (e) {
    console.error(e);
  }
})

module.exports = router;