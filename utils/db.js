/**
 * Формирует SQL предложение для оператора SET
 * @param {Object} obj - объект с данными
 * @returns {String} готовая строка
 */
exports.strSet = (obj) => {
  let str = '';
  for (key in obj){
    str += key + ' = \'' + obj[key] + '\', ';
  }
  str = str.substring(0, str.length - 2);
  return str;
}

// UPLOADS ???
/**
 * Маппинг точек входа на таблицы БД
 * @todo Что делать с uploads???
 */
exports.mapping = {
  '/teachers': 'teachers', 
  '/students': 'students', 
  '/groups': 'groups', 
  '/specialties': 'specialties', 
  '/acad_plan': 'acad_plan', 
  '/dep_load': 'disciplines', 
  '/projects': 'projects', 
  '/department': 'department',
  '/uploads': '???'
};