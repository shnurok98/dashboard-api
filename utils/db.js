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
 * Формирует предложение WHERE
 * @param {Object} fields объект с полями и алиасами для них
 * @param {String} filter поле для фильтрации
 * @example
 * strFilter({'field': 'alias.field'}, 'field eq 100')
 * // где alias - алиас для таблицы 
 * // returns ' WHERE alias.field = 100 '
 */
exports.strFilter = (fields, filter) => {
  let arr = filter.split(' ');

  // меняем на поле с алиасом
  if ( fields[arr[0]] ) {
    arr[0] = fields[arr[0]];
  } else {
    return null; // такого фильтра нет
  }

  // подмена оператора на SQL
  if ( operators[arr[1]] ) {
    arr[1] = operators[arr[1]];
  } else {
    return null; // такого оператора нет
  }
  
  // составляем предложение SQL
  filter = ' WHERE ' + arr.join(' ') + ' ';

  return filter;
}

/**
 * Формирует предложение ORDER BY
 * @param {Object} fields объект с полями и алиасами для них
 * @param {String} orderBy поле для сортировки
 * @example
 * strOrder({'field': 'alias.field'}, 'field DESC')
 * // где alias - алиас для таблицы 
 * // returns ' ORDER BY alias.field DESC '
 */
exports.strOrderBy = (fields, orderBy) => {
  let arr = orderBy.split(' ');

  // меняем на поле с алиасом
  if (fields[arr[0]]) {
    arr[0] = fields[arr[0]];
  } else {
    return null; // такой сортировки нет
  }

  orderBy = ' ORDER BY ' + arr.join(' ') + ' ';
  
  return orderBy;
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

const alias = {
  'teacher': 't',
  'person': 'p',
  'rights_roles': 'rr',
  'sub_unit': 'su',
  'department': 'de',
  'disciplines': 'd',
  'disciplines_teachers': 'dt',
  'rank': 'ra',
  'degree': 'dg',
  'dep_load': 'dl',
  'projects': 'pj'
}

const operators = {
  'eq': '=',
  'ne': '<>',
  'gt': '>',
  'ge': '>=',
  'lt': '<',
  'le': '<='
};