const Teacher = require('../models/teacher');
const SECRET = require('../config').secret;
const jwt = require("jsonwebtoken");

exports.logIn = (req, res, next) => {
	const data = req.body;
	console.log('Teacher logged:', data.login);

	Teacher.authenticate(data.login, data.password, (err, user) => {
		if (err) return next(err);
		if (user) {
			const payload = { id: user.id };
			const token = jwt.sign(payload, SECRET);
			res.status(200).send({ message: 'Success logIn!', token: token });
		}else{
			res.status(401).json({ message: 'Sorry! invalid credentials.' });
		}
	});
};