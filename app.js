const express = require('express');
const bodyParser = require('body-parser');

const auth = require('./routes/auth');

const PORT = require('./config').port;
const strategy = require('./middleware/jwt');
const passport = require('passport');

const users = require('./routes/users');
const teachers = require('./routes/teachers');
const files = require('./routes/files');
const department_load = require('./routes/department_load');

passport.use(strategy);

const app = express();

app.use(passport.initialize());

// можно использовать npm CORS
const allowCrossDomain = function (req, res, next) {
	res.header('Access-Control-Allow-Origin', '*');
	res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
	res.header('Access-Control-Allow-Headers', 'Content-Type');
	next();
};

app.use(allowCrossDomain);
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.use('/api/users', users);
app.use('/api/teachers', passport.authenticate('jwt', { session: false }), teachers);
app.use('/api/files', files);
app.use('/api/department_load', department_load);

app.post('/api/register', auth.register);
app.post('/api/login', auth.logIn);
app.get('/api/logout', auth.logOut);

app.get('/api/', (req, res) => {
	res.send('<h1>Api is live</h1>')
})

app.listen(PORT, () => {
	console.log('API started on localhost:' + PORT);
});