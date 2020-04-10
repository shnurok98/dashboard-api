const connection = require('../db');
const Path = require('path');

class Upload {

  static getFile(table, file_id, cb){
    connection.one(`
    select * 
    from files_${table} 
    WHERE id = ${file_id}`)
    .then(rows => {
      cb(null, rows);
    })
    .catch(err => {
      console.error(err)
      cb(err)
    })
  }

  static ind_plan({name: name, path: path, lastModifiedDate: modified_date}, teacher_id, cb){
    const ext = Path.extname(name);
    connection.one(`
    INSERT INTO files_ind_plan (
      name,
      path,
      ext,
      create_date,
      teacher_id
    ) VALUES (
      $<this:csv>
    ) RETURNING *;`, {
      name,
      path,
      ext,
      modified_date,
      teacher_id
    })
    .then(rows => {
      cb(null, rows);
    })
    .catch(err => {
      console.error(err)
      cb(err)
    })
  }

  static projects({name: name, path: path, lastModifiedDate: modified_date}, teacher_id, project_id, cb){
    const ext = Path.extname(name);
    connection.one(`
    INSERT INTO files_projects (
      name,
      path,
      ext,
      create_date,
      teacher_id,
      project_id
    ) VALUES (
      $<this:csv>
    ) RETURNING *;`, {
      name,
      path,
      ext,
      modified_date,
      teacher_id,
      project_id
    })
    .then(rows => {
      cb(null, rows);
    })
    .catch(err => {
      console.error(err)
      cb(err)
    })
  }

  static rpd({name: name, path: path, lastModifiedDate: modified_date}, teacher_id, discipline_id, cb){
    const ext = Path.extname(name);
    connection.one(`
    INSERT INTO files_rpd (
      name,
      path,
      ext,
      create_date,
      teacher_id,
      discipline_id
    ) VALUES (
      $<this:csv>
    ) RETURNING *;`, {
      name,
      path,
      ext,
      modified_date,
      teacher_id,
      discipline_id
    })
    .then(rows => {
      cb(null, rows);
    })
    .catch(err => {
      console.error(err)
      cb(err)
    })
  }

  static acad_plan({name: name, path: path, lastModifiedDate: modified_date}, teacher_id, acad_plan_id, cb){
    const ext = Path.extname(name);
    connection.one(`
    INSERT INTO files_acad_plan (
      name,
      path,
      ext,
      create_date,
      teacher_id,
      acad_plan_id
    ) VALUES (
      $<this:csv>
    ) RETURNING *;`, {
      name,
      path,
      ext,
      modified_date,
      teacher_id,
      acad_plan_id
    })
    .then(rows => {
      cb(null, rows);
    })
    .catch(err => {
      console.error(err)
      cb(err)
    })
  }
}

module.exports = Upload;