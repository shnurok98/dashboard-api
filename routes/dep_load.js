const express = require('express');
const router = express.Router();

const Access = require('../rights');
const message = require('../messages');
const DepLoad = require('../models/dep_load');
const Upload = require('../models/upload');

router.get('/', (req, res) => {
	DepLoad.getAll(req.query, (err, dep) => {
    if (err) return res.status(400).json(err);
		if (dep) {
			res.status(200).json(dep);
		}else{
			res.sendStatus(500);
		}
  });
});

router.get('/:id', (req, res) => {
	DepLoad.get(req.params.id, (err, depload) => {
		if (err) console.error(err);
		if (depload) {
			res.status(200).json(depload);
		}else{
			res.sendStatus(404);
		}
	});
});

router.get('/:id/files', (req, res) => {
  Upload.getList('files_dep_load', +req.params.id, req.query, (err, rows) => {
		if (err) return res.status(400).json(err);
		if (rows) {
			res.status(200).json(rows);
		} else {
			res.sendStatus(500);
		}
	});
});

router.post('/', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/dep_load');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const data = req.body;
		const depLoad = new DepLoad(data);
		depLoad.save((err, id) => {
			if ( err ) return res.status(400).json(err);
			if ( id ) {
				res.location(`/api/dep_load/${id}`);
				res.sendStatus(201)
			} 
		});
  } catch(e) {
    console.error(e);
    res.sendStatus(500);
  }
});

router.put('/discipline/:discipline_id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied});

    DepLoad.updateDiscipline(+req.params.discipline_id, req.body, (err, id) => {
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

router.post('/discipline/teacher', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/dep_load');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    DepLoad.setTeacher(req.body, (err, id) => {
			if ( err ) return res.status(400).json(err);
			if ( id ) {
				return res.sendStatus(200);
			}
		})
  } catch(e) {
    console.error(e);
    res.sendStatus(500);
  }
});

router.delete('/:id', async (req, res) => {
	try {
		const access = await Access(req.user, req.method, '/dep_load', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied });

		DepLoad.delete(+req.params.id, (err) => {
			if ( err ) return res.status(409).json(err);
			res.sendStatus(204);
		})
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

module.exports = router;