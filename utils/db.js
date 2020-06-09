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
 * Применяет фильтр с помощью дополнения для WHERE
 * @param {String} self алиас для основной таблицы
 * @param {Object} filter строка req.query
 * @returns {String} готовая строка
 */
exports.strFilter = (self, filter) => {
  let arr = filter.split(' ');

  // если алиас !== null то нужна подстановка алиаса 
  if (self !== null){
    let mark = arr[0].lastIndexOf('_');
    let con = arr[0].substring(mark + 1);
    if (mark !== -1 && ( con === 'id' || con === 'name' ) ){
      // значит это внешняя таблица
      arr[0] = alias[arr[0].substring(0, mark)] + '.' + con // если таблица
    } else {
      // значит это поле данной сущности
      arr[0] = self + '.' + arr[0]; // если поле
      
    }
  }

  // подмена оператора на SQL
  arr[1] = operators[arr[1]];
  filter = ' AND ' + arr.join(' ') + ' ';

  // console.log(filter);
  return filter;
}

exports.strOrderBy = (self, orderBy) => {
  let arr = orderBy.split(' ');

  // если алиас !== null то нужна подстановка алиаса 
  if (self !== null){
    let mark = arr[0].lastIndexOf('_');
    let con = arr[0].substring(mark + 1);
    if (mark !== -1 && ( con === 'id' || con === 'name' ) ){
      // значит это внешняя таблица
      arr[0] = alias[arr[0].substring(0, mark)] + '.' + con // если таблица
    } else {
      // значит это поле данной сущности
      arr[0] = self + '.' + arr[0]; // если поле
      
    }
  }

  orderBy = arr.join(' ')
  // console.log(orderBy)
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
  'teacher': 'T',
  'person': 'P',
  'rights_roles': 'RR',
  'sub_unit': 'SU',
  'department': 'DE'
}

const operators = {
  'eq': '=',
  'ne': '<>',
  'gt': '>',
  'ge': '>=',
  'lt': '<',
  'le': '<='
};