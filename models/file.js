const connection = require('../db');
const path = require('path');

class File {
  static ind_plan({name: title, path: link, lastModifiedDate: date}, id_teacher){
    const ext = path.extname(title);
    connection.one(`
    INSERT INTO files_ind_plan (
      title,
      link,
      ext,
      date,
      id_teacher
    ) VALUES (
      $<this:csv>
    ) RETURNING *;`, {
      title,
      link,
      ext,
      date,
      id_teacher
    })
    .then(res => {
      console.log(res);
    })
    .catch(err => console.error(err))
  }
}

module.exports = File;