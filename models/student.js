const connection = require('../db');

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
					this.id = data.student.id; // присваиваем экземпляру id возвращенный из бд
					cb();
				})
				.catch(err => cb(err))

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
			$<obj.group_id>) AS updated_student_id;
		`, { obj })
		.then( data  => {
			if ( data === undefined ) return cb(console.log(new Error('Не удалось обновить данные student')));
			cb();
		})
		.catch((err) => {
			cb(err);
		});
	}

	static get(id, cb){
		connection.oneOrNone(`
			SELECT 
				S.*,
				P.id AS person_id, 
				P.name, 
				P.surname, 
				P.patronymic,
				P.birthday,
				P.phone,
				P.email,
				P.status,
				G.id AS group_id,
				G.specialties_id,
				G.name AS group_name   
			FROM students AS S, personalities AS P, groups AS G 
			WHERE S.id = $1 AND S.person_id = P.id AND S.group_id = G.id
		`, [id])
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, new Student(rows));
		})
		.catch(err => cb(err));
	}

	static getByGroup(group_id, cb){
		connection.manyOrNone(`
			SELECT 
				S.*,
				P.id AS person_id, 
				P.name, 
				P.surname, 
				P.patronymic,
				P.birthday,
				P.phone,
				P.email,
				P.status,
				G.id AS group_id,
				G.specialties_id,
				G.name AS group_name  
			FROM students AS S, personalities AS P, groups AS G 
			WHERE S.group_id = $1 AND S.person_id = P.id AND S.group_id = G.id
		`, [group_id])
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, rows);
		})
		.catch(err => cb(err));
	}

	static getBySpecialty(specialty_id, cb){
		connection.manyOrNone(`
			SELECT 
				S.*,
				P.id AS person_id, 
				P.name, 
				P.surname, 
				P.patronymic,
				P.birthday,
				P.phone,
				P.email,
				P.status,
				G.id AS group_id,
				G.specialties_id,
				G.name AS group_name,
				SP.code,
				SP.name AS specialty_name,
				SP.profile,
				SP.educ_form,
				SP.educ_programm,
				SP.educ_years,
				SP.year_join,
				SP.sub_unit_id   
			FROM students AS S, personalities AS P, groups AS G, specialties AS SP 
			WHERE G.specialties_id = $1 AND S.person_id = P.id AND S.group_id = G.id
		`, [specialty_id])
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			cb(null, rows);
		})
		.catch(err => cb(err));
	}
}

module.exports = Student;