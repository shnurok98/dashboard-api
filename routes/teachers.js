const express = require('express');
const router = express.Router();

const Teacher = require('../models/teacher');
const Upload = require('../models/upload');

const Access = require('../middleware/rights');
const { prefix } = require('../config').api;

router.use('*', async (req, res, next) => {
	try {
		const url = req.baseUrl.replace(prefix, '');
		const partsUrl = url.match(/\/\w+/g); // все части вида '/word'
		// console.log(partsUrl);
		const parentUrl = partsUrl[0];
		let resourceId = partsUrl[1];
		if ( resourceId ) resourceId = resourceId.substring(1, resourceId.length);
		
		// система прав
		const access = await Access(req.user, req.method, parentUrl, resourceId);
		if ( !access ) return res.sendStatus(403);

		next();
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
})

router.get('/', (req, res) => {
	Teacher.getAll(req.query, (err, teachers) => {
		if (err) return res.status(400).json(err);
		if (teachers) {
			res.status(200).json(teachers);
		}else{
			res.sendStatus(500);
		}
	});
});

router.get('/:id', (req, res) => {
	Teacher.get(req.params.id, (err, teacher) => {
		if (err) console.error(err);
		if (teacher) {
			res.status(200).json(teacher);
		}else{
			res.sendStatus(404);
		}
	});
});

// /:id/files_ind_plan ИЛИ /:id/files_rpd
router.get('/:id' + /files_(ind_plan|rpd)/, (req, res) => {
	// получаем таблицу из url по регулярке
	const table = req.url.match(/files_(ind_plan|rpd)/)[0];
	
	Upload.getList(table, +req.params.id, req.query, (err, rows) => {
		if (err) return res.status(400).json(err);
		if (rows) {
			res.status(200).json(rows);
		} else {
			res.sendStatus(500);
		}
	});
});

router.get('/:id/disciplines', (req, res) => {
	Teacher.getDisciplines(+req.params.id, req.query, (err, disciplines) => {
		if (err) return res.status(400).json(err);
		if (disciplines) {
			res.status(200).json(disciplines);
		}else{
			res.sendStatus(500);
		}
	});
});

router.get('/:id/projects', (req, res) => {
	Teacher.getProjects(+req.params.id, req.query, (err, projects) => {
		if (err) return res.status(400).json(err);
		if (projects) {
			res.status(200).json(projects);
		}else{
			res.sendStatus(500);
		}
	});
});

router.post('/', async (req, res) => {
	try {
		const data = req.body;
	  teacher = new Teacher(data);
		teacher.save((err, id) => {
			if ( err ) return res.status(400).json(err);
			if ( id ) {
				res.location(`/api/teachers/${id}`);
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
		const teacher = new Teacher(req.body);
		
		teacher.id = +req.params.id;
		
		teacher.save((err, id) => {
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

router.put('/:id/password', async (req, res) => {
	try {
		Teacher.get(+req.params.id, (err, teacher) => {
			if ( err ) return res.status(400).json(err);
			if ( teacher ) {
				teacher.updatePass(req.body.password, (err, id) => {
					if ( err ) return res.status(400).json(err);
					if ( id ) {
						res.sendStatus(204);
					} else {
						res.sendStatus(404);
					}
				})
			} else {
				res.sendStatus(404);
			}
		});
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

router.delete('/:id', async (req, res) => {
	try {
		Teacher.delete(+req.params.id, (err) => {
			if ( err ) return res.status(409).json(err);
			res.sendStatus(204);
		})
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

module.exports = router;