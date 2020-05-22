--  v.30 | 08.05.20 | new tables, changes in disciplines

CREATE TABLE "department"
(
 "id"    serial PRIMARY KEY,
 "name" varchar(100) UNIQUE NOT NULL
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
 "name"          varchar(100) NOT NULL,
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
 "id"          		serial PRIMARY KEY,
 "name"        		varchar(150) NOT NULL,
 "code"        		varchar(25) NOT NULL,
 "zet"						int,
 "hours_lec"   		int,
 "hours_lab"  	 	int,
 "hours_sem" 	 		int,
 "acad_plan_id" 	int REFERENCES acad_plan(id) NOT NULL,
 "acad_block_id" 	int REFERENCES acad_block(id) NOT NULL,
 "acad_part_id" 	int REFERENCES acad_part(id),
 "acad_module_id" int REFERENCES acad_module(id),
 "exams" 					integer[],
 "zachets" 				integer[],
 "semesters" 			integer[] NOT NULL,
 "is_optional"	 	boolean NOT NULL
);

COMMENT ON COLUMN "acad_discipline"."zet" IS 'Всего ЗЕТ';


CREATE TABLE "dep_load"
(
 "id"           	serial PRIMARY KEY,
 "department_id"	int NOT NULL REFERENCES department(id),
 "begin_date" 		timestamp NOT NULL,
 "end_date" 			timestamp NOT NULL,
 "modified_date" 	timestamp
);

COMMENT ON COLUMN "dep_load"."begin_date" IS 'Начальный год';
COMMENT ON COLUMN "dep_load"."end_date" IS 'Конечный год';

CREATE TABLE "personalities"
(
 "id"         serial PRIMARY KEY,
 "name"       varchar(50) NOT NULL,
 "surname"    varchar(50) NOT NULL,
 "patronymic" varchar(50),
 "birthday"   timestamp,
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
 "position"       varchar(100) NOT NULL,
 "rank_id"        integer REFERENCES ranks(id),
 "degree_id"      integer REFERENCES degree(id),
 "rate"           real,
 "hours_worked"   int,
 "rinc"           real,
 "web_of_science" real,
 "scopus"         real,
 "login"          varchar(25) UNIQUE NOT NULL,
 "password"       varchar(200) NOT NULL,
 "salt"           varchar(200) NOT NULL
);

COMMENT ON COLUMN "teachers"."rate" IS 'ставка';

CREATE TABLE "disciplines"
(
 "id"                 bigserial PRIMARY KEY,
 "name"        				varchar(150) NOT NULL,
 "hours_con_project"	real,
 "hours_lec"   				real,
 "hours_sem" 	 				real,
 "hours_lab"   				real,
 "hours_con_exam"  		real,
 "hours_zachet"       real,
 "hours_exam"      		real,
 "hours_kurs_project" real,
 "hours_gek"          real,
 "hours_ruk_prakt"    real,
 "hours_ruk_vkr"      real,
 "hours_ruk_mag"    	real,
 "hours_ruk_aspirant" real,
 "semester_num" 			smallint NOT NULL,
 "acad_discipline_id" int REFERENCES acad_discipline(id),
 "dep_load_id" 				int NOT NULL REFERENCES dep_load(id),
 "is_approved" 				boolean NOT NULL
);

COMMENT ON COLUMN disciplines.is_approved IS 'Подтверждены различия с учебным планом, либо различий нету';
COMMENT ON COLUMN disciplines.hours_con_exam IS 'Консультация экзамен';
COMMENT ON COLUMN disciplines.hours_exam IS 'Экзамен';
COMMENT ON COLUMN disciplines.hours_zachet IS 'Зачет';
COMMENT ON COLUMN disciplines.hours_kurs_project IS 'Курсовой проект';
COMMENT ON COLUMN disciplines.hours_gek IS 'ГЭК';
COMMENT ON COLUMN disciplines.hours_ruk_prakt IS 'Руководство практикой';
COMMENT ON COLUMN disciplines.hours_ruk_vkr IS 'Руководство ВКР';
COMMENT ON COLUMN disciplines.hours_ruk_mag IS 'Руководство магистрами';
COMMENT ON COLUMN disciplines.hours_ruk_aspirant IS 'Руководство аспирантом';
COMMENT ON COLUMN disciplines.hours_con_project IS 'Консультация проекта';
COMMENT ON COLUMN disciplines.semester_num IS 'Номер семестра (1 или 2)';
COMMENT ON COLUMN disciplines.acad_discipline_id IS 'ID дисциплины из учебного плана';

-- Мб sub_unit вместо acad_plan
CREATE TABLE "files_acad_plan"
(
 "id"         		serial PRIMARY KEY,
 "name"		  			varchar(100) NOT NULL,
 "path"       		text NOT NULL,
 "ext" 	  				varchar(10) NOT NULL,
 "modified_date"  timestamp NOT NULL,
 "teacher_id" 		int NOT NULL REFERENCES teachers(id),
 "sub_unit_id" 			int NOT NULL REFERENCES sub_unit(id),
 "acad_plan_id" 	int REFERENCES acad_plan(id) NOT NULL
);


CREATE TABLE "files_ind_plan"
(
 "id"         			serial PRIMARY KEY,
 "name"		  				varchar(100) NOT NULL,
 "path"       			text NOT NULL,
 "ext" 	 						varchar(10) NOT NULL,
 "modified_date"    timestamp NOT NULL,
 "teacher_id" 			int REFERENCES teachers(id) NOT NULL,
 "sub_unit_id" 			int NOT NULL REFERENCES sub_unit(id)
);

CREATE TABLE "files_rpd"
(
 "id"         			serial PRIMARY KEY,
 "name"		  				varchar(100) NOT NULL,
 "path"       			text NOT NULL,
 "ext" 	 						varchar(10) NOT NULL,
 "modified_date"    timestamp NOT NULL,
 "teacher_id" 			int REFERENCES teachers(id) NOT NULL,
 "sub_unit_id" 			int NOT NULL REFERENCES sub_unit(id),
 "discipline_id"		int REFERENCES disciplines(id) NOT NULL
);

CREATE TABLE "files_dep_load"
(
 "id"         			serial PRIMARY KEY,
 "name"		  				varchar(100) NOT NULL,
 "path"       			text NOT NULL,
 "ext" 	 						varchar(10) NOT NULL,
 "modified_date"    timestamp NOT NULL,
 "teacher_id" 			int REFERENCES teachers(id) NOT NULL,
 "sub_unit_id" 			int NOT NULL REFERENCES sub_unit(id),
 "dep_load_id"			int REFERENCES dep_load(id) NOT NULL
);

CREATE TABLE "rights_roles"
(
 "id"          serial PRIMARY KEY,
 "role"        smallint NOT NULL,
 "teacher_id"  int NOT NULL REFERENCES teachers(id),
 "sub_unit_id" int NOT NULL REFERENCES sub_unit(id)
);

COMMENT ON TABLE "rights_roles" IS 'Права выданные определенным преподавателям к определенным подразделениям';

COMMENT ON COLUMN "rights_roles"."role" IS '1 - пользователь, 2 - преподаватель, 3 - РОП, 4 - админ';





CREATE TABLE "projects"
(
 "id"         	bigserial PRIMARY KEY,
 "name"     		varchar(250) NOT NULL,
 "description" 	text NOT NULL,
 "begin_date"   timestamp NOT NULL,
 "end_date"     timestamp NOT NULL,
 "link_trello" 	text,
 "sub_unit_id" 	int NOT NULL REFERENCES sub_unit(id),
 "teacher_id"  	int REFERENCES teachers(id)
);

CREATE TABLE "files_projects"
(
 "id"         			bigserial PRIMARY KEY,
 "name"		  				varchar(100) NOT NULL,
 "path"       			text NOT NULL,
 "ext" 	  					varchar(10) NOT NULL,
 "modified_date"    timestamp NOT NULL,
 "teacher_id" 			int REFERENCES teachers(id) NOT NULL,
 "sub_unit_id" 			int NOT NULL REFERENCES sub_unit(id),
 "project_id" 			int REFERENCES projects(id) NOT NULL
);

CREATE TABLE "groups"
(
 "id"             serial PRIMARY KEY,
 "specialties_id" int NOT NULL REFERENCES specialties(id),
 "name"           varchar(20) UNIQUE NOT NULL
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

CREATE TABLE "disciplines_groups"
(
	"id"							serial PRIMARY KEY,
	"discipline_id" 	bigint REFERENCES disciplines(id) NOT NULL,
	"group_id"				int REFERENCES groups(id) NOT NULL
);

CREATE TABLE "disciplines_teachers"
(
	"id"							serial PRIMARY KEY,
	"discipline_id" 	bigint REFERENCES disciplines(id) NOT NULL,
	"teacher_id"			int REFERENCES teachers(id) NOT NULL
);