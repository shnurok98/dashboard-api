const express = require('express');
const router = express.Router();

const Access = require('../middleware/rights');
const Dict = require('../models/dict');

const { prefix } = require('../config').api;

router.use('*', async (req, res, next) => {
	try {
		const table = req.baseUrl.match(/department|ranks|degree|sub_unit/)[0];

		const url = req.baseUrl.replace(prefix, '');
		const partsUrl = url.match(/\/\w+/g); // все части вида '/word'
		// console.log(partsUrl);
		const parentUrl = partsUrl[0];
		let resourceId = partsUrl[1];
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

router.get('/', (req, res) => {
	const table = res.locals.table;
	Dict.getAll(table, (err, rows) => {
		if ( err ) return console.error(err);
		if ( rows ) {
			res.status(200).json(rows);
		} else {
			res.sendStatus(500);
		}
	})
});

router.get('/:id', (req, res) => {
	const table = res.locals.table;
	const id = +req.params.id;
	Dict.get(table, id, (err, rows) => {
		if ( err ) console.error(err);
		if ( rows ) {
			res.status(200).json(rows);
		} else {
			res.sendStatus(404);
		}
	})
});

router.post('/', async (req, res) => {
	try {
		const table = res.locals.table;

		dict = new Dict(req.body);
		dict.save(table, (err, id) => {
			if ( err ) return res.status(400).json(err)
			if ( id ) {
				res.location(`/api/${table}/${id}`);
				res.sendStatus(201)
			}
		})
	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

router.put('/:id', async (req, res) => {
	try {
		const table = res.locals.table;

		const dict = new Dict(req.body);
		dict.id = +req.params.id;

		dict.save(table, (err, id) => {
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

router.delete('/:id', async (req, res) => {
	try {
		const table = res.locals.table;
		const id = +req.params.id;

		Dict.delete(table, id, (err) => {
			if ( err ) return res.status(409).json(err);
			res.sendStatus(204);
		})

	} catch (e) {
		console.error(e);
		res.sendStatus(500);
  }
});

module.exports = router;