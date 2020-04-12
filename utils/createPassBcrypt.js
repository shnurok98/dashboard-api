const Teacher = require('../models/teacher.js');

// Нужно добавить поля password и salt в выдачу из Teacher.get

/**
 * Изменение пароля вписанного в базу вручную
 */
Teacher.get(1, (err, teacher) => {
  if (err) console.error(err);
  console.log(teacher);
  teacher.fromSql((err, res) => {
    if (err) console.error(err);

    console.log(res);
  });
})