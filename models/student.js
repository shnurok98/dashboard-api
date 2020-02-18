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
			SELECT S.*,  
			FROM students AS S 
			INNER JOIN personalities AS P 
				ON S.id_person = P.id and S.id = $1
			INNER JOIN 
		`)
	}
}