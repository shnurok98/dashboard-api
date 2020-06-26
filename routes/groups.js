const express = require('express');
const router = express.Router();

const Access = require('../middleware/rights');
const { prefix } = require('../config').api;
const Group = require('../models/group');

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
  Group.getAll(req.query, (err, groups) => {
		if (err) return res.status(400).json(err);
		if (groups) {
			res.status(200).json(groups);
		}else{
			res.sendStatus(500);
		}
	});
});

router.get('/:id', (req, res) => {
  Group.get(req.params.id, (err, group) => {
		if (err) console.error(err);
		if (group) {
			res.status(200).json(group);
		}else{
			res.sendStatus(404);
		}
	});
});

router.post('/', async (req, res) => {
  try {
    const data = req.body;
		const group = new Group(data);
		group.save((err, id) => {
			if ( err ) return res.status(400).json(err);
			if ( id ) {
				res.location(`/api/groups/${id}`);
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
    const group = new Group(req.body);

    group.id = +req.params.id;

    group.save((err, id) => {
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
		Group.delete(+req.params.id, (err) => {
			if ( err ) return res.status(409).json(err);
			res.sendStatus(204);
		})
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

module.exports = router;