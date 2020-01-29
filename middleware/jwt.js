const SECRET = require('../config').secret;
const User = require('../models/user');

const passportJWT = require("passport-jwt");

const ExtractJWT = passportJWT.ExtractJwt;
const JwtStrategy = passportJWT.Strategy;

const jwtOptions = {};
jwtOptions.jwtFromRequest = ExtractJWT.fromAuthHeaderAsBearerToken();
jwtOptions.secretOrKey = SECRET;

let strategy = new JwtStrategy(jwtOptions, function(jwt_payload, next) {
	// console.log('payload received', jwt_payload);
  // usually this would be a database call:
  User.get(jwt_payload.id, (err, user) => {
  	if (err) return next(err);
  	if (user) {
  		next(null, user);
  	} else {
  		next(null, false);
  	}
  });  
});

module.exports = strategy;