const connection = require('../db');
const path = require('path');

const { strFilter, strOrderBy } = require('../utils/db');
const message = require('../messages');

const parameters = {
	limit: {
		max: 10000,
		default: 1000
	}
}

/**
 * Класс описывающий файлы
 */
class Upload {

  static getFile(table, file_id, cb){
    connection.oneOrNone(`
    select * 
    from files_${table} 
    WHERE id = ${file_id}`)
    .then(rows => {
      if (rows === undefined || rows === null) return cb();
      cb(null, rows);
    })
    .catch(err => {
      console.error(err)
      cb(err)
    })
  }

  static saveFile(table, file, fields, cb){

    fields.ext = path.extname(file.name);
    fields.name = file.name;
    fields.path = file.path;
    fields.modified_date = file.lastModifiedDate;

    console.log(fields);

    connection.one(`
    INSERT INTO files_${table}(
      $<this:name>
    ) VALUES (
      $<this:csv>
    ) RETURNING *;`, fields)
    .then(rows => {
      cb(null, rows);
    })
    .catch(err => {
      console.error(err)
      cb(err)
    })
  }

  
  /**
   * Выдают список файлов. Внутрь вшита обработка параметров.
   * @param {String} table целевая таблица
   * @param {Number} link_id целевой id ресурса (определение поля вшито)
   * @param {Object} query строка с праметрами URL
   * @param {Object} cb 
   */
  static getList(table, link_id, query, cb){
    const fields = {
      'files_ind_plan': {
        'select': ' id, name, ext, modified_date, teacher_id, sub_unit_id ',
        'link': ' teacher_id '
      },
      'files_rpd': {
        'select': ' id, name, ext, modified_date, teacher_id, sub_unit_id, discipline_id ',
        'link': ' teacher_id '
      },
      'files_acad_plan': {
        'select': ' id, name, ext, modified_date, teacher_id, sub_unit_id, acad_plan_id ',
        'link': ' acad_plan_id '
      },
      'files_dep_load': {
        'select': ' id, name, ext, modified_date, teacher_id, sub_unit_id, dep_load_id ',
        'link': ' dep_load_id '
      },
      'files_projects': {
        'select': ' id, name, ext, modified_date, teacher_id, sub_unit_id, project_id ',
        'link': ' project_id '
      }
    };

    const fieldsList = {
      'id': 'id',
      'name': 'name',
      'ext': 'ext',
      'modified_date': 'modified_date',
      'teacher_id': 'teacher_id',
      'sub_unit_id': 'sub_unit_id',
      'discipline_id': 'discipline_id',
      'acad_plan_id': 'acad_plan_id',
      'dep_load_id': 'dep_load_id',
      'project_id': 'project_id'
    }

    const limit = (query.limit <= parameters.limit.max ? query.limit : false) || parameters.limit.default;
    const offset = query.offset || 0;
    
    let orderBy = query.orderBy || ' ORDER BY modified_date DESC ';
		if (orderBy !== ' ORDER BY modified_date DESC ') orderBy = strOrderBy(fieldsList, orderBy);
    if (orderBy === null) return cb({message: message.badOrder})

		let filter = query.filter || '';
		if (filter !== '') {
      filter = strFilter(fieldsList, filter);
      if (filter === null) return cb({message: message.badFilter})
      filter += ` AND ${fields[table].link} = ${link_id} `;
    } else {
      filter = ` WHERE ${fields[table].link} = ${link_id} `;
    }

    connection.manyOrNone(`
    SELECT ${fields[table].select} 
    FROM ${table} 
    ${filter}
    ${orderBy}
    LIMIT ${limit}
    OFFSET ${offset};
    `)
    .then(rows => {
      cb(null, rows);
    })
    .catch(err => {
      console.error(err);
      cb(err);
    })
  }

  static delete(table, id, cb) {
		const sql = `DELETE FROM files_${table} where id = ${id};`

		connection.none(sql)
		.then( () => {
			cb()
		})
		.catch(err => { 
			console.error(err);
			cb(err)
		});
  }
  
}

module.exports = Upload;