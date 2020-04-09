const connection = require('../db');
const Path = require('path');

class Upload {
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
}

module.exports = Upload;