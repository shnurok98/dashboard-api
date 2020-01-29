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

app.use('/users', users);
app.use('/teachers', passport.authenticate('jwt', { session: false }), teachers);
app.use('/files', files);
app.use('/department_load', department_load);

app.post('/register', auth.register);
app.post('/login', auth.logIn);
app.get('/logout', auth.logOut);

app.get('/', (req, res) => {
	res.send('<h1>Api is live</h1>')
})

app.listen(PORT, () => {
	console.log('API started on localhost:' + PORT);
});