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


/*
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
}*/

exports.strFilter = (fields, filter) => {
  let arr = filter.split(' ');

  // меняем на поле с алиасом
  if (fields[arr[0]]) {
    arr[0] = fields[arr[0]];
  } else {
    return null; // такого фильтра нет
  }
  // подмена оператора на SQL
  arr[1] = operators[arr[1]];
  filter = ' AND ' + arr.join(' ') + ' ';

  
  return filter;
}

exports.strOrderBy = (fields, orderBy) => {
  let arr = orderBy.split(' ');

  // меняем на поле с алиасом
  if (fields[arr[0]]) {
    arr[0] = fields[arr[0]];
  } else {
    return null; // такой сортировки нет
  }

  orderBy = arr.join(' ')
  
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
  'department': 'DE',
  'disciplines': 'D',
  'disciplines_teachers': 'DT',
  'rank': 'RA',
  'degree': 'DG'
}

const operators = {
  'eq': '=',
  'ne': '<>',
  'gt': '>',
  'ge': '>=',
  'lt': '<',
  'le': '<='
};