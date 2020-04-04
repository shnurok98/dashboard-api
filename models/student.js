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
				G.name   
			FROM students AS S, personalities AS P, groups AS G 
			WHERE S.id = $1 AND S.person_id = P.id AND S.group_id = G.id
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
				G.name   
			FROM students AS S, personalities AS P, groups AS G 
			WHERE S.group_id = $1 AND S.person_id = P.id AND S.group_id = G.id
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
				G.name,
				SP.code,
				SP.name,
				SP.profile,
				SP.educ_form,
				SP.educ_programm,
				SP.educ_years,
				SP.year_join,
				SP.acad_plan_id,
				SP.sub_unit_id   
			FROM students AS S, personalities AS P, groups AS G, specialties AS SP 
			WHERE G.specialties_id = $1 AND S.person_id = P.id AND S.group_id = G.id
		`, [specialty_id])
		.then(rows => {
			if (rows === undefined) return cb();
			if (rows === null) return cb();
			cb(null, rows);
		})
		.catch(err => cb(err));
	}

	// isOwner(user_id, resource_id)

	// Лучший вариант
	/**
	 * Проверка прав
	 * @param {Teacher} teacher_id 
	 * @param {String} method 
	 * @param {Object} resource 
	 */
	static isOwner(teacher_id, method, resource){
		const roles = "select * from rights_roles rr where rr.teacher_id = " + teacher_id;
		if (roles.teacher && roles.length == 1) { return false};
		if (roles.rop) {
			switch(method){
				case 'POST':
					return rop.sub_unit_id == resource.sub_unit_id ? true : false;
				case 'PUT':
				case 'DELETE':
					return sql = `select 
					(select 1 
						from 
						students s, 
						groups g, 
						specialties sp 
						where s.id = ${resource.id} 
						AND s.group_id = g.id 
						AND g.specialties_id = sp.id 
						AND sp.sub_unit_id = ${rop.sub_unit_id}) IS NOT NULL exists`;
				default: 
					return false;
			}
		}
	}
}

module.exports = Student;