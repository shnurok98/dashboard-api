const User = require('../models/user');
const SECRET = require('../config').secret;
const jwt = require("jsonwebtoken");

exports.logIn = (req, res, next) => {
	const data = req.body.user;
	console.log('User logged:', req.body.user.login);

	User.authenticate(data.login, data.password, (err, user) => {
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

// exports.getId = (req, res) => {
// 	const email = req.params.email;
// 	User.getId(email, (err, id) => {
// 		if (err) return next(err);
// 		if (id){
// 			res.send({id: id});
// 		}else{
// 			res.send({message: 'User not found'});
// 		}
// 	});
// };

// exports.getInfo = (req, res) => {
// 	const id = +req.params.id;
// 	User.get(id, (err, user) => {
// 		if (err) return next(err);
// 		if (user){
// 			if (req.session.uid == user.id){
// 				res.send({
// 					id: user.id,
// 					email: user.email
// 				});
// 			}else{
// 				res.send(user);
// 			}
// 		}else{
// 			res.send({message: 'User not found'});
// 		}
// 	});
// };

exports.logOut = (req, res) => {
	req.logout();
	res.status(200).json({ message: 'Success logOut!' });
};

// служебный
exports.register = (req, res, next) => {
	const data = req.body.user;
	User.getByLogin(data.login, (err, user) => {
		if(err) return next(err);

		if (user) {
			res.send({ message: 'Пользователь с данным login уже существует' });
		}else{
			user = new User(data);
			user.save((err) => {
				if(err) return next(err);
				res.status(200).send({ message: 'Success registration!' });
			});
		}
	});
};