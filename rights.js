const connection = require('./db');

// UPLOADS ???

// allow - полный доступ 
// self - только для владельца или РОПа 
// forbid - запрещено
const rights = {
  1: {
    'GET': {
      '/teachers': 'allow', 
      '/students': 'allow', 
      '/groups': 'allow', 
      '/specialties': 'allow', 
      '/acad_plan': 'allow', 
      '/dep_load': 'allow', 
      '/projects': 'allow', 
      '/uploads': 'allow', 
      '/department': 'allow'
    },
    'POST': {
      '/teachers': 'forbid',
      '/students': 'forbid', 
      '/groups': 'forbid', 
      '/specialties': 'forbid', 
      '/acad_plan': 'forbid', 
      '/dep_load': 'forbid', 
      '/projects': 'forbid', 
      '/uploads': 'forbid', 
      '/department': 'forbid'
    },
    'PUT': {
      '/teachers': 'self',
      '/students': 'forbid', 
      '/groups': 'forbid', 
      '/specialties': 'forbid', 
      '/acad_plan': 'forbid', 
      '/dep_load': 'forbid', 
      '/projects': 'forbid', 
      '/uploads': 'forbid', 
      '/department': 'forbid'
    },
    'DELETE': {
      '/teachers': 'forbid',
      '/students': 'forbid', 
      '/groups': 'forbid', 
      '/specialties': 'forbid', 
      '/acad_plan': 'forbid', 
      '/dep_load': 'forbid', 
      '/projects': 'forbid', 
      '/uploads': 'forbid', 
      '/department': 'forbid'
    }
  },
  2: {
    'GET': {
      '/teachers': 'allow', 
      '/students': 'allow', 
      '/groups': 'allow', 
      '/specialties': 'allow', 
      '/acad_plan': 'allow', 
      '/dep_load': 'allow', 
      '/projects': 'allow', 
      '/uploads': 'allow', 
      '/department': 'allow'
    },
    'POST': {
      '/teachers': 'forbid',
      '/students': 'forbid', 
      '/groups': 'forbid', 
      '/specialties': 'forbid', 
      '/acad_plan': 'forbid', 
      '/dep_load': 'forbid', 
      '/projects': 'forbid', 
      '/uploads': 'self', 
      '/department': 'forbid'
    },
    'PUT': {
      '/teachers': 'self',
      '/students': 'forbid', 
      '/groups': 'forbid', 
      '/specialties': 'forbid', 
      '/acad_plan': 'forbid', 
      '/dep_load': 'forbid', 
      '/projects': 'self', 
      '/uploads': 'self', 
      '/department': 'forbid'
    },
    'DELETE': {
      '/teachers': 'forbid',
      '/students': 'forbid', 
      '/groups': 'forbid', 
      '/specialties': 'forbid', 
      '/acad_plan': 'forbid', 
      '/dep_load': 'forbid', 
      '/projects': 'forbid', 
      '/uploads': 'self', 
      '/department': 'forbid'
    }
  },
  3: {
    'GET': {
      '/teachers': 'allow', 
      '/students': 'allow', 
      '/groups': 'allow', 
      '/specialties': 'allow', 
      '/acad_plan': 'allow', 
      '/dep_load': 'allow', 
      '/projects': 'allow', 
      '/uploads': 'allow', 
      '/department': 'allow'
    },
    'POST': {
      '/teachers': 'forbid',
      '/students': 'self', 
      '/groups': 'self', 
      '/specialties': 'self', 
      '/acad_plan': 'self', 
      '/dep_load': 'self', 
      '/projects': 'self', 
      '/uploads': 'self', 
      '/department': 'self'
    },
    'PUT': {
      '/teachers': 'self',
      '/students': 'self', 
      '/groups': 'self', 
      '/specialties': 'self', 
      '/acad_plan': 'self', 
      '/dep_load': 'self', 
      '/projects': 'self', 
      '/uploads': 'self', 
      '/department': 'self'
    },
    'DELETE': {
      '/teachers': 'forbid',
      '/students': 'self', 
      '/groups': 'self', 
      '/specialties': 'self', 
      '/acad_plan': 'self', 
      '/dep_load': 'self', 
      '/projects': 'self', 
      '/uploads': 'self', 
      '/department': 'self'
    }
  },
  4: {
    'GET': {
      '/teachers': 'allow', 
      '/students': 'allow', 
      '/groups': 'allow', 
      '/specialties': 'allow', 
      '/acad_plan': 'allow', 
      '/dep_load': 'allow', 
      '/projects': 'allow', 
      '/uploads': 'allow', 
      '/department': 'allow'
    },
    'POST': {
      '/teachers': 'allow',
      '/students': 'allow', 
      '/groups': 'allow', 
      '/specialties': 'allow', 
      '/acad_plan': 'allow', 
      '/dep_load': 'allow', 
      '/projects': 'allow', 
      '/uploads': 'allow', 
      '/department': 'allow'
    },
    'PUT': {
      '/teachers': 'allow',
      '/students': 'allow', 
      '/groups': 'allow', 
      '/specialties': 'allow', 
      '/acad_plan': 'allow', 
      '/dep_load': 'allow', 
      '/projects': 'allow', 
      '/uploads': 'allow', 
      '/department': 'allow'
    },
    'DELETE': {
      '/teachers': 'allow',
      '/students': 'allow', 
      '/groups': 'allow', 
      '/specialties': 'allow', 
      '/acad_plan': 'allow', 
      '/dep_load': 'allow', 
      '/projects': 'allow', 
      '/uploads': 'allow', 
      '/department': 'allow'
    }
  }
};

const mapping = {
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

// url??
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
    if (url === '/teacher' && method === 'PUT') {
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