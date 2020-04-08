--  v.28 | 29.03.20 | New scheme.

CREATE TABLE "department"
(
 "id"    serial PRIMARY KEY,
 "name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "sub_unit"
(
 "id"            serial PRIMARY KEY,
 "name"         varchar(50) NOT NULL,
 "department_id" int NOT NULL REFERENCES department(id)
);

COMMENT ON TABLE "sub_unit" IS 'Подразделения ( условные САПР, ВЕБ и т.д. ), проекты ПД делятся согласно этим подразделениям.';

CREATE TABLE "specialties"
(
 "id"            serial PRIMARY KEY,
 "code"          varchar(20) NOT NULL,
 "name"          varchar(50) NOT NULL,
 "profile"       varchar(100) NOT NULL,
 "educ_form"     varchar(20) NOT NULL,
 "educ_programm" smallint NOT NULL,
 "educ_years"    int NOT NULL,
 "year_join"     timestamp NOT NULL,
 "sub_unit_id"   int REFERENCES sub_unit(id)
);

COMMENT ON COLUMN "specialties"."profile" IS 'Профиль';
COMMENT ON COLUMN "specialties"."educ_form" IS 'очная, очно-заочная и тд';
COMMENT ON COLUMN "specialties"."educ_programm" IS '1 - бакалавр, 2 - магистр';
COMMENT ON COLUMN "specialties"."educ_years" IS 'Срок обучения';
COMMENT ON COLUMN "specialties"."year_join" IS 'Год набора';


CREATE TABLE "acad_plan"
(
 "id"          serial PRIMARY KEY,
 "modified_date" timestamp,
 "specialties_id" int UNIQUE NOT NULL REFERENCES specialties(id)
);

COMMENT ON COLUMN "acad_plan"."modified_date" IS 'Дата последнего изменения';

CREATE TABLE "acad_block"
(
 "id"    serial PRIMARY KEY,
 "name"  varchar(120) NOT NULL,
 "code" varchar(25) NOT NULL,
 UNIQUE ("name", "code")
);

CREATE TABLE "acad_part"
(
 "id"       serial PRIMARY KEY,
 "name"     varchar(120) NOT NULL,
 "code"     varchar(25) NOT NULL,
 UNIQUE ("name", "code")
);

CREATE TABLE "acad_module"
(
 "id"       serial PRIMARY KEY,
 "name"     varchar(120) NOT NULL,
 "code"     varchar(25) NOT NULL,
 UNIQUE ("name", "code")
);

CREATE TABLE "acad_discipline"
(
 "id"          serial PRIMARY KEY,
 "name"        varchar(150) NOT NULL,
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




CREATE TABLE "dep_load"
(
 "id"           	serial PRIMARY KEY,
 "sub_unit_id"		int NOT NULL REFERENCES sub_unit(id),
 "begin_date" 		timestamp NOT NULL,
 "end_date" 			timestamp NOT NULL,
 "modified_date" 	timestamp
);


CREATE TABLE "personalities"
(
 "id"         serial PRIMARY KEY,
 "name"       varchar(50) NOT NULL,
 "surname"    varchar(50) NOT NULL,
 "patronymic" varchar(50),
 "birthday"   date,
 "phone"      varchar(20),
 "email"      varchar(40) UNIQUE,
 "status"     smallint NOT NULL
);

COMMENT ON COLUMN "personalities"."status" IS '1 - студент, 2 - преподаватель';

CREATE TABLE "ranks"
(
 "id"   serial PRIMARY KEY,
 "name" varchar(50) UNIQUE NOT NULL
);

COMMENT ON TABLE "ranks" IS 'Звание';

CREATE TABLE "degree"
(
 "id"     serial PRIMARY KEY,
 "name" varchar(50) UNIQUE NOT NULL
);

COMMENT ON TABLE "degree" IS 'Степень';

CREATE TABLE "teachers"
(
 "id"             serial PRIMARY KEY,
 "person_id"      int UNIQUE NOT NULL REFERENCES personalities(id),
 "position"       varchar(70) NOT NULL,
 "rank_id"        integer REFERENCES ranks(id),
 "degree_id"      integer REFERENCES degree(id),
 "rate"           real,
 "hours_worked"   int,
 "rinc"           real,
 "web_of_science" real,
 "scopus"         real,
 "login"          varchar(25) NOT NULL,
 "password"       varchar(200) NOT NULL,
 "salt"           varchar(200) NOT NULL
);

COMMENT ON COLUMN "teachers"."rate" IS 'ставка';

CREATE TABLE "disciplines"
(
 "id"                 bigserial PRIMARY KEY,
 "name"        				varchar(150) NOT NULL,
 "code"        				varchar(25) NOT NULL,
 "hours_lec"   				int,
 "hours_lab"   				int,
 "hours_sem" 	 				int,
 "hours_self"  				int,
 "hours_con_exam"  		int,
 "hours_exam"      		int,
 "hours_zachet"       int,
 "hours_kursovoy"     int,
 "hours_gek"          int,
 "hours_ruk_prakt"    int,
 "hours_ruk_vkr"      int,
 "hours_ruk_magic"    int,
 "hours_ruk_aspirant" int,
 "hours_proj_act"     int,
 "semester_num" 			int NOT NULL,
 "acad_discipline_id" int UNIQUE NOT NULL REFERENCES acad_discipline(id),
 "dep_load_id" 				int NOT NULL REFERENCES dep_load(id),
 "is_approved" 				boolean NOT NULL,
 "teacher_id"					int REFERENCES teachers(id)
);

COMMENT ON COLUMN disciplines.is_approved IS 'Подтверждены различия с учебным планом, либо различий нету';
COMMENT ON COLUMN disciplines.hours_self IS 'Самостоятельная работа';
COMMENT ON COLUMN disciplines.hours_con_exam IS 'Консультация экзамен';
COMMENT ON COLUMN disciplines.hours_exam IS 'Экзамен';
COMMENT ON COLUMN disciplines.hours_zachet IS 'Зачет';
COMMENT ON COLUMN disciplines.hours_kursovoy IS 'Курсовой проект';
COMMENT ON COLUMN disciplines.hours_gek IS 'ГЭК';
COMMENT ON COLUMN disciplines.hours_ruk_prakt IS 'Руководство практикой';
COMMENT ON COLUMN disciplines.hours_ruk_vkr IS 'Руководство ВКР';
COMMENT ON COLUMN disciplines.hours_ruk_magic IS 'Руководство магистрами';
COMMENT ON COLUMN disciplines.hours_ruk_aspirant IS 'Руководство аспирантом';
COMMENT ON COLUMN disciplines.hours_proj_act IS 'Консультация проекта';
COMMENT ON COLUMN disciplines.semester_num IS 'Номер семестра (1 или 2)';
COMMENT ON COLUMN disciplines.acad_discipline_id IS 'ID дисциплины из учебного плана';
COMMENT ON COLUMN disciplines.teacher_id IS 'ID преподавателя назначенного на дисциплину';


CREATE TABLE "files_acad_plan"
(
 "id"         		serial PRIMARY KEY,
 "name"		  			varchar(50) NOT NULL,
 "path"       		text NOT NULL,
 "ext" 	  				varchar(10) NOT NULL,
 "modified_date"  timestamp,
 "create_date"		timestamp NOT NULL,
 "acad_plan_id" 	int REFERENCES acad_plan(id) UNIQUE NOT NULL,
 "teacher_id" 		int NOT NULL REFERENCES teachers(id)
);


CREATE TABLE "files_ind_plan"
(
 "id"         			serial PRIMARY KEY,
 "name"		  				varchar(50) NOT NULL,
 "path"       			text NOT NULL,
 "ext" 	 						varchar(10) NOT NULL,
 "modified_date"    timestamp,
 "create_date"			timestamp NOT NULL,
 "teacher_id" 			int REFERENCES teachers(id) NOT NULL
);

CREATE TABLE "files_rpd"
(
 "id"         			serial PRIMARY KEY,
 "name"		  				varchar(50) NOT NULL,
 "path"       			text NOT NULL,
 "ext" 	 						varchar(10) NOT NULL,
 "modified_date"    timestamp,
 "create_date"			timestamp NOT NULL,
 "teacher_id" 			int REFERENCES teachers(id) NOT NULL,
 "discipline_id"		int REFERENCES disciplines(id) UNIQUE NOT NULL
);



CREATE TABLE "rights_roles"
(
 "id"          serial PRIMARY KEY,
 "role"        smallint NOT NULL,
 "teacher_id"  int NOT NULL REFERENCES teachers(id),
 "sub_unit_id" int NOT NULL REFERENCES sub_unit(id)
);

COMMENT ON TABLE "rights_roles" IS 'Права выданные определенным преподавателям к определенным подразделениям';

COMMENT ON COLUMN "rights_roles"."role" IS '1 - преподаватель, 2 - РОП';





CREATE TABLE "projects"
(
 "id"         	bigserial PRIMARY KEY,
 "name"     		varchar(50) NOT NULL,
 "description" 	text NOT NULL,
 "begin_date"   date NOT NULL,
 "end_date"     date NOT NULL,
 "link_trello" varchar(250),
 "sub_unit_id" int NOT NULL REFERENCES sub_unit(id),
 "teacher_id"  int REFERENCES teachers(id)
);

CREATE TABLE "files_projects"
(
 "id"         			bigserial PRIMARY KEY,
 "name"		  				varchar(50) NOT NULL,
 "path"       			text NOT NULL,
 "ext" 	  					varchar(10) NOT NULL,
 "modified_date"    timestamp,
 "create_date"			timestamp NOT NULL,
 "teacher_id" 			int REFERENCES teachers(id) NOT NULL,
 "project_id" 			int REFERENCES projects(id) UNIQUE NOT NULL
);

CREATE TABLE "groups"
(
 "id"             serial PRIMARY KEY,
 "specialties_id" int NOT NULL REFERENCES specialties(id),
 "name"           varchar(15) UNIQUE NOT NULL
);

CREATE TABLE "students"
(
 "id"          serial PRIMARY KEY,
 "person_id"   int REFERENCES personalities(id) UNIQUE NOT NULL,
 "group_id"    int NOT NULL REFERENCES groups(id)
);

CREATE TABLE "students_projects"
(
	"id"	serial PRIMARY KEY,
	"student_id" int NOT NULL REFERENCES students(id),
	"project_id" int NOT NULL REFERENCES projects(id),
	"date" date NOT NULL
);
