const connection = require('../db');

const { strFilter, strOrderBy, strSet } = require('../utils/db');
const message = require('../messages');
const Dict = require('./dict');

const fields = `
  acp.*,
  sp.code,
  sp.name,
  sp.profile,
  sp.educ_form,
  sp.educ_programm,
  sp.educ_years,
  sp.year_join,
  sp.sub_unit_id
`;

const parameters = {
	limit: {
		max: 10000,
		default: 1000
	}
}

/**
 * Класс описывающий учебный план
 */
class AcadPlan {
	constructor(obj){
		for(let key in obj){
			this[key] = obj[key];
		}
	}


	save(cb){
		let obj = this;

		connection.one('SELECT public.pr_acadplan_i($1::jsonb) id;', [obj ])
		.then(data => {
			if (data.id === undefined) return cb(console.log(new Error('Не удалось создать acadPlan')));
			this.id = data.id; // присваиваем экземпляру id возвращенный из бд
			cb(null, this.id);
		})
		.catch(err => {
			if ( err.constraint === "acad_plan_specialties_id_key" ) return cb({message: message.acCrFail});
			if ( err.constraint === "acad_plan_specialties_id_fkey" ) return cb({message: message.spNotExist});
			console.error(err);
			cb(err)
		})
	}

	static get(id, cb){
		connection.oneOrNone(`
		SELECT public.pr_acadplan_s(${id}) acad_plan;
		`)
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, new AcadPlan(rows.acad_plan));
		})
		.catch(err => cb(err));
	}

	static getAll(query, cb){
		// можно вынести дефолтные значения в конфиг выше
		const limit = (query.limit <= parameters.limit.max ? query.limit : false) || parameters.limit.default;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 'acp.id',
			'modified_date': 'acp.modified_date',
			'specialties_id': 'sp.id',
			'code': 'sp.code',
			'name': 'sp.name',
			'profile': 'sp.profile',
			'educ_form': 'sp.educ_form',
			'educ_programm': 'sp.educ_programm',
			'educ_years': 'sp.educ_years',
			'year_join': 'date_part(\'year\', sp.year_join)'
		}

		let orderBy = query.orderBy || ' ORDER BY acp.id ';
		if (orderBy !== ' ORDER BY acp.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
		SELECT 
			${fields}
		FROM acad_plan AS acp
		LEFT JOIN specialties sp ON sp.id = acp.specialties_id
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

	// Disciplines

	static getSemester(id, semester, cb) {
		connection.manyOrNone(`
		SELECT * from acad_discipline acd
		where acd.acad_plan_id = ${id} AND acd.semesters[${semester}] IS NOT NULL;
		`)
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, rows)
		})
		.catch(err => {
			cb(err);
		})
	}

	static updateDiscipline(id, body, cb) {
		const str = strSet(body);

		connection.oneOrNone(`
    UPDATE acad_discipline SET ${str} where id = ${id} returning id;
    `)
    .then(rows => {
      if (!rows) return cb();
			cb(null, rows.id)
		})
		.catch(err => {
			if ( err.constraint ) return cb({message: err.detail})
			console.error(err);
			cb(err)
		})
	}

	static getDir(table, id, cb) {
		Dict.get(table, id, (err, dir) => {
			if ( err ) return cb(err);
			if ( dir ) {
				cb(null, dir)
			} else {
				cb()
			}
		})
	}

	static updateDir(table, id, body, cb) {
		const dir = new Dict(body);
		dir.id = id;

		dir.save(table, (err, dir) => {
			if ( err ) return cb(err);
			if ( dir ) {
				cb(null, dir)
			} else {
				cb()
			}
		})
	}

	static delete(id, cb) {
		const sql = `DELETE FROM acad_plan where id = ${id};`

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

module.exports = AcadPlan;