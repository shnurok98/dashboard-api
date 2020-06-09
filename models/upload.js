const connection = require('../db');
const path = require('path');

const { strFilter, strOrderBy } = require('../utils/db');

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

    const limit = (query.limit <= 100 ? query.limit : false) || 25;
    const offset = query.offset || 0;
    
    let orderBy = query.orderBy || 'modified_date DESC';
		if (orderBy !== 'modified_date DESC') orderBy = strOrderBy(null, orderBy);

		let filter = query.filter || '';
		if (filter !== '') filter = strFilter(null, filter);

    connection.manyOrNone(`
    SELECT ${fields[table].select} 
    FROM ${table} 
    WHERE ${fields[table].link} = ${link_id}
    ${filter}
    ORDER BY ${orderBy}
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
}

module.exports = Upload;