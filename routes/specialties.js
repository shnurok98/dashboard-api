const express = require('express');
const router = express.Router();

const Access = require('../middleware/rights');
const Specialty = require('../models/specialty');
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
  Specialty.getAll(req.query, (err, specialties) => {
    if (err) return res.status(400).json(err);
		if (specialties) {
			res.status(200).json(specialties);
		}else{
			res.sendStatus(500);
		}
  });
});

router.get('/:id', (req, res) => {
  Specialty.get(req.params.id, (err, specialty) => {
		if (err) console.error(err);
		if (specialty) {
			res.status(200).json(specialty);
		}else{
			res.sendStatus(404);
		}
	});
});

router.post('/', async (req, res) => {
  try {
    const data = req.body;
		const specialty = new Specialty(data);
		specialty.save((err, id) => {
			if ( err ) return res.status(400).json(err);
			if ( id ) {
				res.location(`/api/specialties/${id}`);
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
    const specialty = new Specialty(req.body);
		
		specialty.id = +req.params.id;
		
		specialty.save((err, id) => {
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

router.delete('/:id', async (req, res) => {
	try {
		Specialty.delete(+req.params.id, (err) => {
			if ( err ) return res.status(409).json(err);
			res.sendStatus(204);
		})
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

module.exports = router;