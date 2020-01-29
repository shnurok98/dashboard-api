-- INSERT INTO personalities (
-- 	name,
-- 	surname,
-- 	patronymic,
-- 	birthday,
-- 	phone,
-- 	"e-mail",
-- 	status,
-- 	login,
-- 	password
-- ) VALUES (
-- 	'Ivan',
-- 	'Ivanov',
-- 	'Nikolaevich',
-- 	'1998-10-25',
-- 	880055,
-- 	'mail@mail.ru',
-- 	1,
-- 	'ivan',
-- 	'root'
-- );


INSERT INTO personalities (
	name,
	surname,
	patronymic,
	birthday,
	phone,
	"email",
	status
) VALUES (
	'Igor',
	'Ivanov',
	'Nikolaevich',
	'1998-10-25',
	'8(800)555-3535',
	'mail@mail.ru',
	2
);

INSERT INTO ranks (
	rank
) VALUES (
	'Звание'
);

INSERT INTO degree (
	degree
) VALUES (
	'Степень'
);

INSERT INTO files_ind_plan (
	file,
	"date"
) VALUES (
	'ссылка на файл',
	'2020-01-25'
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
-- 	'Преподаватель',
-- 	1,
-- 	1,
-- 	0.5,
-- 	900,
-- 	0.5,
-- 	1,
-- 	0.1,
-- 	0.3,
-- 	'admin'
-- );