const connection = require('../db');
const path = require('path');

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

}

module.exports = Upload;