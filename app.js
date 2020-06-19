const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const PORT = require('./config').port;

const auth = require('./routes/auth');
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
const dep_load = require('./routes/dep_load');
const dictionaries = require('./routes/dictionaries');

passport.use(strategy);

const app = express();

app.use(passport.initialize());

app.use(cors()); // включаем CORS заголовки
app.use(bodyParser.json({limit: '10mb'})); // парсинг json
app.use(bodyParser.urlencoded({limit: '10mb', extended: true})); // парсинг formdata

app.use('/api/debug', debug);

app.post('/api/auth', auth.logIn);

app.get('/api/', (req, res) => {
	res.send('<h1>Api is live</h1>')
});


// req.user виден после passport.initialize
app.use('*', passport.authenticate('jwt', { session: false }) );

app.use('/api/teachers', teachers);
app.use('/api/uploads', uploads);
app.use('/api/dep_load', dep_load);
app.use('/api/students', students);
app.use('/api/groups', groups);
app.use('/api/specialties', specialties);
app.use('/api/acad_plan', acad_plan);
app.use('/api/projects', projects);

app.use('/api/department', dictionaries);
app.use('/api/ranks', dictionaries);
// degree, sub_unit

app.listen(PORT, () => {
	console.log('API started on localhost:' + PORT);
});