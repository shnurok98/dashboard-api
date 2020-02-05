-- dev DB v.20 | 04.02.20 | NOT NULL УБРАН

CREATE TABLE IF NOT EXISTS "files_ind_plan"
(
 "id"   serial PRIMARY KEY,
 "file" varchar(50),
 "date" date
);

CREATE TABLE IF NOT EXISTS "degree"
(
 "id"     serial PRIMARY KEY,
 "degree" varchar(50)
);


CREATE TABLE IF NOT EXISTS "specialties"
(
 "id"           serial PRIMARY KEY,
 "code"         varchar(20),
 "title"        varchar(50),
 "profile"		 varchar(100),
 "educ_form"	 varchar(20),
 "educ_program" smallint,
 "educ_years"	 int,
 "year_join"	 date,
 "id_acad_plan" serial
);

COMMENT ON COLUMN "specialties"."educ_program" IS '1 - бакалавр, 2 - магистр, 3 - специалитет';

CREATE TABLE IF NOT EXISTS "groups"
(
 "id"             serial PRIMARY KEY,
 "id_specialties" serial,
 "name" 				varchar(15)
);

CREATE TABLE IF NOT EXISTS "students"
(
 "id"             serial PRIMARY KEY,
 "id_person" 		serial,
 "id_group"			serial,
 "id_proj_act"		serial
);

CREATE TABLE IF NOT EXISTS "personalities" (
	"id"         serial PRIMARY KEY,
	"name"       varchar(50),
	"surname"    varchar(50),
	"patronymic" varchar(50),
	"birthday"   date,
	"phone"      varchar(20),
	"email"      varchar(40),
	"status"     smallint
);

COMMENT ON COLUMN "personalities"."status" IS '1 - преподаватель, 2 - студент';

CREATE TABLE IF NOT EXISTS "teachers" (
	"id"         serial PRIMARY KEY,
	"id_person"      serial NOT NULL,
	"position"       varchar(50),
	"id_rank"        serial,
	"id_degree"      serial,
	"rate"           real,
	"hours_worked"   int,
	"RINC"           real,
	"id_ind_plan"    serial,
	"web_of_science" real,
	"scopus"         real,
	"login"				varchar(25) NOT NULL,
	"password"			varchar(150),
	"salt"				varchar(150)
);


CREATE TABLE IF NOT EXISTS "rights_roles"
(
	"id"           serial PRIMARY KEY,
	"role"         varchar(50),
	"id_teacher"   serial,
	"sub_unit"		serial
);

CREATE TABLE IF NOT EXISTS "sub_unit"
(
 "id"           	serial PRIMARY KEY,
 "title"        	varchar(50),
 "is_project"		boolean
);


CREATE TABLE IF NOT EXISTS "disciplines_year"
(
 "id"                 serial,
 "title"              varchar(50),
 "hours_lec"          int,
 "hours_lab"          int,
 "hours_seminar"      int,
 "hours_con_ekzamen"  int,
 "hours_ekzamen"      int,
 "hours_zachet"       int,
 "hours_kursovoy"     int,
 "hours_GEK"          int,
 "hours_ruk_prakt"    int,
 "hours_ruk_VKR"      int,
 "hours_ruk_magic"    int,
 "hours_ruk_aspirant" int,
 "hours_proj_act"     int,
 "id_specialty"       int,
 "semester"           int,
 "id_file_RPD"			 bigserial,
 "id_department"		 serial
);


-- select * from teachers inner join personalities on teachers.id_person = personalities.id and teachers.id = 5;