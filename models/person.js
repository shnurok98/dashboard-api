const connection = require('../db');

class Person {
	constructor(obj){
		for(let key in obj){
			this[key] = obj[key];
		}
	}

	save(cb){
		if(this.id){
			this.update(cb);
		}else{
			let obj = { 
				name: this.name,
				surname: this.surname, 
				patronymic: this.patronymic, 
				birthday: this.birthday,
				phone: this.phone,
				email: this.email,
				status: this.status
			};
			connection.oneOrNone('INSERT INTO personalities (${this:name}) VALUES (${this:csv}) RETURNING id;', obj)
			.then((rows) => {
				if (rows === undefined) return cb(console.log(new Error('Не удалось создать пользователя')));
				this.id = rows.id;
				cb(null, this.id);
			})
			.catch((err) => {
				cb(err);
			});
		}
	}

	static get(id, cb){
		connection.oneOrNone(`
			SELECT * FROM personalities WHERE id = $1;
		`, [id])
		.then((person) => {
			if (person === undefined) return cb();
			if (person === null) return cb();
			cb(null, new Person(person));
		})
		.catch((err) => {
			cb(err);
		});
	}

/*
	update(cb){
		let obj = {
			id: this.id,
			name: this.name,
			surname: this.surname, 
			patronymic: this.patronymic, 
			birthday: this.birthday,
			phone: this.phone,
			email: this.email,
			status: this.status
		};
		connection.oneOrNone('UPDATE teachers SET login = $1, password = $2, salt = $3 WHERE id = $4 RETURNING id;', [obj.login, obj.pass, obj.salt, obj.id])
		.then((rows) => {
			if (rows === undefined) return cb(console.log(new Error('Не удалось обновить данные пользователя')));
			cb();
		})
		.catch((err) => {
			cb(err);
		});
	}

	static getByLogin(login, cb){
		User.getId(login, (err, id) => {
			if(err) return cb(err);
			User.get(id, cb);
		});
	}

	// static getByEmail(email, cb){
	// 	connection.oneOrNone(`
	// 		SELECT * FROM personalities WHERE email = $1;
	// 	`, [email])
	// 	.then((res) => {
	// 		if (res === undefined || res === null) return cb();
	// 		cb(null, res);
	// 	})
	// 	.catch((err) => {
	// 		console.log(err);
	// 		cb(err);
	// 	});
	// }

	static authenticate(login, password, cb){
		User.getByLogin(login, (err, user) => {
			if(err) return cb(err);
			if(!user) return cb();
			bcrypt.hash(password, user.salt, (err, hash) => {
				if(err) return cb(err);
				if(hash == user.password) return cb(null, user);
				cb();
			});
		});
	}

	static getId(login, cb){
		connection.oneOrNone(`
			SELECT teachers.id FROM teachers WHERE login = $1;
		`, [login])
		.then((rows) => {
			if (rows === undefined) return cb();
			if (rows === null) return cb();
			cb(null, rows.id);
		})
		.catch((err) => {
			cb(err);
		});
		
	}*/
}

module.exports = Person;