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
const projects = require('./routes/projects');

const uploads = require('./routes/uploads');
const department_load = require('./routes/department_load');


const department = require('./routes/department');


passport.use(strategy);

const app = express();

app.use(passport.initialize());


app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

app.use('/api/debug', debug);


// app.post('/api/users/register', auth.register);
app.post('/api/users/login', auth.logIn);
app.get('/api/users/logout', auth.logOut);

app.get('/api/', (req, res) => {
	res.send('<h1>Api is live</h1>')
});


// req.user виден после passport.initialize
app.use('*', passport.authenticate('jwt', { session: false }) );

app.use('/api/teachers', teachers);
app.use('/api/uploads', uploads);

app.use('/api/dep_load', department_load);

app.use('/api/students', students);
app.use('/api/groups', groups);
app.use('/api/specialties', specialties);
app.use('/api/acad_plan', acad_plan);
app.use('/api/projects', projects);

app.use('/api/department', department);

app.listen(PORT, () => {
	console.log('API started on localhost:' + PORT);
});