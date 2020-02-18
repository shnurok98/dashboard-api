const connection = require('../db');
const bcrypt = require('bcrypt');

const saltRounds = 12;

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

				let obj = this;

				/**
				 * @see http://vitaly-t.github.io/pg-promise/Database.html#task
				 * @see http://vitaly-t.github.io/pg-promise/Database.html#tx
				 */
				connection.task(t => {
					return t.oneOrNone(`
					INSERT INTO personalities (
						name, 
						surname, 
						patronymic, 
						birthday, 
						phone, 
						email, 
						status
					) 
					VALUES (
						$<obj.name>, 
						$<obj.surname>, 
						$<obj.patronymic>, 
						$<obj.birthday>, 
						$<obj.phone>, 
						$<obj.email>, 
						$<obj.status>
					)
					RETURNING id;`, 
					{
						obj
					})
					.then(person => {
						return t.oneOrNone(`
						INSERT INTO teachers (
							id_person,
							position,
							rate,
							hours_worked,
							"RINC",
							web_of_science,
							scopus,
							login,
							password,
							salt
						) 
						VALUES (
							$<person.id>,
							$<obj.position>,
							$<obj.rate>,
							$<obj.hours_worked>,
							$<obj.RINC>,
							$<obj.web_of_science>,
							$<obj.scopus>,
							$<obj.login>,
							$<obj.password>,
							$<obj.salt>
						) 
						RETURNING id;`,
						{
							obj, 
							person
						})
					});

				})
				.then(data => {
					if (data === undefined) return cb(console.log(new Error('Не удалось создать преподавателя')));
					this.id = data.id;
					cb();
				})
				.catch((err) => cb(err))
				
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
			SELECT 
				T.*, 
				P.id AS id_person, 
				P.name, 
				P.surname, 
				P.patronymic,
				P.birthday,
				P.phone,
				P.email,
				P.status
			FROM teachers AS T 
			INNER JOIN personalities AS P
			ON T.id_person = P.id and T.id = $1;
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

	toJSON(){
		return {
			id: this.id,
			id_person: this.id_person,
			name: this.name,
			surname: this.surname,
			patronymic: this.patronymic,
			birthday: this.birthday,
			phone: this.phone,
			email: this.email,
			position: this.position,
			id_rank: this.id_rank,
			id_degree: this.id_degree,
			rate: this.rate,
			hours_worked: this.hours_worked,
			RINC: this.RINC,
			web_of_science: this.web_of_science,
			scopus: this.scopus,
			status: this.status
		}
	}
}

module.exports = Teacher;