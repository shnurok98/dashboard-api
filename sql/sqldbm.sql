-- source from sqldbm.com v.21 | 07.02.20
-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "academic_plan"

CREATE TABLE "academic_plan"
(
 "id"          serial NOT NULL,
 "id_sub_unit" serial NOT NULL,
 CONSTRAINT "FK_332" FOREIGN KEY ( "id_sub_unit" ) REFERENCES "sub_unit" ( "id" )
);

CREATE UNIQUE INDEX "PK_academic_plan" ON "academic_plan"
(
 "id"
);

CREATE INDEX "fkIdx_332" ON "academic_plan"
(
 "id_sub_unit"
);








-- ************************************** "blocks_for_acad_plan"

CREATE TABLE "blocks_for_acad_plan"
(
 "id"               serial NOT NULL,
 "id_acad_plan"     serial NOT NULL,
 "id_discip_blocks" serial NOT NULL,
 CONSTRAINT "FK_192" FOREIGN KEY ( "id_acad_plan" ) REFERENCES "academic_plan" ( "id" ),
 CONSTRAINT "FK_195" FOREIGN KEY ( "id_discip_blocks" ) REFERENCES "discip_blocks" ( "id" )
);

CREATE UNIQUE INDEX "PK_rel" ON "blocks_for_acad_plan"
(
 "id"
);

CREATE INDEX "fkIdx_192" ON "blocks_for_acad_plan"
(
 "id_acad_plan"
);

CREATE INDEX "fkIdx_195" ON "blocks_for_acad_plan"
(
 "id_discip_blocks"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "department"

CREATE TABLE "department"
(
 "id"    serial NOT NULL,
 "title" varchar(50) NOT NULL,
 CONSTRAINT "PK_department" PRIMARY KEY ( "id" )
);








-- ************************************** "degree"

CREATE TABLE "degree"
(
 "id"     serial NOT NULL,
 "degree" varchar(50) NOT NULL

);

CREATE UNIQUE INDEX "PK_degree" ON "degree"
(
 "id"
);

COMMENT ON TABLE "degree" IS 'Степень';





-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "discip_blocks"

CREATE TABLE "discip_blocks"
(
 "id"    serial NOT NULL,
 "code"  varchar(10) NOT NULL,
 "title" varchar(25) NOT NULL

);

CREATE UNIQUE INDEX "PK_discip_block" ON "discip_blocks"
(
 "id"
);








-- ************************************** "department_load"

CREATE TABLE "department_load"
(
 "id"            serial NOT NULL,
 "years"         varchar(20) NOT NULL,
 "date"          date NOT NULL,
 "id_department" serial NOT NULL,
 CONSTRAINT "FK_320" FOREIGN KEY ( "id_department" ) REFERENCES "department" ( "id" )
);

CREATE UNIQUE INDEX "PK_Кафедра" ON "department_load"
(
 "id"
);

CREATE INDEX "fkIdx_320" ON "department_load"
(
 "id_department"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "discip_modules"

CREATE TABLE "discip_modules"
(
 "id"       serial NOT NULL,
 "code"     varchar(10) NOT NULL,
 "title"    varchar(15) NOT NULL,
 "id_block" serial NOT NULL,
 CONSTRAINT "FK_115" FOREIGN KEY ( "id_block" ) REFERENCES "discip_blocks" ( "id" )
);

CREATE UNIQUE INDEX "PK_discip_module" ON "discip_modules"
(
 "id"
);

CREATE INDEX "fkIdx_115" ON "discip_modules"
(
 "id_block"
);








-- ************************************** "discip_optional"

CREATE TABLE "discip_optional"
(
 "id"           serial NOT NULL,
 "code"         varchar(10) NOT NULL,
 "title"        varchar(25) NOT NULL,
 "semester"     int NOT NULL,
 "hours"        int NOT NULL,
 "id_acad_plan" serial NOT NULL,
 CONSTRAINT "FK_221" FOREIGN KEY ( "id_acad_plan" ) REFERENCES "academic_plan" ( "id" )
);

CREATE UNIQUE INDEX "PK_discip_optional" ON "discip_optional"
(
 "id"
);

CREATE INDEX "fkIdx_221" ON "discip_optional"
(
 "id_acad_plan"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "disciplines"

CREATE TABLE "disciplines"
(
 "id"          serial NOT NULL,
 "id_module"   serial NOT NULL,
 "title"       varchar(30) NOT NULL,
 "code"        varchar(10) NOT NULL,
 "hours_lec"   int NOT NULL,
 "hours_lab"   int NOT NULL,
 "hours_prakt" int NOT NULL,
 "hours_self"  int NOT NULL,
 CONSTRAINT "FK_118" FOREIGN KEY ( "id_module" ) REFERENCES "discip_modules" ( "id" )
);

CREATE UNIQUE INDEX "PK_disciplines" ON "disciplines"
(
 "id"
);

CREATE INDEX "fkIdx_118" ON "disciplines"
(
 "id_module"
);








-- ************************************** "disciplines_year"

CREATE TABLE "disciplines_year"
(
 "id"                 serial NOT NULL,
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
 "id_specialty"       serial NOT NULL,
 "semester"           int NOT NULL,
 "id_file_RPD"        bigserial NOT NULL,
 "id_department_load" serial NOT NULL,
 CONSTRAINT "FK_257" FOREIGN KEY ( "id_specialty" ) REFERENCES "specialties" ( "id" ),
 CONSTRAINT "FK_280" FOREIGN KEY ( "id_file_RPD" ) REFERENCES "files_RPD" ( "id" ),
 CONSTRAINT "FK_300" FOREIGN KEY ( "id_department_load" ) REFERENCES "department_load" ( "id" )
);

CREATE UNIQUE INDEX "PK_Нагрузка" ON "disciplines_year"
(
 "id"
);

CREATE INDEX "fkIdx_257" ON "disciplines_year"
(
 "id_specialty"
);

CREATE INDEX "fkIdx_280" ON "disciplines_year"
(
 "id_file_RPD"
);

CREATE INDEX "fkIdx_300" ON "disciplines_year"
(
 "id_department_load"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "files_ind_plan"

CREATE TABLE "files_ind_plan"
(
 "id"         serial NOT NULL,
 "file"       varchar(50) NOT NULL,
 "date"       date NOT NULL,
 "id_teacher" serial NOT NULL,
 CONSTRAINT "FK_326" FOREIGN KEY ( "id_teacher" ) REFERENCES "teachers" ( "id" )
);

CREATE UNIQUE INDEX "PK_files_ind_plan" ON "files_ind_plan"
(
 "id"
);

CREATE INDEX "fkIdx_326" ON "files_ind_plan"
(
 "id_teacher"
);








-- ************************************** "files_acad_plan"

CREATE TABLE "files_acad_plan"
(
 "id"           serial NOT NULL,
 "file"         varchar(50) NOT NULL,
 "date"         date NOT NULL,
 "id_acad_plan" serial NOT NULL,
 CONSTRAINT "FK_232" FOREIGN KEY ( "id_acad_plan" ) REFERENCES "academic_plan" ( "id" )
);

CREATE UNIQUE INDEX "PK_files_acad_plan" ON "files_acad_plan"
(
 "id"
);

CREATE INDEX "fkIdx_232" ON "files_acad_plan"
(
 "id_acad_plan"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "files_proj_act"

CREATE TABLE "files_proj_act"
(
 "id"   serial NOT NULL,
 "file" varchar(50) NOT NULL,
 "date" date NOT NULL

);

CREATE UNIQUE INDEX "PK_files_proj_act" ON "files_proj_act"
(
 "id"
);








-- ************************************** "files_RPD"

CREATE TABLE "files_RPD"
(
 "id"         bigserial NOT NULL,
 "file"       varchar(50) NOT NULL,
 "date"       date NOT NULL,
 "id_teacher" serial NOT NULL,
 CONSTRAINT "FK_284" FOREIGN KEY ( "id_teacher" ) REFERENCES "teachers" ( "id" )
);

CREATE UNIQUE INDEX "PK_files_RPD" ON "files_RPD"
(
 "id"
);

CREATE INDEX "fkIdx_284" ON "files_RPD"
(
 "id_teacher"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "personalities"

CREATE TABLE "personalities"
(
 "id"         serial NOT NULL,
 "name"       varchar(50) NOT NULL,
 "surname"    varchar(50) NOT NULL,
 "patronymic" varchar(50) NOT NULL,
 "birthday"   date NOT NULL,
 "phone"      varchar(20) NOT NULL,
 "email"      varchar(40) NOT NULL,
 "status"     smallint NOT NULL

);

CREATE UNIQUE INDEX "PK_personalities" ON "personalities"
(
 "id"
);



COMMENT ON COLUMN "personalities"."status" IS '1 - студент, 2 - преподаватель';





-- ************************************** "groups"

CREATE TABLE "groups"
(
 "id"             serial NOT NULL,
 "id_specialties" serial NOT NULL,
 "name"           varchar(15) NOT NULL,
 CONSTRAINT "FK_83" FOREIGN KEY ( "id_specialties" ) REFERENCES "specialties" ( "id" )
);

CREATE UNIQUE INDEX "PK_groups" ON "groups"
(
 "id"
);

CREATE INDEX "fkIdx_83" ON "groups"
(
 "id_specialties"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "ranks"

CREATE TABLE "ranks"
(
 "id"   serial NOT NULL,
 "rank" varchar(50) NOT NULL

);

CREATE UNIQUE INDEX "PK_ranks" ON "ranks"
(
 "id"
);

COMMENT ON TABLE "ranks" IS 'Звание';






-- ************************************** "project_activities"

CREATE TABLE "project_activities"
(
 "id"          serial NOT NULL,
 "title"       varchar(50) NOT NULL,
 "id_file"     serial NOT NULL,
 "description" text NOT NULL,
 "start"       date NOT NULL,
 "end"         date NOT NULL,
 "link_trello" varchar(250) NOT NULL,
 "id_sub_unit" serial NOT NULL,
 CONSTRAINT "FK_329" FOREIGN KEY ( "id_sub_unit" ) REFERENCES "sub_unit" ( "id" ),
 CONSTRAINT "FK_98" FOREIGN KEY ( "id_file" ) REFERENCES "files_proj_act" ( "id" )
);

CREATE UNIQUE INDEX "PK_project_activities" ON "project_activities"
(
 "id"
);

CREATE INDEX "fkIdx_329" ON "project_activities"
(
 "id_sub_unit"
);

CREATE INDEX "fkIdx_98" ON "project_activities"
(
 "id_file"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "rights_roles"

CREATE TABLE "rights_roles"
(
 "id"          serial NOT NULL,
 "role"        varchar(50) NOT NULL,
 "id_teacher"  serial NOT NULL,
 "id_sub_unit" serial NOT NULL,
 CONSTRAINT "FK_270" FOREIGN KEY ( "id_teacher" ) REFERENCES "teachers" ( "id" ),
 CONSTRAINT "FK_273" FOREIGN KEY ( "id_sub_unit" ) REFERENCES "sub_unit" ( "id" )
);

CREATE UNIQUE INDEX "PK_таблица ролей" ON "rights_roles"
(
 "id"
);

CREATE INDEX "fkIdx_270" ON "rights_roles"
(
 "id_teacher"
);

CREATE INDEX "fkIdx_274" ON "rights_roles"
(
 "id_sub_unit"
);

COMMENT ON TABLE "rights_roles" IS 'Права выданные определенным преподавателям к определенным подразделениям и проектам';

COMMENT ON COLUMN "rights_roles"."role" IS 'Можно сделать smallint типо (РОП, Куратор и тд)';





-- ************************************** "semestr"

CREATE TABLE "semestr"
(
 "id"            serial NOT NULL,
 "id_discipline" serial NOT NULL,
 "semester"      int NOT NULL,
 "is_exam"       boolean NOT NULL,
 CONSTRAINT "FK_177" FOREIGN KEY ( "id_discipline" ) REFERENCES "disciplines" ( "id" )
);

CREATE UNIQUE INDEX "PK_Семестр" ON "semestr"
(
 "id"
);

CREATE INDEX "fkIdx_177" ON "semestr"
(
 "id_discipline"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "specialties"

CREATE TABLE "specialties"
(
 "id"            serial NOT NULL,
 "code"          varchar(20) NOT NULL,
 "title"         varchar(50) NOT NULL,
 "profile"       varchar(100) NOT NULL,
 "educ_form"     varchar(20) NOT NULL,
 "educ_programm" smallint NOT NULL,
 "educ_years"    int NOT NULL,
 "year_join"     date NOT NULL,
 "id_acad_plan"  serial NOT NULL,
 CONSTRAINT "FK_209" FOREIGN KEY ( "id_acad_plan" ) REFERENCES "academic_plan" ( "id" )
);

CREATE UNIQUE INDEX "PK_napravlenie" ON "specialties"
(
 "id"
);

CREATE INDEX "fkIdx_209" ON "specialties"
(
 "id_acad_plan"
);



COMMENT ON COLUMN "specialties"."profile" IS 'Профиль';
COMMENT ON COLUMN "specialties"."educ_form" IS 'очная, очно-заочная и тд';
COMMENT ON COLUMN "specialties"."educ_programm" IS '1 - бакалавр, 2 - магистр';
COMMENT ON COLUMN "specialties"."educ_years" IS 'Срок обучения';
COMMENT ON COLUMN "specialties"."year_join" IS 'Год набора';





-- ************************************** "students"

CREATE TABLE "students"
(
 "id"          serial NOT NULL,
 "id_person"   serial NOT NULL,
 "id_group"    serial NOT NULL,
 "id_proj_act" serial NOT NULL,
 CONSTRAINT "FK_14" FOREIGN KEY ( "id_person" ) REFERENCES "personalities" ( "id" ),
 CONSTRAINT "FK_31" FOREIGN KEY ( "id_group" ) REFERENCES "groups" ( "id" ),
 CONSTRAINT "FK_91" FOREIGN KEY ( "id_proj_act" ) REFERENCES "project_activities" ( "id" )
);

CREATE UNIQUE INDEX "PK_students" ON "students"
(
 "id"
);

CREATE INDEX "fkIdx_14" ON "students"
(
 "id_person"
);

CREATE INDEX "fkIdx_31" ON "students"
(
 "id_group"
);

CREATE INDEX "fkIdx_91" ON "students"
(
 "id_proj_act"
);







-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;


-- ************************************** "teachers"

CREATE TABLE "teachers"
(
 "id"             serial NOT NULL,
 "id_person"      serial NOT NULL,
 "position"       varchar(50) NOT NULL,
 "id_rank"        serial NOT NULL,
 "id_degree"      serial NOT NULL,
 "rate"           real NOT NULL,
 "hours_worked"   int NOT NULL,
 "RINC"           real NOT NULL,
 "web_of_science" real NOT NULL,
 "scopus"         real NOT NULL,
 "login"          varchar(25) NOT NULL,
 "password"       varchar(150) NOT NULL,
 "salt"           varchar(150) NOT NULL,
 CONSTRAINT "FK_21" FOREIGN KEY ( "id_person" ) REFERENCES "personalities" ( "id" ),
 CONSTRAINT "FK_45" FOREIGN KEY ( "id_rank" ) REFERENCES "ranks" ( "id" ),
 CONSTRAINT "FK_52" FOREIGN KEY ( "id_degree" ) REFERENCES "degree" ( "id" )
);

CREATE UNIQUE INDEX "PK_teachers" ON "teachers"
(
 "id"
);

CREATE INDEX "fkIdx_21" ON "teachers"
(
 "id_person"
);

CREATE INDEX "fkIdx_45" ON "teachers"
(
 "id_rank"
);

CREATE INDEX "fkIdx_52" ON "teachers"
(
 "id_degree"
);



COMMENT ON COLUMN "teachers"."rate" IS 'ставка';





-- ************************************** "sub_unit"

CREATE TABLE "sub_unit"
(
 "id"            serial NOT NULL,
 "title"         varchar(50) NOT NULL,
 "is_project"    boolean NOT NULL,
 "id_department" serial NOT NULL,
 CONSTRAINT "FK_323" FOREIGN KEY ( "id_department" ) REFERENCES "department" ( "id" )
);

CREATE UNIQUE INDEX "PK_sub_unit" ON "sub_unit"
(
 "id"
);

CREATE INDEX "fkIdx_323" ON "sub_unit"
(
 "id_department"
);

COMMENT ON TABLE "sub_unit" IS 'Подразделения ( условные САПР, ВЕБ и т.д. ), также сюда включаются проекты по ПД.';





