const express = require('express');
const router = express.Router();

const Access = require('../rights');
const message = require('../messages');

const Group = require('../models/group');

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
    const access = await Access(req.user, req.method, '/groups');
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

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
    const access = await Access(req.user, req.method, '/groups', req.params.id);
    if ( !access ) return res.status(403).json({ message: message.accessDenied });

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
		const access = await Access(req.user, req.method, '/groups', req.params.id);
		if ( !access ) return res.status(403).json({ message: message.accessDenied });

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