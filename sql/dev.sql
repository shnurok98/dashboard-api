--  v.26 | 09.03.20 | New scheme. Upgrade discipline


CREATE TABLE "acad_plan"
(
 "id"          serial PRIMARY KEY,
 "action_date" timestamp
);

COMMENT ON COLUMN "acad_plan"."action_date" IS 'Дата последнего изменения';

CREATE TABLE "acad_block"
(
 "id"    serial PRIMARY KEY,
 "name"  varchar(120) UNIQUE NOT NULL,
 "code" varchar(25) NOT NULL
);

CREATE TABLE "acad_part"
(
 "id"       serial PRIMARY KEY,
 "name"     varchar(120) UNIQUE NOT NULL,
 "code"     varchar(25) NOT NULL
);

CREATE TABLE "acad_module"
(
 "id"       serial PRIMARY KEY,
 "name"     varchar(120) UNIQUE NOT NULL,
 "code"     varchar(25) NOT NULL
);

CREATE TABLE "discipline"
(
 "id"          serial PRIMARY KEY,
 "name"        varchar(50) NOT NULL,
 "code"        varchar(25) NOT NULL,
 "hours_lec"   int,
 "hours_lab"   int,
 "hours_sem" 	 int,
 "hours_self"  int,
 "acad_plan_id" int REFERENCES acad_plan(id) NOT NULL,
 "acad_block_id" int REFERENCES acad_block(id) NOT NULL,
 "acad_part_id" int REFERENCES acad_part(id),
 "acad_module_id"   int REFERENCES acad_module(id),
 "semester_num" int NOT NULL,
 "is_exam" boolean NOT NULL,
 "is_optional" boolean NOT NULL
);

CREATE TABLE "files_acad_plan"
(
 "id"         serial PRIMARY KEY,
 "name"		  varchar(50) NOT NULL,
 "path"       text NOT NULL,
 "extname" 	  varchar(7) NOT NULL,
 "lastModifiedDate"       date NOT NULL,
 "acad_plan_id" int REFERENCES acad_plan(id)
);

CREATE TABLE "personalities"
(
 "id"         serial PRIMARY KEY,
 "name"       varchar(50) NOT NULL,
 "surname"    varchar(50) NOT NULL,
 "patronymic" varchar(50),
 "birthday"   date,
 "phone"      varchar(20),
 "email"      varchar(40),
 "status"     smallint NOT NULL
);

COMMENT ON COLUMN "personalities"."status" IS '1 - студент, 2 - преподаватель';

CREATE TABLE "ranks"
(
 "id"   serial PRIMARY KEY,
 "name" varchar(50) NOT NULL
);

COMMENT ON TABLE "ranks" IS 'Звание';

CREATE TABLE "degree"
(
 "id"     serial PRIMARY KEY,
 "name" varchar(50) NOT NULL
);

COMMENT ON TABLE "degree" IS 'Степень';

CREATE TABLE "teachers"
(
 "id"             serial PRIMARY KEY,
 "person_id"      int UNIQUE NOT NULL REFERENCES personalities(id),
 "position"       varchar(50) NOT NULL,
 "rank_id"        integer REFERENCES ranks(id),
 "degree_id"      integer REFERENCES degree(id),
 "rate"           real,
 "hours_worked"   int,
 "rinc"           real,
 "web_of_science" real,
 "scopus"         real,
 "login"          varchar(25) NOT NULL,
 "password"       varchar(150) NOT NULL,
 "salt"           varchar(150) NOT NULL
);

COMMENT ON COLUMN "teachers"."rate" IS 'ставка';

CREATE TABLE "files_ind_plan"
(
 "id"         serial PRIMARY KEY,
 "name"		  varchar(50) NOT NULL,
 "path"       text NOT NULL,
 "extname" 	  varchar(7) NOT NULL,
 "lastModifiedDate"       date NOT NULL,
 "teacher_id" int REFERENCES teachers(id)
);

CREATE TABLE "files_rpd"
(
 "id"         serial PRIMARY KEY,
 "name"		  varchar(50) NOT NULL,
 "path"       text NOT NULL,
 "extname" 	  varchar(7) NOT NULL,
 "lastModifiedDate"       date NOT NULL,
 "teacher_id" int REFERENCES teachers(id)
);






CREATE TABLE "department"
(
 "id"    serial PRIMARY KEY,
 "name" varchar(50) NOT NULL
);

CREATE TABLE "sub_unit"
(
 "id"            serial PRIMARY KEY,
 "name"         varchar(50) NOT NULL,
 "is_project"    boolean NOT NULL,
 "department_id" int NOT NULL REFERENCES department(id)
);

COMMENT ON TABLE "sub_unit" IS 'Подразделения ( условные САПР, ВЕБ и т.д. ), также сюда включаются проекты по ПД.';

CREATE TABLE "rights_roles"
(
 "id"          serial PRIMARY KEY,
 "role"        varchar(50) NOT NULL,
 "teacher_id"  int NOT NULL REFERENCES teachers(id),
 "sub_unit_id" int NOT NULL REFERENCES sub_unit(id)
);

COMMENT ON TABLE "rights_roles" IS 'Права выданные определенным преподавателям к определенным подразделениям и проектам';

COMMENT ON COLUMN "rights_roles"."role" IS 'Можно сделать smallint типо (РОП, Куратор и тд)';

CREATE TABLE "specialties"
(
 "id"            serial PRIMARY KEY,
 "code"          varchar(20) NOT NULL,
 "name"          varchar(50) NOT NULL,
 "profile"       varchar(100) NOT NULL,
 "educ_form"     varchar(20) NOT NULL,
 "educ_programm" smallint NOT NULL,
 "educ_years"    int NOT NULL,
 "year_join"     date NOT NULL,
 "acad_plan_id"  int UNIQUE NOT NULL REFERENCES acad_plan(id),
 "sub_unit_id"   int REFERENCES sub_unit(id)
);

COMMENT ON COLUMN "specialties"."profile" IS 'Профиль';
COMMENT ON COLUMN "specialties"."educ_form" IS 'очная, очно-заочная и тд';
COMMENT ON COLUMN "specialties"."educ_programm" IS '1 - бакалавр, 2 - магистр';
COMMENT ON COLUMN "specialties"."educ_years" IS 'Срок обучения';
COMMENT ON COLUMN "specialties"."year_join" IS 'Год набора';

CREATE TABLE "dep_load"
(
 "id"            serial PRIMARY KEY,
 "department_id" int NOT NULL REFERENCES department(id),
 "begin_date" timestamp NOT NULL,
 "end_date" timestamp NOT NULL,
 "action_date" timestamp
);

CREATE TABLE "dis_load"
(
 "id"                 serial PRIMARY KEY,
 "name"        varchar(50) NOT NULL,
 "code"        varchar(25) NOT NULL,
 "hours_lec"   int,
 "hours_lab"   int,
 "hours_sem" 	 int,
 "hours_self"  int,
 "hours_con_exam"  int,
 "hours_exam"      int,
 "hours_zachet"       int,
 "hours_kursovoy"     int,
 "hours_gek"          int,
 "hours_ruk_prakt"    int,
 "hours_ruk_vkr"      int,
 "hours_ruk_magic"    int,
 "hours_ruk_aspirant" int,
 "hours_proj_act"     int,
 "semester_num" int NOT NULL,
 "discipline_id" int UNIQUE NOT NULL REFERENCES discipline(id),
 "file_rpd_id"        bigint REFERENCES "files_rpd"(id),
 "dep_load_id" int NOT NULL REFERENCES dep_load(id),
 "is_approved" boolean NOT NULL
);

COMMENT ON COLUMN dis_load.is_approved IS 'Подтверждены различия с учебным планом, либо различий нету';
COMMENT ON COLUMN dis_load.hours_self IS 'Самостоятельная работа';
COMMENT ON COLUMN dis_load.hours_con_exam IS 'Консультация экзамен';
COMMENT ON COLUMN dis_load.hours_exam IS 'Экзамен';
COMMENT ON COLUMN dis_load.hours_zachet IS 'Зачет';
COMMENT ON COLUMN dis_load.hours_kursovoy IS 'Курсовой проект';
COMMENT ON COLUMN dis_load.hours_gek IS 'ГЭК';
COMMENT ON COLUMN dis_load.hours_ruk_prakt IS 'Руководство практикой';
COMMENT ON COLUMN dis_load.hours_ruk_vkr IS 'Руководство ВКР';
COMMENT ON COLUMN dis_load.hours_ruk_magic IS 'Руководство магистрами';
COMMENT ON COLUMN dis_load.hours_ruk_aspirant IS 'Руководство аспирантом';
COMMENT ON COLUMN dis_load.hours_proj_act IS 'Консультация проекта';
COMMENT ON COLUMN dis_load.semester_num IS 'Номер семестра (1 или 2)';
COMMENT ON COLUMN dis_load.discipline_id IS 'ID дисциплины из учебного плана';


CREATE TABLE "project_activities"
(
 "id"          serial PRIMARY KEY,
 "name"       varchar(50) NOT NULL,
 "description" text NOT NULL,
 "begin_date"       date NOT NULL,
 "end_date"         date NOT NULL,
 "link_trello" varchar(250),
 "sub_unit_id" int NOT NULL REFERENCES sub_unit(id)
);

CREATE TABLE "files_proj_act"
(
 "id"         serial PRIMARY KEY,
 "name"		  varchar(50) NOT NULL,
 "path"       text NOT NULL,
 "extname" 	  varchar(7) NOT NULL,
 "lastModifiedDate"       date NOT NULL,
 "proj_act_id" int NOT NULL REFERENCES project_activities(id)
);

CREATE TABLE "groups"
(
 "id"             serial PRIMARY KEY,
 "specialties_id" int NOT NULL REFERENCES specialties(id),
 "name"           varchar(15) NOT NULL
);

CREATE TABLE "students"
(
 "id"          serial PRIMARY KEY,
 "person_id"   int NOT NULL REFERENCES personalities(id),
 "group_id"    int NOT NULL REFERENCES groups(id)
);

CREATE TABLE "stud_on_proj"
(
	"id"	serial PRIMARY KEY,
	"student_id" int NOT NULL REFERENCES students(id),
	"project_id" int NOT NULL REFERENCES project_activities(id),
	"date" date NOT NULL
);


