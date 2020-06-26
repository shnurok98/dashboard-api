const connection = require('../db');
const bcrypt = require('bcrypt');

const saltRounds = 12; // длина соли

const { strFilter, strOrderBy } = require('../utils/db');
const message = require('../messages');

const fields = `
	t.id,
	t.position,
	t.rank_id,
	ra."name" as rank_name,
	t.degree_id,
	dg."name" as degree_name, 
	t.rate,
	t.hours_worked,
	t.rinc,
	t.web_of_science,
	t.scopus, 
	p.id AS person_id, 
	p."name", 
	p.surname, 
	p.patronymic,
	p.birthday,
	p.phone,
	p.email,
	rr."role",
	su.id as sub_unit_id,
	su."name" as sub_unit_name,
	de.id as department_id,
	de."name" as department_name
`;

/**
	 * @memberof Teacher
	 * @typedef {Teacher} Teacher
	 * 
	 * @property {Number} id
	 * @property {Number} person_id
	 * @property {String} position
	 * @property {Number} rank_id
	 * @property {Number} degree_id
	 * @property {Number} rate
	 * @property {Number} hours_worked
	 * @property {Number} rinc
	 * @property {Number} web_of_science
	 * @property {Number} scopus
	 * @property {String} login
	 * @property {String} password
	 * @property {String} salt
	 * @property {String} role
	 */

/**
 * Класс описывающий преподавателя
 */
class Teacher {
	/**
	 * Создать экземпляр преподавателя
	 * @param {Teacher} obj 
	 */ 
	constructor(obj){
		for(let key in obj){
			this[key] = obj[key];
		}
	}
	
	/**
	 * Метод сохранения
	 * @param {Function} cb 
	 */
	save(cb){
		if(this.id){
			this.update(cb); // если есть id, то обновляем
		}else{
			this.hashPassword((err) => {
				if (err) return cb(err);

				let obj = this;

				connection.one(`
					SELECT public.pr_teachers_i(
						$<obj.name>::text,
						$<obj.surname>::text,
						$<obj.patronymic>::text,
						$<obj.birthday>,
						$<obj.phone>::text,
						$<obj.email>::text,
						2::smallint,
						$<obj.position>::text,
						$<obj.rank_id>,
						$<obj.degree_id>,
						$<obj.rate>::real,
						$<obj.hours_worked>,
						$<obj.rinc>::real,
						$<obj.web_of_science>::real,
						$<obj.scopus>::real,
						$<obj.login>::text,
						$<obj.password>::text,
						$<obj.salt>::text, 
						$<obj.role>::smallint, 
						$<obj.sub_unit_id>) AS teacher;
				`, { obj })
				.then(data => {
					if (data === undefined) return cb(console.log(new Error('Не удалось создать преподавателя')));
					this.id = data.teacher.id; // присваиваем экземпляру id возвращенный из бд
					cb(null, this.id);
				})
				.catch(err => {
					if ( err.constraint === "teachers_login_key" ) return cb({message: message.loginExist});
					if ( err.constraint === "personalities_email_key" ) return cb({message: message.emailExist});
					cb(err)
				})
			});
		}
	}

	update(cb){
		let obj = this;
		connection.one(`
		SELECT public.pr_teachers_u(
			$<obj.id>,
			$<obj.name>::text,
			$<obj.surname>::text,
			$<obj.patronymic>::text,
			$<obj.birthday>,
			$<obj.phone>::text,
			$<obj.email>::text,
			$<obj.position>::text,
			$<obj.rank_id>,
			$<obj.degree_id>,
			$<obj.rate>::real,
			$<obj.hours_worked>,
			$<obj.rinc>::real,
			$<obj.web_of_science>::real,
			$<obj.scopus>::real) AS id;
		`, { obj })
		.then( data  => {
			if ( data.id === null ) return cb();
			cb(null, data.id);
		})
		.catch(err => {
			if ( err.constraint === "personalities_email_key" ) return cb({message: message.emailExist});
			cb(err)
		});
	}

	/**
	 * Функция хэширования пароля
	 * @private
	 * @param {Function} cb 
	 */
	hashPassword(cb){
		bcrypt.genSalt(saltRounds, (err, salt) => {
			if(err) return cb(err);
			this.salt = salt;
			bcrypt.hash(this.password, salt, (err, hash) => {
				if(err) return cb(err);
				this.password = hash;
				cb();
			});
		});
	}

	/**
	 * Получение преподавателя по login
	 * @param {String} login логин искомого пользователя
	 * @param {Function} cb 
	 */
	static getByLogin(login, cb){
		connection.oneOrNone(`
		SELECT 
			T.id,
			T.login,
			T.password,
			T.salt,
			P.id AS person_id, 
			P.name, 
			P.surname, 
			P.patronymic,
			P.email,
			P.status
		FROM teachers T, personalities P
		WHERE T.person_id = P.id AND T.login = $1;
		`, [login])
		.then((row) => {
			if (row === undefined || row === null) return cb();
			cb(null, new Teacher(row));
		})
		.catch(err => cb(err));
	}

	/**
	 * Метод для авторизации пользователя
	 * @param {String} login логин пользователя
	 * @param {String} password пароль пользователя
	 * @param {Function} cb 
	 */
	static authenticate(login, password, cb){
		Teacher.getByLogin(login, (err, user) => {
			if(err) return cb(err);
			if(!user) return cb();
			bcrypt.hash(password, user.salt, (err, hash) => {
				if(err) return cb(err);
				if(hash == user.password) return cb(null, user);
				cb();
			});
		});
	}

	/**
	 * Получение полной информации о преподавателе
	 * @param {Number} id id преподавателя
	 * @param {Function} cb 
	 */
	static get(id, cb){
		connection.oneOrNone(`
			SELECT 
				${fields}
			FROM 
				teachers t
			left join 
				personalities p on t.person_id = p.id
			left join 
				rights_roles rr on t.id = rr.teacher_id
			left join 
				sub_unit su on rr.sub_unit_id = su.id
			left join 
				department de on su.department_id = de.id 
			left join 
				"ranks" ra on t.rank_id = ra.id 
			left join 
				"degree" dg on t.degree_id = dg.id
			where 
				t.id = $1;`, [id])
		.then((user) => {
			if (user === undefined || user === null) return cb();
			// user.role = String(user.role);
			cb(null, new Teacher(user));
		})
		.catch(err =>	{
			cb(err)
		});
	}

	static getAll(query, cb){
		const limit = (query.limit <= 100 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 't.id',
			'position': 't.position',
			'rank_name': 'ra.name',
			'degree_name': 'dg.name',
			'rate': 't.rate',
			'hours_worked': 't.hours_worked',
			'rinc': 't.rinc',
			'web_of_science': 't.web_of_science',
			'scopus': 't.scopus',
			'surname': 'p.surname',
			'sub_unit_name': 'su.name',
			'department_name': 'de.name'
		}

		let orderBy = query.orderBy || ' ORDER BY t.id ';
		if (orderBy !== ' ORDER BY t.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
			SELECT 
				${fields}
			FROM 
				teachers t
			left join 
				personalities p on t.person_id = p.id
			left join 
				rights_roles rr on t.id = rr.teacher_id
			left join 
				sub_unit su on rr.sub_unit_id = su.id
			left join 
				department de on su.department_id = de.id 
			left join 
				"ranks" ra on t.rank_id = ra.id 
			left join 
				"degree" dg on t.degree_id = dg.id
			${filter}
			${orderBy} 
			LIMIT ${limit}
			OFFSET ${offset};
			`)
		.then((rows) => {
			cb(null, rows);
		})
		.catch(err => cb(err));
	}

	/**
	 * Метод для обновления пароля
	 * @param {String} pass - новый пароль
	 * @param {Function} cb 
	 */
	updatePass(pass, cb) {
		this.password = pass;
		this.hashPassword(err => {
			if (err) return cb(err);

			connection.one(`
			UPDATE teachers 
			SET password = $1, salt = $2 
			where id = $3
			returning id;`, [this.password, this.salt, this.id])
			.then(data => {
				if (data === undefined) return cb();
				cb(null, data.id);
			})
			.catch(err => cb(err))
		})

	}

	static getDisciplines(id, query, cb){
		const limit = (query.limit <= 100 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 'd.id',
			'name': 'd.name',
			"hours_con_project": 'd.hours_con_project',
			"hours_lec": 'd.hours_lec',
			"hours_sem": 'd.hours_sem',
			"hours_lab": 'd.hours_lab',
			"hours_con_exam": 'd.hours_con_exam',
			"hours_zachet": 'd.hours_zachet',
			"hours_exam": 'd.hours_exam',
			"hours_kurs_project": 'd.hours_kurs_project',
			"hours_gek": 'd.hours_gek',
			"hours_ruk_prakt": 'd.hours_ruk_prakt',
			"hours_ruk_vkr": 'd.hours_ruk_vkr',
			"hours_ruk_mag": 'd.hours_ruk_mag',
			"hours_ruk_aspirant": 'd.hours_ruk_aspirant',
			"semester_num": 'd.semester_num',
			"is_approved": 'd.is_approved'
		}

		let orderBy = query.orderBy || ' ORDER BY d.id ';
		if (orderBy !== ' ORDER BY d.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
			SELECT 
				d.*
			FROM 
				disciplines d
			INNER JOIN
				disciplines_teachers dt ON dt.discipline_id = d.id AND dt.teacher_id = ${id}
			${filter}
			${orderBy} 
			LIMIT ${limit}
			OFFSET ${offset};
			`)
		.then((rows) => {
			cb(null, rows);
		})
		.catch(err => cb(err));
	
	}

	static getProjects(id, query, cb){
		const limit = (query.limit <= 100 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 'pj.id',
			'name': 'pj.name',
			'begin_date': 'pj.begin_date',
			'end_date': 'pj.end_date',
			'link_trello': 'pj.link_trello',
			'sub_unit_id': 'pj.sub_unit_id',
			'teacher_id': 'pj.teacher_id'
		}

		let orderBy = query.orderBy || ' ORDER BY pj.id ';
		if (orderBy !== ' ORDER BY pj.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') {
			filter = strFilter(fieldsList, filter);
			if (filter === null) return cb({message: message.badFilter});
			filter += ` AND pj.teacher_id = ${id} `;
		} else {
			filter = ` WHERE pj.teacher_id = ${id} `;
		}
		

		connection.manyOrNone(`
			SELECT 
				pj.*
			FROM 
				projects pj
			${filter}
			${orderBy} 
			LIMIT ${limit}
			OFFSET ${offset};
			`)
		.then((rows) => {
			cb(null, rows);
		})
		.catch(err => cb(err));
	
	}

	static delete(id, cb) {
		const sql = `DELETE FROM teachers where id = ${id};`

		connection.none(sql)
		.then( () => {
			cb()
		})
		.catch(err => { 
			console.error(err);
			cb(err)
		});
	}
}

module.exports = Teacher;