--  v.25 | 07.03.20 | Renamed, fix FK


CREATE TABLE "academic_plan"
(
 "id"          serial PRIMARY KEY
);

CREATE TABLE "discip_blocks"
(
 "id"    serial PRIMARY KEY,
 "code"  varchar(10) NOT NULL,
 "name" varchar(25) NOT NULL
);

CREATE TABLE "discip_modules"
(
 "id"       serial PRIMARY KEY,
 "code"     varchar(10) NOT NULL,
 "name"    varchar(75) NOT NULL,
 "block_id" int REFERENCES discip_blocks(id)
);

CREATE TABLE "disciplines"
(
 "id"          serial PRIMARY KEY,
 "module_id"   int REFERENCES discip_modules(id),
 "name"       varchar(30) NOT NULL,
 "code"        varchar(10) NOT NULL,
 "hours_lec"   int NOT NULL,
 "hours_lab"   int NOT NULL,
 "hours_prakt" int NOT NULL,
 "hours_self"  int NOT NULL
);

CREATE TABLE "semestr"
(
 "id"            serial PRIMARY KEY,
 "discipline_id" int NOT NULL REFERENCES disciplines(id),
 "semester"      int NOT NULL,
 "is_exam"       boolean NOT NULL
);

CREATE TABLE "blocks_for_acad_plan"
(
 "id"               serial PRIMARY KEY,
 "acad_plan_id"     int REFERENCES academic_plan(id),
 "discip_blocks_id" int REFERENCES discip_blocks(id)
);

CREATE TABLE "discip_optional"
(
 "id"           serial PRIMARY KEY,
 "code"         varchar(10) NOT NULL,
 "name"        varchar(25) NOT NULL,
 "semester"     int NOT NULL,
 "hours"        int NOT NULL,
 "acad_plan_id" int REFERENCES academic_plan(id)
);

CREATE TABLE "files_acad_plan"
(
 "id"         serial PRIMARY KEY,
 "name"		  varchar(50) NOT NULL,
 "path"       text NOT NULL,
 "extname" 	  varchar(7) NOT NULL,
 "lastModifiedDate"       date NOT NULL,
 "acad_plan_id" int REFERENCES academic_plan(id)
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
 "person_id"      int NOT NULL REFERENCES personalities(id),
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
 "acad_plan_id"  int REFERENCES academic_plan(id),
 "sub_unit_id"   int REFERENCES sub_unit(id)
);

COMMENT ON COLUMN "specialties"."profile" IS 'Профиль';
COMMENT ON COLUMN "specialties"."educ_form" IS 'очная, очно-заочная и тд';
COMMENT ON COLUMN "specialties"."educ_programm" IS '1 - бакалавр, 2 - магистр';
COMMENT ON COLUMN "specialties"."educ_years" IS 'Срок обучения';
COMMENT ON COLUMN "specialties"."year_join" IS 'Год набора';

CREATE TABLE "disciplines_year"
(
 "id"                 serial PRIMARY KEY,
 "name"               varchar(50) NOT NULL,
 "hours_lec"          int NOT NULL,
 "hours_lab"          int NOT NULL,
 "hours_seminar"      int NOT NULL,
 "hours_con_ekzamen"  int NOT NULL,
 "hours_ekzamen"      int NOT NULL,
 "hours_zachet"       int NOT NULL,
 "hours_kursovoy"     int NOT NULL,
 "hours_gek"          int NOT NULL,
 "hours_ruk_prakt"    int NOT NULL,
 "hours_ruk_vkr"      int NOT NULL,
 "hours_ruk_magic"    int NOT NULL,
 "hours_ruk_aspirant" int NOT NULL,
 "hours_proj_act"     int NOT NULL,
 "specialty_id"       int REFERENCES specialties(id),
 "semester"           int NOT NULL,
 "file_rpd_id"        bigint REFERENCES "files_rpd"(id),
 "years"          	  varchar(20) NOT NULL,
 "date"          	 	  date NOT NULL
);

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


