const connection = require('../db');

const rights = require('../acl');

const mapping = require('../utils/db').mapping;

/**
 * Получаем владельца ресурса
 * @param {*} teacher 
 * @param {*} resource_id 
 */
function getRights(teacher, method, table, resource_id){
  console.log('Проверка владельца ресурса');
  let sql;

  if (teacher.role == 3) sql = `select (select 1 from ${table} p where p.id = ${resource_id} and p.sub_unit_id = ${teacher.sub_unit_id}) is not null exist`;
  if (teacher.role == 2) sql = `select (select 1 from ${table} p where p.id = ${resource_id} and p.teacher_id = ${teacher.id}) is not null exist`;

  return new Promise((resolve, reject) => { 
    connection.one(sql)
    .then(row => {
      resolve(row.exist);
    })
    .catch(err => {
      console.log(err)
      reject(false);
    });
  })
}

/**
 * Проверяет доступ к роуту и к ресурсу
 * @param {Teacher} user - пользователь от которого запрос
 * @param {String} method - метод HTTP
 * @param {String} url - ссылка на ресурс в виде '/link'
 * @param {*} resource_id - id ресурса 
 */
async function access(user, method, url, resource_id){
  console.log({role: user.role, method, url, resource_id})
  if ( rights[user.role][method][url] === 'forbid' ) return false;
  if ( rights[user.role][method][url] === 'allow' ) {
    return true;
  }
  else if ( rights[user.role][method][url] === 'self' ){
    // Сразу откидываем ситуацию с изменением своего аккаунта
    if (url === '/teachers' && method === 'PUT') {
      return user.id == resource_id ? true : false
    };

    // РОП
    if (user.role == 3) {
      const table = mapping[url];
      return await getRights(user, method, table, resource_id);
    }
    // Преподаватель
    if (user.role == 2) {
      const table = mapping[url];
      return await getRights(user, method, table, resource_id);
    }
  }

}

module.exports = access;