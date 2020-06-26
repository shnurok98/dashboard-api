const express = require('express');
const router = express.Router();

const connection = require('../db');

const Access = require('../rights');
const message = require('../messages');
const Project = require('../models/project');
const Upload = require('../models/upload');

router.get('/', (req, res) => {
  Project.getAll(req.query, (err, projects) => {
		if (err) return res.status(400).json(err);
		if (projects) {
			res.status(200).json(projects);
		}else{
			res.sendStatus(500);
		}
	});
});

router.get('/:id', (req, res) => {
  Project.get(req.params.id, (err, project) => {
		if (err) console.error(err);
		if (project) {
			res.status(200).json(project);
		}else{
			res.sendStatus(404);
		}
	});
});

router.get('/:id/files', (req, res) => {
  Upload.getList('files_projects', +req.params.id, req.query, (err, rows) => {
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
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const data = req.body;
		const project = new Project(data);
		project.save((err, id) => {
			if ( err ) return res.status(400).json(err);
			if ( id ) {
				res.location(`/api/projects/${id}`);
				res.sendStatus(201)
			} 
		});
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
});

router.put('/:id', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    const project = new Project(req.body);
		
		project.id = +req.params.id;
		
		project.save((err, id) => {
			if ( err ) {
				return res.status(400).json(err);
			}
			if ( id ) {
				res.sendStatus(204)
			} else {
				res.sendStatus(404)
			}
		});
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
});

router.put('/:id/students', async (req, res) => {
  try {
    const access = await Access(req.user, req.method, '/projects', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

    Project.setStudents(+req.params.id, req.body, (err, id) => {
      if ( err ) return res.status(400).json(err);
      if ( id ){
        res.sendStatus(200)
      } else {
        res.sendStatus(404)
      }
    });

  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
});

router.delete('/:id', async (req, res) => {
	try {
		const access = await Access(req.user, req.method, '/projects', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied });

		Project.delete(+req.params.id, (err) => {
			if ( err ) return res.status(409).json(err);
			res.sendStatus(204);
		})
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

module.exports = router;