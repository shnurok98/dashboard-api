const express = require('express');
const router = express.Router();

const Access = require('../rights');
const message = require('../messages');
const AcadPlan = require('../models/acad_plan');
const Upload = require('../models/upload');

router.get('/', (req, res) => {
  AcadPlan.getAll(req.query, (err, acad) => {
    if (err) return res.status(400).json(err);
		if (acad) {
			res.status(200).json(acad);
		}else{
			res.sendStatus(500);
		}
  });
});

router.get('/:id', (req, res) => {
  AcadPlan.get(req.params.id, (err, acad) => {
		if (err) console.error(err);
		if (acad) {
			res.status(200).json(acad);
		}else{
			res.sendStatus(404);
		}
	});
});

router.get('/:id/files', (req, res) => {
  Upload.getList('files_acad_plan', +req.params.id, req.query, (err, rows) => {
		if (err) return res.status(400).json(err);
		if (rows) {
			res.status(200).json(rows);
		} else {
			res.sendStatus(500);
		}
	});
});

router.get('/:id/semester/:num', (req, res) => {
  AcadPlan.getSemester(+req.params.id, +req.params.num, (err, dis) => {
    if (err) console.error(err);
		if (dis) {
			res.status(200).json(dis);
		}else{
			res.sendStatus(404);
		}
  })
});

router.put('/discipline/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied});

    AcadPlan.updateDiscipline(+req.params.id, req.body, (err, id) => {
      if ( err ) return res.status(400).json(err);
			if ( id ) {
				res.sendStatus(204)
			} else {
				res.sendStatus(404)
			}
    })
    
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
});

router.post('/', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied});

    const data = req.body;
		const acadplan = new AcadPlan(data);
		acadplan.save((err, id) => {
			if ( err ) return res.status(400).json(err);
			if ( id ) {
				res.location(`/api/acad_plan/${id}`);
				res.sendStatus(201)
			} 
		});
  } catch(e) {
    console.error(e);
    res.sendStatus(500);
  }
});

// Block, Part, Module

router.get('/:table(module|block|part)/:id', (req, res) => {
  const table = 'acad_' + req.params.table;

  AcadPlan.getDir(table, +req.params.id, (err, dir) => {
    if ( err ) return res.status(400).json(err);
    if ( dir ) {
      res.status(200).json(dir);
    } else {
      res.sendStatus(404);
    }
  })
});

router.put('/:table(module|block|part)/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/acad_plan', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });
    
    const table = 'acad_' + req.params.table;

    AcadPlan.updateDir(table, +req.params.id, req.body, (err, dir) => {
      if ( err ) return res.status(400).json(err);
      if ( dir ) {
        res.sendStatus(204)
      } else {
        res.sendStatus(404);
      }
    })
    
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
})

module.exports = router;