CREATE TABLE "files_ind_plan"
(
 "id"   int,
 "file" varchar(50) NOT NULL,
 "date" date NOT NULL

);

CREATE UNIQUE INDEX "PK_files_ind_plan" ON "files_ind_plan"
(
 "id"
);




CREATE TABLE "degree"
(
 "id"     int,
 "degree" varchar(50) NOT NULL

);

CREATE UNIQUE INDEX "PK_degree" ON "degree"
(
 "id"
);




CREATE TABLE "personalities"
(
 "id"         serial,
 "name"       varchar(50),
 "surname"    varchar(50),
 "patronymic" varchar(50),
 "birthday"   date,
 "phone"      varchar(20),
 "email"      varchar(40),
 "status"     smallint
);

CREATE UNIQUE INDEX "PK_personalities" ON "personalities"
(
 "id"
);



COMMENT ON COLUMN "personalities"."status" IS '1 - студент, 2 - преподаватель';




CREATE TABLE "groups"
(
 "id"             serial,
 "id_acad_plan"   int NOT NULL,
 "id_napravlenie" serial NOT NULL,
 "name"           varchar(15) NOT NULL,
 "year"           int NOT NULL,
 CONSTRAINT "FK_38" FOREIGN KEY ( "id_acad_plan" ) REFERENCES "academic_plan" ( "id" ),
 CONSTRAINT "FK_83" FOREIGN KEY ( "id_napravlenie" ) REFERENCES "specialties" ( "id" )
);

CREATE UNIQUE INDEX "PK_groups" ON "groups"
(
 "id"
);

CREATE INDEX "fkIdx_38" ON "groups"
(
 "id_acad_plan"
);

CREATE INDEX "fkIdx_83" ON "groups"
(
 "id_napravlenie"
);





CREATE TABLE "specialties"
(
 "id"           serial,
 "code"         varchar(20) NOT NULL,
 "title"        varchar(50) NOT NULL,
 "educ_program" smallint NOT NULL

);

CREATE UNIQUE INDEX "PK_napravlenie" ON "specialties"
(
 "id"
);



COMMENT ON COLUMN "specialties"."educ_program" IS '1 - бакалавр, 2 - магистр, 3 - специалитет';





CREATE TABLE "ranks"
(
 "id"   int,
 "rank" varchar(50) NOT NULL

);

CREATE UNIQUE INDEX "PK_ranks" ON "ranks"
(
 "id"
);





CREATE TABLE "teachers"
(
 "id"             serial,
 "id_person"      serial NOT NULL,
 "position"       varchar(50) NOT NULL,
 "id_rank"        int NOT NULL,
 "id_degree"      int NOT NULL,
 "rate"           real NOT NULL,
 "hours_worked"   int NOT NULL,
 "RINC"           real NOT NULL,
 "id_ind_plan"    int NOT NULL,
 "web_of_science" real NOT NULL,
 "scopus"         real NOT NULL,
 "login"				varchar(25) NOT NULL,
 "password"			varchar(150),
 "salt"				varchar(150),
 CONSTRAINT "FK_21" FOREIGN KEY ( "id_person" ) REFERENCES "personalities" ( "id" ),
 CONSTRAINT "FK_45" FOREIGN KEY ( "id_rank" ) REFERENCES "ranks" ( "id" ),
 CONSTRAINT "FK_52" FOREIGN KEY ( "id_degree" ) REFERENCES "degree" ( "id" ),
 CONSTRAINT "FK_62" FOREIGN KEY ( "id_ind_plan" ) REFERENCES "files_ind_plan" ( "id" )
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

CREATE INDEX "fkIdx_62" ON "teachers"
(
 "id_ind_plan"
);





CREATE TABLE "students"
(
 "id"          serial,
 "id_person"   serial NOT NULL,
 "id_group"    serial NOT NULL,
 "id_proj_act" int NOT NULL,
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