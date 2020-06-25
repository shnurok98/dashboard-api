const connection = require('../db');

const message = require('../messages');
const { strSet } = require('../utils/db');

/**
 * Класс описывающий словари (и простые сущности)
 */
class Dict {
	constructor(obj){
		for(let key in obj){
			this[key] = obj[key];
		}
	}

	save(table, cb){
		if(this.id){
			this.update(table, cb); // если есть id, то обновляем
		}else{
				let obj = this;

				connection.one(`
					INSERT INTO $<table:name> ($<obj:name>) VALUES ($<obj:csv>) RETURNING id;
				`, { table, obj })
				.then(data => {
					if (data === undefined) return cb();
					this.id = data.id; // присваиваем экземпляру id возвращенный из бд
					cb(null, this.id);
				})
				.catch(err => {
					// нулевое значение в одном из полей записи (нарушает СЦ)
					if (err.code == '23502') return cb({message: message.badData});
					if (err.constraint === `${table}_name_key`) return cb({message: message.exist});
					console.error(err);
					cb(err);
				})

		}
	}

	update(table, cb){
		const str = strSet(this);
		
		connection.oneOrNone(`
			UPDATE ${table} SET ${str} WHERE id = ${this.id} RETURNING id;
		`)
		.then( data  => {
			if ( data === undefined || data === null ) return cb();
			cb(null, data.id);
		})
		.catch(err => {
			if (err.constraint === `${table}_name_key`) return cb({message: message.exist});
			if (err.code == 23505) return cb({message: message.exist});
			console.error(err);
			cb(err);
		});
	}

	static get(table, id, cb){
		connection.oneOrNone(`
			SELECT * FROM ${table} WHERE id = ${id};
		`)
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, new Dict(rows));
		})
		.catch(err => {
			console.error(err);
			cb(err)
		});
  }
  
  static getAll(table, cb){
    connection.manyOrNone(`
    SELECT * FROM ${table} ORDER BY id;
    `)
    .then(rows => {
      cb(null, rows)
    })
    .catch(err => cb(err));
  }

  static delete(table, id, cb){
		connection.none(`
			DELETE FROM ${table} where id = ${id};
		`)
		.then( () => {
			cb()
		})
		.catch(err => {
			// 23503 - нарушение ограничения внешнего ключа
			if (err.code == 23503) return cb({message: message.deleteFail});
			console.error(err);
			cb(err)
		});
	}
}

module.exports = Dict;