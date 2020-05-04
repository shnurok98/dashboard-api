const connection = require('./db');

const rights = require('./acl');

const mapping = require('./utils/db').mapping;

/**
 * Получаем владельца ресурса
 * @param {*} teacher 
 * @param {*} resource_id 
 */
function getRights(teacher, table, resource_id){
  console.log('Проверка владельца ресурса');
  return new Promise((resolve, reject) => { 
    connection.one(`select (select 1 from ${table} p where p.id = ${resource_id} and p.teacher_id = ${teacher.id}) is not null exist`)
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
 * @param {String} url - ссылка на ресурс
 * @param {*} resource_id - id ресурса в виде '/link'
 */
async function access(user, method, url, resource_id){
  console.log({role: user.role, method, url, resource_id})
  if ( rights[user.role][method][url] === 'forbid' ) return false;
  if ( rights[user.role][method][url] === 'allow' ) {
    return true;
  }
  else if ( rights[user.role][method][url] === 'self' ){
    // Проходимся по ролям
    // Админу полный доступ (его вообще не должно быть здесь)
    if (user.role == 4) return true;
    //Сразу откидываем ситуацию с изменением своего аккаунта
    if (url === '/teachers' && method === 'PUT') {
      return user.id == resource_id ? true : false
    };

    // РОП
    if (user.role == 3) {
      // РОП пока что меняет все направления
      return true;
    }
    // Преподаватель
    if (user.role == 2) {
      const table = mapping[url];
      return await getRights(user, table, resource_id);
    }
    // Вьюер
    if (user.role == 1) {
      // Не требует доплнительных проверок
    }
  }

}

module.exports = access;