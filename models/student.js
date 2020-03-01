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

	static get(id, cb){
		connection.oneOrNone(`
			SELECT 
				S.*,
				P.id AS id_person, 
				P.name, 
				P.surname, 
				P.patronymic,
				P.birthday,
				P.phone,
				P.email,
				P.status,
				G.id AS id_group,
				G.id_specialties,
				G.name   
			FROM students AS S, personalities AS P, groups AS G 
			WHERE S.id = $1 AND S.id_person = P.id AND S.id_group = G.id
		`, [id])
		.then(rows => {
			if (rows === undefined) return cb();
			if (rows === null) return cb();
			cb(null, new Student(rows));
		})
		.catch(err => cb(err));
	}

	static getByGroup(group_id, cb){
		connection.manyOrNone(`
			SELECT 
				S.*,
				P.id AS id_person, 
				P.name, 
				P.surname, 
				P.patronymic,
				P.birthday,
				P.phone,
				P.email,
				P.status,
				G.id AS id_group,
				G.id_specialties,
				G.name   
			FROM students AS S, personalities AS P, groups AS G 
			WHERE S.id_group = $1 AND S.id_person = P.id AND S.id_group = G.id
		`, [group_id])
		.then(rows => {
			if (rows === undefined) return cb();
			if (rows === null) return cb();
			cb(null, rows);
		})
		.catch(err => cb(err));
	}

	static getBySpecialty(specialty_id, cb){
		connection.manyOrNone(`
			SELECT 
				S.*,
				P.id AS id_person, 
				P.name, 
				P.surname, 
				P.patronymic,
				P.birthday,
				P.phone,
				P.email,
				P.status,
				G.id AS id_group,
				G.id_specialties,
				G.name,
				SP.code,
				SP.title,
				SP.profile,
				SP.educ_form,
				SP.educ_programm,
				SP.educ_years,
				SP.year_join,
				SP.id_acad_plan,
				SP.id_sub_unit   
			FROM students AS S, personalities AS P, groups AS G, specialties AS SP 
			WHERE G.id_specialties = $1 AND S.id_person = P.id AND S.id_group = G.id
		`, [specialty_id])
		.then(rows => {
			if (rows === undefined) return cb();
			if (rows === null) return cb();
			cb(null, rows);
		})
		.catch(err => cb(err));
	}
}

module.exports = Student;