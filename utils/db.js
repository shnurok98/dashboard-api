/**
 * Формирует SQL предложение для оператора SET
 * @param {Object} obj - объект с данными
 * @returns {String} готовая строка
 */
exports.strSet = (obj) => {
  let str = '';
  
  for (key in obj){
    if (Array.isArray(obj[key])){
      str += key + ' = \'{' + obj[key] + '}\', ';
      continue;
    }
    if (obj[key] == null || isFinite(obj[key]) ) {
      str += key + ' = ' + obj[key] + ', ';
      continue;
    }
    str += key + ' = \'' + obj[key] + '\', ';
  }
  
  str = str.substring(0, str.length - 2);
  return str;
}

/**
 * Маппинг точек входа на таблицы БД
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
  '/uploads/ind_plan': 'files_ind_plan',
  '/uploads/projects': 'files_projects',
  '/uploads/rpd': 'files_rpd',
  '/uploads/acad_plan': 'files_acad_plan',
  '/uploads/dep_load': 'files_dep_load',
};