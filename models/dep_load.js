const connection = require('../db');

const { strFilter, strOrderBy, strSet } = require('../utils/db');
const message = require('../messages');

const fields = `
	dl.*,
	de.name department_name
`;


/**
 * Класс описывающий нагрузку
 */
class DepLoad {
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

				connection.one('SELECT public.pr_depload_i($1::jsonb) id;', [obj])
				.then(data => {
					if (data.id === undefined) return cb(console.log(new Error('Не удалось создать depload')));
					this.id = data.id; // присваиваем экземпляру id возвращенный из бд
					cb(null, this.id);
				})
				.catch(err => {
					// if ( err.constraint === "groups_name_key" ) return cb({message: message.exist});
					console.error(err);
					cb(err)
				})

		}
	}

	static get(id, cb){
		connection.oneOrNone(`
			SELECT public.pr_depload_s(${id}) dep_load;
		`, [id])
		.then(rows => {
			if (!rows.dep_load) return cb();
			cb(null, new DepLoad(rows.dep_load));
		})
		.catch(err => cb(err));
	}

	static getAll(query, cb){
		// можно вынести дефолтные значения в конфиг выше
		const limit = (query.limit <= 1000 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 'dl.id',
			'department_id': 'de.id',
			'begin_date': 'dl.begin_date',
			'end_date': 'dl.end_date',
			'modified_date': 'dl.modified_date',
			'department_name': 'de.name'
		}

		let orderBy = query.orderBy || ' ORDER BY dl.id ';
		if (orderBy !== ' ORDER BY dl.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
			SELECT 
				${fields}
			FROM 
				dep_load dl
			left join 
				department de ON de.id = dl.department_id
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

	static updateDiscipline(id, body, cb) {
		connection.oneOrNone(`
			SELECT public.pr_discipline_u($1, $2) id;
			`, [id, body])
    .then(rows => {
      if (!rows.id) return cb()
      cb(null, rows.id)
		})
		.catch(err => {
			console.error(err);
			cb(err);
		});
	}

	static setTeacher(body, cb) {
		connection.one('INSERT INTO disciplines_teachers (discipline_id, teacher_id) VALUES ($1, $2) RETURNING id;', [+body.discipline_id, +body.teacher_id ])
    .then(rows => {
      cb(null, rows.id)
		})
		.catch(err => {
			if ( err.constraint ) return cb({ message: err.detail });
			console.error(err);
			cb(err)
		})
	}

	static delete(id, cb) {
		const sql = `DELETE FROM dep_load where id = ${id};`

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

module.exports = DepLoad;