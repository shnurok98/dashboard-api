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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow',
      '/uploads/dep_load': 'allow',
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
      '/uploads/ind_plan': 'forbid',
      '/uploads/projects': 'forbid',
      '/uploads/rpd': 'forbid',
      '/uploads/acad_plan': 'forbid',
      '/uploads/dep_load': 'forbid', 
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
      '/uploads/ind_plan': 'forbid',
      '/uploads/projects': 'forbid',
      '/uploads/rpd': 'forbid',
      '/uploads/acad_plan': 'forbid',
      '/uploads/dep_load': 'forbid', 
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
      '/uploads/ind_plan': 'forbid',
      '/uploads/projects': 'forbid',
      '/uploads/rpd': 'forbid',
      '/uploads/acad_plan': 'forbid',
      '/uploads/dep_load': 'forbid', 
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow',
      '/uploads/dep_load': 'allow', 
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow', 
      '/uploads/dep_load': 'allow',
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
      '/uploads/ind_plan': 'self',
      '/uploads/projects': 'self',
      '/uploads/rpd': 'self',
      '/uploads/acad_plan': 'self',
      '/uploads/dep_load': 'self', 
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
      '/uploads/ind_plan': 'self',
      '/uploads/projects': 'self',
      '/uploads/rpd': 'self',
      '/uploads/acad_plan': 'self', 
      '/uploads/dep_load': 'self', 
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow', 
      '/uploads/dep_load': 'allow',
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow', 
      '/uploads/dep_load': 'allow',
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
      '/uploads/ind_plan': 'self',
      '/uploads/projects': 'self',
      '/uploads/rpd': 'self',
      '/uploads/acad_plan': 'self', 
      '/uploads/dep_load': 'self',
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
      '/uploads/ind_plan': 'self',
      '/uploads/projects': 'self',
      '/uploads/rpd': 'self',
      '/uploads/acad_plan': 'self', 
      '/uploads/dep_load': 'self',
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow', 
      '/uploads/dep_load': 'allow',
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow', 
      '/uploads/dep_load': 'allow',
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow', 
      '/uploads/dep_load': 'allow',
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
      '/uploads/ind_plan': 'allow',
      '/uploads/projects': 'allow',
      '/uploads/rpd': 'allow',
      '/uploads/acad_plan': 'allow', 
      '/uploads/dep_load': 'allow',
      '/department': 'allow'
    }
  }
};

module.exports = rights;