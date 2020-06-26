const connection = require('../db');

const { strFilter, strOrderBy } = require('../utils/db');
const message = require('../messages');

const fields = `
	s.*, 
	p.name, 
	p.surname, 
	p.patronymic,
	p.birthday,
	p.phone,
	p.email,
	g.specialties_id,
	g.name AS group_name,
	sp.name AS specialties_name
`;

const conf = {
	limit: {
		max: 1000,
		default: 25
	},
	orderBy: ' ORDER BY s.id '
}

/**
 * Класс описывающий студента
 */
class Student {
	constructor(obj){
		for(let key in obj){
			this[key] = obj[key];
		}
	}


	save(cb){
		if(this.id){
			this.update(cb); // если есть id, то обновляем
		}else{
				let obj = this;

				connection.one(`
					SELECT public.pr_students_i(
						$<obj.name>::text,
						$<obj.surname>::text,
						$<obj.patronymic>::text,
						$<obj.birthday>,
						$<obj.phone>::text,
						$<obj.email>::text,
						1::smallint, 
						$<obj.group_id>) AS student;
				`, { obj })
				.then(data => {
					if (data === undefined) return cb(console.log(new Error('Не удалось создать student')));
					this.id = data.student; // присваиваем экземпляру id возвращенный из бд
					cb(null, this.id);
				})
				.catch(err => {
					if ( err.constraint === "personalities_email_key" ) return cb({message: message.emailExist});
					cb(err)
				})

		}
	}

	update(cb){
		let obj = this;
		connection.one(`
		SELECT public.pr_students_u(
			$<obj.id>,
			$<obj.name>::text,
			$<obj.surname>::text,
			$<obj.patronymic>::text,
			$<obj.birthday>,
			$<obj.phone>::text,
			$<obj.email>::text,
			1::smallint,
			$<obj.group_id>) AS id;
		`, { obj })
		.then( data  => {
			if ( data.id === undefined || data.id === null) return cb();
			cb(null, data.id);
		})
		.catch((err) => {
			if ( err.constraint === "personalities_email_key" ) return cb({message: message.emailExist});
			cb(err)
		});
	}

	static get(id, cb){
		connection.oneOrNone(`
			SELECT 
				${fields}
			FROM 
				students s
			left join 
				personalities p on s.person_id = p.id
			left join 
				groups g on g.id = s.group_id
			left join 
				specialties sp on sp.id = g.specialties_id
			WHERE s.id = $1;`, [id])
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, new Student(rows));
		})
		.catch(err => cb(err));
	}

	static getAll(query, cb){
		// можно вынести дефолтные значения в конфиг выше
		const limit = (query.limit <= 1000 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 's.id',
			'group_id': 'g.id',
			'group_name': 'g.name',
			'specialties_id': 'sp.id',
			'specialties_name': 'sp.name',
			'surname': 'p.surname',
			'phone': 'p.phone',
			'email': 'p.email',
			'birthday': 'p.birthday'
		}

		let orderBy = query.orderBy || ' ORDER BY s.id ';
		if (orderBy !== ' ORDER BY s.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
			SELECT 
				${fields}
			FROM 
				students s
			left join 
				personalities p on s.person_id = p.id
			left join 
				groups g on g.id = s.group_id
			left join 
				specialties sp on sp.id = g.specialties_id
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
		const sql = `DELETE FROM students where id = ${id};`

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

module.exports = Student;