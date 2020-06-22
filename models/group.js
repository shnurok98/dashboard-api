const connection = require('../db');

const { strFilter, strOrderBy, strSet } = require('../utils/db');
const message = require('../messages');

const fields = `
  g.*, 
  sp.name specialties_name, 
  sp.code specialties_code, 
  sp.sub_unit_id,
  su.name sub_unit_name 
`;

/**
 * Класс описывающий группу
 */
class Group {
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

				connection.one('insert into groups ( ${obj:name} ) values (${obj:csv}) returning id;', { obj })
				.then(data => {
					if (data.id === undefined) return cb(console.log(new Error('Не удалось создать group')));
					this.id = data.id; // присваиваем экземпляру id возвращенный из бд
					cb(null, this.id);
				})
				.catch(err => {
					if ( err.constraint === "groups_name_key" ) return cb({message: message.exist});
					console.error(err);
					cb(err)
				})

		}
	}

	update(cb){
		let obj = this;

		const str = strSet(obj);

		connection.one(`
			UPDATE groups SET ${str} where id = ${this.id} returning id;
		`)
		.then( data  => {
			if ( data.id === undefined || data.id === null) return cb();
			cb(null, data.id);
		})
		.catch((err) => {
			if ( err.constraint === "groups_name_key" ) return cb({message: message.exist});
			cb(err)
		});
	}

	static get(id, cb){
		connection.oneOrNone(`
			SELECT 
				${fields}
			FROM "groups" g
			left join specialties sp on g.specialties_id = sp.id
			LEFT JOIN sub_unit su ON sp.sub_unit_id = su.id
			WHERE g.id = $1;`, [id])
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, new Group(rows));
		})
		.catch(err => cb(err));
	}

	static getAll(query, cb){
		// можно вынести дефолтные значения в конфиг выше
		const limit = (query.limit <= 1000 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 'g.id',
			'name': 'g.name',
			'specialties_id': 'sp.id',
			'specialties_name': 'sp.name',
			'specialties_code': 'sp.code',
			'sub_unit_id': 'su.id',
			'sub_unit_name': 'su.name'
		}

		let orderBy = query.orderBy || ' ORDER BY g.id ';
		if (orderBy !== ' ORDER BY g.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
			SELECT 
				${fields}
			FROM "groups" g
			left join specialties sp on g.specialties_id = sp.id
			LEFT JOIN sub_unit su ON sp.sub_unit_id = su.id
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

module.exports = Group;