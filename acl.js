// Access Contol List
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

module.exports = rights;