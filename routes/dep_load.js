const express = require('express');
const router = express.Router();

const Access = require('../middleware/rights');
const DepLoad = require('../models/dep_load');
const Upload = require('../models/upload');
const { prefix } = require('../config').api;

router.use('*', async(req, res, next) => {
    try {
        const url = req.baseUrl.replace(prefix, '');
        const partsUrl = url.match(/\/\w+/g); // все части вида '/word'
        // console.log(partsUrl);
        const parentUrl = partsUrl[0];
        let resourceId = partsUrl[1];
        if (resourceId) resourceId = resourceId.substring(1, resourceId.length);

        // система прав
        const access = await Access(req.user, req.method, parentUrl, resourceId);
        if (!access) return res.sendStatus(403);

        next();
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
})

router.get('/', (req, res) => {
    DepLoad.getAll(req.query, (err, dep) => {
        if (err) return res.status(400).json(err);
        if (dep) {
            res.status(200).json(dep);
        } else {
            res.sendStatus(500);
        }
    });
});

router.get('/:id', (req, res) => {
    DepLoad.get(req.params.id, (err, depload) => {
        if (err) console.error(err);
        if (depload) {
            res.status(200).json(depload);
        } else {
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

router.post('/', async(req, res) => {
    try {
        const data = req.body;
        const depLoad = new DepLoad(data);
        depLoad.save((err, id) => {
            if (err) return res.status(400).json(err);
            if (id) {
                res.location(`/api/dep_load/${id}`);
                res.status(201).json({ id: id });
                res.sendStatus(201)
            }
        });
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
});

router.put('/discipline/:discipline_id', async(req, res) => {
    try {
        DepLoad.updateDiscipline(+req.params.discipline_id, req.body, (err, id) => {
            if (err) return res.status(400).json(err);
            if (id) {
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

router.post('/discipline/teacher', async(req, res) => {
    try {
        DepLoad.setTeacher(req.body, (err, id) => {
            if (err) return res.status(400).json(err);
            if (id) {
                return res.sendStatus(200);
            }
        })
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
});

router.delete('/:id', async(req, res) => {
    try {
        DepLoad.delete(+req.params.id, (err) => {
            if (err) return res.status(409).json(err);
            res.sendStatus(204);
        })
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
});

module.exports = router;