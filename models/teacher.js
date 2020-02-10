const connection = require('../db');
const bcrypt = require('bcrypt');

const saltRounds = 12;

const Person = require('./person');

/**
	 * @memberof Teacher
	 * @typedef {Teacher} Teacher
	 * 
	 * @property {Number} id
	 * @property {Number} id_person
	 * @property {String} position
	 * @property {Number} id_rank
	 * @property {Number} id_degree
	 * @property {Number} rate
	 * @property {Number} hours_worked
	 * @property {Number} RINC
	 * @property {Number} web_of_science
	 * @property {Number} scopus
	 * @property {String} login
	 * @property {String} password
	 * @property {String} salt
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
			this.update(cb);
		}else{
			this.hashPassword((err) => {
				if (err) return cb(err);
				// let obj = { 
				// 	login: this.login,
				// 	// email: this.email, 
				// 	password: this.password, 
				// 	salt: this.salt
				// };
				let obj = this;
				const person = new Person(obj);
				let teacher = {
					position: obj.position,
					rate: obj.rate,
					hours_worked: obj.hours_worked,
					RINC: obj.RINC,
					web_of_science: obj.web_of_science,
					scopus: obj.scopus,
					login: obj.login,
					password: obj.password,
					salt: obj.salt
				}
				person.save((err, id) => {
					if (err) return cb(err);
					teacher.id_person = id;
					connection.oneOrNone('INSERT INTO teachers (${this:name}) VALUES (${this:csv}) RETURNING id;', teacher)
						.then((rows) => {
							if (rows === undefined) return cb(console.log(new Error('Не удалось создать пользователя')));
							this.id = rows.id;
							cb();
						})
						.catch((err) => {
							cb(err);
						});
				})
				
				
			});
		}
	}

	update(cb){
		let obj = {
			id: this.id,
			login: this.login,  
			// email: this.email, 
			password: this.password,  
			salt: this.salt
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
		Teacher.getId(login, (err, id) => {
			if(err) return cb(err);
			Teacher.get(id, cb);
		});
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
	 * Получение id по login
	 * @param {String} login логин искомого пользователя
	 * @param {Function} cb 
	 */
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
		
	}

	/**
	 * Получение полной информации о преподавателе
	 * @param {Number} id id преподавателя
	 * @param {Function} cb 
	 */
	static get(id, cb){
		connection.oneOrNone(`
			select * from teachers inner join personalities on teachers.id_person = personalities.id and teachers.id = $1;
		`, [id])
		.then((user) => {
			if (user === undefined) return cb();
			if (user === null) return cb();
			cb(null, new Teacher(user));
		})
		.catch((err) => {
			cb(err);
		});
	}
}

module.exports = Teacher;