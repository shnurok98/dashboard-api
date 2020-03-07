-- 07.03.20 for v23.

/* Персоны:Студенты */
INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	birthday,
	phone,
	"email",
	"status"
) VALUES (
	'Игорь',
	'Степаненко',
	'Сергеевич',
	'1998-6-3',
	'8(800)555-3535',
	'stepanenko@mail.ru',
	1
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	birthday,
	phone,
	"email",
	"status"
) VALUES (
	'Александр',
	'Буравов',
	'Николаевич',
	'1998-10-25',
	'8(800)555-3535',
	'buravov@mail.ru',
	1
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	birthday,
	phone,
	"email",
	"status"
) VALUES (
	'Алексей',
	'Тремаскин',
	'Владимирович',
	'1998-12-10',
	'8(800)555-3535',
	'tremaskin@mail.ru',
	1
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	birthday,
	phone,
	"email",
	"status"
) VALUES (
	'Павел',
	'Бабушкин',
	'Михайлович',
	'1996-11-30',
	'8(800)555-3535',
	'babushkin@mail.ru',
	1
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	birthday,
	phone,
	"email",
	"status"
) VALUES (
	'Алина',
	'Борзикова',
	'Александровна',
	'1998-3-5',
	'8(800)555-3535',
	'borzikova@mail.ru',
	1
);
/* end Персоны:Студенты */

/* Персоны:Преподаватели */
INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	phone,
	"email",
	"status"
) VALUES (
	'Дмитрий',
	'Холодов',
	'Алексеевич',
	'8(800)555-3535',
	'holodov@mail.ru',
	2
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	phone,
	"email",
	"status"
) VALUES (
	'Антон',
	'Толстиков',
	'Витальевич',
	'8(800)555-3535',
	'tolstikov@mail.ru',
	2
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	phone,
	"email",
	"status"
) VALUES (
	'Анастасия',
	'Ковалева',
	'Александровна',
	'8(800)555-3535',
	'kovaleva@mail.ru',
	2
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	phone,
	"email",
	"status"
) VALUES (
	'Андрей',
	'Джунковский',
	'Владимирович',
	'8(800)555-3535',
	'babushkin@mail.ru',
	2
);

INSERT INTO personalities (
	"name",
	surname,
	patronymic,
	phone,
	"email",
	"status"
) VALUES (
	'Виктор',
	'Лянг',
	'Федорович',
	'8(800)555-3535',
	'lyang@mail.ru',
	2
);
/* end Персоны:Преподаватели */

/* Преподаватели */
INSERT INTO teachers
(
 "person_id",
 "position",
 "login",
 "password",
 "salt"
) VALUES (
	53,
	'Преподаватель',
	'holodov',
	'1',
	'1'
);

INSERT INTO teachers
(
 "person_id",
 "position",
 "login",
 "password",
 "salt"
) VALUES (
	54,
	'Преподаватель',
	'tolstikov',
	'1',
	'1'
);

INSERT INTO teachers
(
 "person_id",
 "position",
 "login",
 "password",
 "salt"
) VALUES (
	55,
	'Преподаватель',
	'kovaleva',
	'1',
	'1'
);

INSERT INTO teachers
(
 "person_id",
 "position",
 "login",
 "password",
 "salt"
) VALUES (
	56,
	'Преподаватель',
	'djunkovski',
	'1',
	'1'
);

INSERT INTO teachers
(
 "person_id",
 "position",
 "login",
 "password",
 "salt"
) VALUES (
	57,
	'Преподаватель',
	'lyang',
	'1',
	'1'
);
/* end Преподаватели */

INSERT INTO ranks (
	rank
) VALUES (
	"Звание"
);

INSERT INTO degree (
	degree
) VALUES (
	"Степень"
);

INSERT INTO files_ind_plan (
	file,
	"date"
) VALUES (
	"ссылка на файл",
	"2020-01-25"
);

-- INSERT INTO teachers (
--  "id_person"      ,
--  "position"       ,
--  "id_rank"        ,
--  "id_degree"      ,
--  "rate"           ,
--  "hours_worked"   ,
--  "RINC"           ,
--  "id_ind_plan"    ,
--  "web_of_science" ,
--  "scopus"         ,
--  "login"				,
--  "password"			,
--  "salt"				
-- ) VALUES (
-- 	1,
-- 	"Преподаватель",
-- 	1,
-- 	1,
-- 	0.5,
-- 	900,
-- 	0.5,
-- 	1,
-- 	0.1,
-- 	0.3,
-- 	"admin"
-- );