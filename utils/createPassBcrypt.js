const Teacher = require('../models/teacher.js');

/**
 * Изменение пароля вписанного в базу вручную
 */
Teacher.get(5, (err, teacher) => {
  if (err) console.error(err);

  teacher.fromSql((err, res) => {
    if (err) console.error(err);

    console.log(res);
  });
})