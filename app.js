const express = require('express');
const bodyParser = require('body-parser');

const cors = require('cors');

const auth = require('./routes/auth');

const PORT = require('./config').port;
const strategy = require('./middleware/jwt');
const passport = require('passport');

const debug = require('./routes/debug');
const teachers = require('./routes/teachers');
const students = require('./routes/students');
const groups = require('./routes/groups');
const specialties = require('./routes/specialties');
const acad_plan = require('./routes/acad_plan');

const files = require('./routes/files');
const department_load = require('./routes/department_load');

passport.use(strategy);

const app = express();

app.use(passport.initialize());


app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.use('/api/debug', debug);

app.use('/api/teachers', passport.authenticate('jwt', { session: false }), teachers);
app.use('/api/files', passport.authenticate('jwt', { session: false }), files);
app.use('/api/dep_load', department_load);

app.use('/api/students', students);
app.use('/api/groups', groups);
app.use('/api/specialties', specialties);
app.use('/api/acad_plan', acad_plan);

app.post('/api/users/register', auth.register);
app.post('/api/users/login', auth.logIn);
app.get('/api/users/logout', auth.logOut);

app.get('/api/', (req, res) => {
	res.send('<h1>Api is live</h1>')
})

app.listen(PORT, () => {
	console.log('API started on localhost:' + PORT);
});