const connection = require('../db');
const bcrypt = require('bcrypt');

const saltRounds = 12;

const fields = `
	T.id,
	T.position,
	T.rank_id,
	T.degree_id,
	T.rate,
	T.hours_worked,
	T.rinc,
	T.web_of_science,
	T.scopus, 
	P.id AS person_id, 
	P.name, 
	P.surname, 
	P.patronymic,
	P.birthday,
	P.phone,
	P.email,
	P.status
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
	 * Служебная функция для смены пароля, записанного в базу вручную (костыль)
	 * @param {Function} cb 
	 */
	fromSql(cb){
		this.hashPassword(err => {
			if (err) return cb(err);

			connection.one(`
			UPDATE teachers 
			SET password = $1, salt = $2
			WHERE id = $3
			RETURNING *;
			`, [this.password, this.salt, this.id])
			.then(row => {
				if (row === undefined) return cb(err);
				cb(null, row);
			})
			.catch((err) => {
				cb(err);
			});
		})
	}

	/**
	 * Получение преподавателя по login (служебная)
	 * @param {String} login логин искомого пользователя
	 * @param {Function} cb 
	 * @todo Сделать её private
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
			if (row === undefined) return cb();
			if (row === null) return cb();
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
				${fields},
				rr.role
			FROM teachers AS T, personalities AS P, rights_roles rr 
			where T.person_id = P.id and T.id = $1 and rr.teacher_id = $1
			order by rr."role" desc
			limit 1;
		`, [id])
		.then((user) => {
			if (user === undefined) return cb();
			if (user === null) return cb();
			user.role = String(user.role);
			cb(null, new Teacher(user));
		})
		.catch((err) => {
			cb(err);
		});
	}

	static getAll(cb){
		connection.many(`
			SELECT 
				${fields}
			FROM teachers AS T, personalities AS P
			WHERE T.person_id = P.id ORDER BY P.surname;
			`)
		.then((rows) => {
			cb(null, rows);
		})
		.catch(err => cb(err));
	}

	/**
	 * Проверка прав
	 * @param {Teacher} teacher_id 
	 * @param {String} method 
	 * @param {Object} resource 
	 */
	static isOwner(teacher, method, resource_id){
		if (teacher.role < '4'){
			if (teacher.id == resource_id) return true;
		}
		if (teacher.role == '4'){
			return true;
		}
		return false;
	}
}

module.exports = Teacher;