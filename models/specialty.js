const connection = require('../db');

const { strFilter, strOrderBy, strSet } = require('../utils/db');
const message = require('../messages');

const fields = `
	sp.*,
	su.name sub_unit_name
`;


/**
 * Класс описывающий специальность
 */
class Specialty {
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

				connection.one('insert into specialties ( ${obj:name} ) values (${obj:csv}) returning id;', { obj })
				.then(data => {
					if (data.id === undefined) return cb(console.log(new Error('Не удалось создать specialty')));
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

	update(cb){
		let obj = this;

		const str = strSet(obj);

		connection.one(`
			UPDATE specialties SET ${str} where id = ${this.id} returning id;
		`)
		.then( data  => {
			if ( data.id === undefined || data.id === null) return cb();
			cb(null, data.id);
		})
		.catch((err) => {
			// if ( err.constraint === "groups_name_key" ) return cb({message: message.exist});
			cb(err)
		});
	}

	static get(id, cb){
		connection.oneOrNone(`
			SELECT 
				${fields}
			FROM 
				specialties sp
			left join 
				sub_unit su on su.id = sp.sub_unit_id
			WHERE sp.id = $1;`, [id])
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, new Specialty(rows));
		})
		.catch(err => cb(err));
	}

	static getAll(query, cb){
		// можно вынести дефолтные значения в конфиг выше
		const limit = (query.limit <= 1000 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 'sp.id',
			'code': 'sp.code',
			'name': 'sp.name',
			'profile': 'sp.profile',
			'educ_form': 'sp.educ_form',
			'educ_programm': 'sp.educ_programm',
			'educ_years': 'sp.educ_years',
			'year_join': 'sp.year_join',
			'sub_unit_id': 'su.id',
			'sub_unit_name': 'su.name'
		}

		let orderBy = query.orderBy || ' ORDER BY sp.id ';
		if (orderBy !== ' ORDER BY sp.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
			SELECT 
				${fields}
			FROM 
				specialties sp
			left join 
				sub_unit su on su.id = sp.sub_unit_id
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

}

module.exports = Specialty;