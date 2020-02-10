--  v.23 | 08.02.20


CREATE TABLE "academic_plan"
(
 "id"          serial PRIMARY KEY
);



CREATE TABLE "blocks_for_acad_plan"
(
 "id"               serial PRIMARY KEY,
 "id_acad_plan"     serial REFERENCES academic_plan(id),
 "id_discip_blocks" serial REFERENCES discip_blocks(id)
);



CREATE TABLE "department"
(
 "id"    serial PRIMARY KEY,
 "title" varchar(50) NOT NULL
);


CREATE TABLE "degree"
(
 "id"     serial PRIMARY KEY,
 "title" varchar(50) NOT NULL
);

COMMENT ON TABLE "degree" IS 'Степень';



CREATE TABLE "discip_blocks"
(
 "id"    serial PRIMARY KEY,
 "code"  varchar(10) NOT NULL,
 "title" varchar(25) NOT NULL
);



CREATE TABLE "discip_modules"
(
 "id"       serial PRIMARY KEY,
 "code"     varchar(10) NOT NULL,
 "title"    varchar(15) NOT NULL,
 "id_block" serial REFERENCES discip_blocks(id)
);




CREATE TABLE "discip_optional"
(
 "id"           serial PRIMARY KEY,
 "code"         varchar(10) NOT NULL,
 "title"        varchar(25) NOT NULL,
 "semester"     int NOT NULL,
 "hours"        int NOT NULL,
 "id_acad_plan" serial REFERENCES academic_plan(id)
);



CREATE TABLE "disciplines"
(
 "id"          serial PRIMARY KEY,
 "id_module"   serial REFERENCES discip_modules(id),
 "title"       varchar(30) NOT NULL,
 "code"        varchar(10) NOT NULL,
 "hours_lec"   int NOT NULL,
 "hours_lab"   int NOT NULL,
 "hours_prakt" int NOT NULL,
 "hours_self"  int NOT NULL
);



CREATE TABLE "disciplines_year"
(
 "id"                 serial PRIMARY KEY,
 "title"              varchar(50) NOT NULL,
 "hours_lec"          int NOT NULL,
 "hours_lab"          int NOT NULL,
 "hours_seminar"      int NOT NULL,
 "hours_con_ekzamen"  int NOT NULL,
 "hours_ekzamen"      int NOT NULL,
 "hours_zachet"       int NOT NULL,
 "hours_kursovoy"     int NOT NULL,
 "hours_GEK"          int NOT NULL,
 "hours_ruk_prakt"    int NOT NULL,
 "hours_ruk_VKR"      int NOT NULL,
 "hours_ruk_magic"    int NOT NULL,
 "hours_ruk_aspirant" int NOT NULL,
 "hours_proj_act"     int NOT NULL,
 "id_specialty"       serial REFERENCES specialties(id),
 "semester"           int NOT NULL,
 "id_file_RPD"        bigserial REFERENCES "files_RPD"(id),
 "years"          	 varchar(20) NOT NULL,
 "date"          	 	 date NOT NULL
);



CREATE TABLE "files_ind_plan"
(
 "id"         serial PRIMARY KEY,
 "title"		  varchar(50) NOT NULL,
 "link"       varchar(80) NOT NULL,
 "ext" 		  varchar(7) NOT NULL,
 "date"       date NOT NULL,
 "id_teacher" serial REFERENCES teachers(id)
);



CREATE TABLE "files_acad_plan"
(
 "id"         serial PRIMARY KEY,
 "title"		  varchar(50) NOT NULL,
 "link"       varchar(80) NOT NULL,
 "ext" 		  varchar(7) NOT NULL,
 "date"       date NOT NULL,
 "id_acad_plan" serial REFERENCES academic_plan(id)
);



CREATE TABLE "files_proj_act"
(
 "id"         serial PRIMARY KEY,
 "title"		  varchar(50) NOT NULL,
 "link"       varchar(80) NOT NULL,
 "ext" 		  varchar(7) NOT NULL,
 "date"       date NOT NULL,
 "id_proj_act" serial NOT NULL REFERENCES project_activities(id)
);



CREATE TABLE "files_RPD"
(
 "id"         serial PRIMARY KEY,
 "title"		  varchar(50) NOT NULL,
 "link"       varchar(80) NOT NULL,
 "ext" 		  varchar(7) NOT NULL,
 "date"       date NOT NULL,
 "id_teacher" serial REFERENCES teachers(id)
);



CREATE TABLE "personalities"
(
 "id"         serial PRIMARY KEY,
 "name"       varchar(50) NOT NULL,
 "surname"    varchar(50) NOT NULL,
 "patronymic" varchar(50) NOT NULL,
 "birthday"   date NOT NULL,
 "phone"      varchar(20) NOT NULL,
 "email"      varchar(40) NOT NULL,
 "status"     smallint NOT NULL
);


COMMENT ON COLUMN "personalities"."status" IS '1 - студент, 2 - преподаватель';


CREATE TABLE "groups"
(
 "id"             serial PRIMARY KEY,
 "id_specialties" serial NOT NULL REFERENCES specialties(id),
 "name"           varchar(15) NOT NULL
);



CREATE TABLE "ranks"
(
 "id"   serial PRIMARY KEY,
 "title" varchar(50) NOT NULL
);


COMMENT ON TABLE "ranks" IS 'Звание';




CREATE TABLE "project_activities"
(
 "id"          serial PRIMARY KEY,
 "title"       varchar(50) NOT NULL,
 "description" text NOT NULL,
 "start"       date NOT NULL,
 "end"         date NOT NULL,
 "link_trello" varchar(250),
 "id_sub_unit" serial NOT NULL REFERENCES sub_unit(id)
);



CREATE TABLE "rights_roles"
(
 "id"          serial PRIMARY KEY,
 "role"        varchar(50) NOT NULL,
 "id_teacher"  serial NOT NULL REFERENCES teachers(id),
 "id_sub_unit" serial NOT NULL REFERENCES sub_unit(id)
);



COMMENT ON TABLE "rights_roles" IS 'Права выданные определенным преподавателям к определенным подразделениям и проектам';

COMMENT ON COLUMN "rights_roles"."role" IS 'Можно сделать smallint типо (РОП, Куратор и тд)';



CREATE TABLE "semestr"
(
 "id"            serial PRIMARY KEY,
 "id_discipline" serial NOT NULL REFERENCES disciplines(id),
 "semester"      int NOT NULL,
 "is_exam"       boolean NOT NULL
);



CREATE TABLE "specialties"
(
 "id"            serial PRIMARY KEY,
 "code"          varchar(20) NOT NULL,
 "title"         varchar(50) NOT NULL,
 "profile"       varchar(100) NOT NULL,
 "educ_form"     varchar(20) NOT NULL,
 "educ_programm" smallint NOT NULL,
 "educ_years"    int NOT NULL,
 "year_join"     date NOT NULL,
 "id_acad_plan"  serial REFERENCES academic_plan(id),
 "id_sub_unit"   serial REFERENCES sub_unit(id)
);


COMMENT ON COLUMN "specialties"."profile" IS 'Профиль';
COMMENT ON COLUMN "specialties"."educ_form" IS 'очная, очно-заочная и тд';
COMMENT ON COLUMN "specialties"."educ_programm" IS '1 - бакалавр, 2 - магистр';
COMMENT ON COLUMN "specialties"."educ_years" IS 'Срок обучения';
COMMENT ON COLUMN "specialties"."year_join" IS 'Год набора';



CREATE TABLE "students"
(
 "id"          serial PRIMARY KEY,
 "id_person"   serial NOT NULL REFERENCES personalities(id),
 "id_group"    serial NOT NULL REFERENCES groups(id)
);


CREATE TABLE "teachers"
(
 "id"             serial PRIMARY KEY,
 "id_person"      serial NOT NULL REFERENCES personalities(id),
 "position"       varchar(50) NOT NULL,
 "id_rank"        serial NOT NULL REFERENCES ranks(id),
 "id_degree"      serial NOT NULL REFERENCES degree(id),
 "rate"           real NOT NULL,
 "hours_worked"   int NOT NULL,
 "RINC"           real NOT NULL,
 "web_of_science" real NOT NULL,
 "scopus"         real NOT NULL,
 "login"          varchar(25) NOT NULL,
 "password"       varchar(150) NOT NULL,
 "salt"           varchar(150) NOT NULL
);



COMMENT ON COLUMN "teachers"."rate" IS 'ставка';



CREATE TABLE "sub_unit"
(
 "id"            serial PRIMARY KEY,
 "title"         varchar(50) NOT NULL,
 "is_project"    boolean NOT NULL,
 "id_department" serial NOT NULL REFERENCES department(id)
);

COMMENT ON TABLE "sub_unit" IS 'Подразделения ( условные САПР, ВЕБ и т.д. ), также сюда включаются проекты по ПД.';



CREATE TABLE "stud_on_proj"
(
	"id"	serial PRIMARY KEY,
	"id_student" serial NOT NULL REFERENCES students(id),
	"id_project" serial NOT NULL REFERENCES project_activities(id),
	"date" date NOT NULL
)

