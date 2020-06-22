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
class Project {
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

				connection.one('insert into projects ( ${obj:name} ) values (${obj:csv}) returning id;', { obj })
				.then(data => {
					if (data.id === undefined) return cb(console.log(new Error('Не удалось создать project')));
					this.id = data.id; // присваиваем экземпляру id возвращенный из бд
					cb(null, this.id);
				})
				.catch(err => {
					// if ( err.constraint === "groups_name_key" ) return cb({message: message.exist});
					console.error(err);
					cb(err)
				})

		}
	}

	update(cb){
		let obj = this;

		const str = strSet(obj);

		connection.one(`
			UPDATE projects SET ${str} where id = ${this.id} returning id;
		`)
		.then( data  => {
			if ( data.id === undefined || data.id === null) return cb();
			cb(null, data.id);
		})
		.catch((err) => {
			// if ( err.constraint === "groups_name_key" ) return cb({message: message.exist});
			cb(err)
		});
	}

	static get(id, cb){
		connection.oneOrNone(`
			select public.pr_projects_s($1) as project;
		`, [id])
		.then(rows => {
			if (rows === undefined || rows === null) return cb();
			const project = new Project(rows.project)
			cb(null, project);
		})
		.catch(err => cb(err));
	}

	static getAll(query, cb){
		// можно вынести дефолтные значения в конфиг выше
		const limit = (query.limit <= 1000 ? query.limit : false) || 25;
		const offset = query.offset || 0;

		const fieldsList = {
			'id': 'pj.id',
			'name': 'pj.name',
			'begin_date': 'pj.begin_date',
			'end_date': 'pj.end_date',
			'link_trello': 'pj.link_trello',
			'sub_unit_id': 'pj.sub_unit_id',
			'teacher_id': 'pj.teacher_id'
		}

		let orderBy = query.orderBy || ' ORDER BY pj.id ';
		if (orderBy !== ' ORDER BY pj.id ') orderBy = strOrderBy(fieldsList, orderBy);
		if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(fieldsList, filter);
		if (filter === null) return cb({message: message.badFilter})

		connection.manyOrNone(`
			SELECT 
				pj.*,
				count(spj.id) students_count 
			FROM projects pj  
			LEFT JOIN students_projects spj ON pj.id = spj.project_id 
			${filter}
			GROUP BY pj.id
			${orderBy} 
			LIMIT ${limit}
			OFFSET ${offset};
			`)
		.then((rows) => {
			cb(null, rows);
		})
		.catch(err => cb(err));
	}

	static setStudents(id, students, cb){
		connection.one(`
			SELECT public.pr_projects_students_i(${id}, $1) as id;
		`, [students])
    .then(rows => {
			console.log(rows);
      if (!rows) return cb();
      cb(null, rows.id)
    })
    .catch(err => {
			// такого проекта не сущ
			if (err.code == 23503) return cb();
			console.error(err);
			cb(err);
		})
	}
}

module.exports = Project;