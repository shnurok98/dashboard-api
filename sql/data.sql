-- v.30 | 08.05.20 

INSERT INTO public.department (id,"name") VALUES 
(1,'Информатика и вычислительная техника')
,(2,'Проектная деятельность');

INSERT INTO public.sub_unit (id,"name",department_id) VALUES 
(1,'САПР',1)
,(2,'ВЕБ',1)
,(3,'КИС',1)
,(4,'Дашборд',2);

INSERT INTO public.specialties (id,code,"name",profile,educ_form,educ_programm,educ_years,year_join,sub_unit_id) VALUES 
(2,'09.03.01','Информатика и вычислительная техника','Интеграция и программирование в САПР','Очная',1,4,'2016-09-01',1);

INSERT INTO acad_plan (id, modified_date, specialties_id) VALUES 
(1,'2016-09-01 09:00:00.000', 2);

INSERT INTO acad_block (id,"name",code) VALUES 
(1,'БЛОК 1. Дисциплины (модули)','Б.1'),
(2,'БЛОК 2. Практика','Б.2'),
(3,'БЛОК 3. Государственная итоговая аттестация','Б.3');

INSERT INTO acad_part (id,"name",code) VALUES 
(1,'Базовая часть','Б.1.1'),
(2,'Вариативная часть','Б.1.2'),
(3,'Дисциплины по выбору студента','Б.1.ДВ');

INSERT INTO acad_module (id,"name",code) VALUES 
(1,'Модуль "Инностранный язык"','Б.1.1.1'),
(2,'Модуль "Русский язык и культура речи"','Б.1.1.2'),
(3,'Модуль "Навыки эффективной презентации"','Б.1.1.3'),
(4,'Модуль "Безопасность жизнедеятельности"','Б.1.1.4');

INSERT INTO public."acad_discipline" (id, "name", code, zet, hours_lec, hours_lab, hours_sem, acad_plan_id, acad_block_id, acad_part_id, acad_module_id, exams, zachets, semesters, is_optional) VALUES 
(1, 'Инностранный язык', 'Б.1.1.1',              9, null, null,  162, 1, 1, 1,  1, null, '{1,2,3}', '{54,54,54}', false),
(2, 'Русский язык и культура речи', 'Б.1.1.2',   2, null, 36,    null, 1, 1, 1, 2, null, '{1}', '{36}', false),
(3, 'Навыки эффективной презентации', 'Б.1.1.3', 2, null, 36,    null, 1, 1, 1, 3, null, '{2}', '{null, 36}', false),
(4, 'Безопасность жизнедеятельности', 'Б.1.1.4', 2, 18,   18,    null, 1, 1, 1, 4, null, '{4}', '{null, null, null, 36}', false);

INSERT INTO public."dep_load" (id, department_id, begin_date, end_date, modified_date) VALUES 
(1, 1, '2016-09-01 09:00:00.000','2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000'),
(2, 2, '2016-09-01 09:00:00.000','2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000'),
(3, 1, '2016-09-01 09:00:00.000','2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000'),
(4, 2, '2016-09-01 09:00:00.000','2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000');
 
INSERT INTO public.personalities (id,"name",surname,patronymic,birthday,phone,email,status) VALUES 
(1,'Игорь','Степаненко','Сергеевич','1998-06-03','8(800)555-3535','stepanenko@mail.ru',1)
,(2,'Александр','Буравов','Николаевич','1998-10-25','8(800)555-3535','buravov@mail.ru',1)
,(3,'Алексей','Тремаскин','Владимирович','1998-12-10','8(800)555-3535','tremaskin@mail.ru',1)
,(4,'Павел','Бабушкин','Михайлович','1996-11-30','8(800)555-3535','babushkin@mail.ru',1)
,(5,'Алина','Борзикова','Александровна','1998-03-05','8(800)555-3535','borzikova@mail.ru',1)
,(53,'Дмитрий','Холодов','Алексеевич',NULL,'8(800)555-3535','holodov@mail.ru',2)
,(54,'Антон','Толстиков','Витальевич',NULL,'8(800)555-3535','tolstikov@mail.ru',2)
,(55,'Анастасия','Ковалева','Александровна',NULL,'8(800)555-3535','kovaleva@mail.ru',2)
,(57,'Виктор','Лянг','Федорович',NULL,'8(800)555-3535','lyang@mail.ru',2)
,(56,'Андрей','Джунковский','Владимирович',NULL,'8(800)555-3535','djunkovski@mail.ru',2);

INSERT INTO public."ranks" (id, "name") VALUES 
(1,'Аспирант'),
(2,'Ассистент'),
(3,'Ведущий научный сотрудник'),
(4,'Главный научный сотрудник'),
(5,'Докторант'),
(6,'Доцент'),
(7,'Младший научный сотрудник');

INSERT INTO public."degree" (id, "name") VALUES 
(1,'Кандидат наук'),
(2,'Доктор наук');

INSERT INTO public.teachers (id,person_id,"position",rank_id,degree_id,rate,hours_worked,rinc,web_of_science,scopus,login,"password",salt) VALUES 
(1,53,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'holodov','$2b$12$WJPfMpLjWz/fRtn21qiy4eyuprgS2YCNSmlUmwOdjZHUjVq33Q7Hi','$2b$12$WJPfMpLjWz/fRtn21qiy4e')
,(2,54,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tolstikov','$2b$12$H2FY2xgNEANnRv69.gXSruq35I50F6wm5OslvDN0uFk.ky09wJ/MW','$2b$12$H2FY2xgNEANnRv69.gXSru')
,(3,55,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'kovaleva','$2b$12$IH8kIKTXrM3UXyDs1JyFOe3.oBjDWnAo2zMVO2Q0MLR8hINLEH7wm','$2b$12$IH8kIKTXrM3UXyDs1JyFOe')
,(4,56,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'djunkovski','$2b$12$Qh.8rPRjF.eYOiGPo6F.ReKE32vdJmHdvifhQTvxzKTv.8ycU73IC','$2b$12$Qh.8rPRjF.eYOiGPo6F.Re')
,(5,57,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'lyang','$2b$12$S6ARaLllzdaHhpMPLTvn8uU9ycBlW92zxuO.R1ImCULrMoWkqyn0u','$2b$12$S6ARaLllzdaHhpMPLTvn8u');

INSERT INTO public.disciplines (id,"name",hours_con_project,hours_lec,hours_sem,hours_lab,hours_con_exam,hours_zachet,hours_exam,hours_kurs_project,hours_gek,hours_ruk_prakt,hours_ruk_vkr,hours_ruk_mag,hours_ruk_aspirant,semester_num,acad_discipline_id,dep_load_id,is_approved) VALUES 
(1,'Инностранный язык',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,1,false)
,(2,'Русский язык и культура речи',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,2,false)
,(3,'Навыки эффективной презентации',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,3,false)
,(4,'Безопасность жизнедеятельности',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,4,false)
;

INSERT INTO public."files_acad_plan" (id, "name", "path", ext, modified_date, create_date, acad_plan_id, teacher_id) VALUES 
(1, 'files_acad_plan_1', 'text_1', '1', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', 1, 1);

INSERT INTO public."files_ind_plan" (id, "name", "path", ext, modified_date, create_date, teacher_id) VALUES 
(1, 'files_ind_plan_1', 'text_1', '1', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', 1),
(2, 'files_ind_plan_2', 'text_2', '2', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', 2);

INSERT INTO public."files_rpd" (id, "name", "path", ext, modified_date, create_date, teacher_id, discipline_id) VALUES 
(1, 'files_rpd_1', 'text_1', '1', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', 1, 1),
(2, 'files_rpd_2', 'text_2', '2', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', 2, 2);

INSERT INTO public."rights_roles" (id, "role", teacher_id, sub_unit_id) VALUES 
(1, 2, 1, 1),
(2, 4, 1, 1),
(3, 2, 2, 1),
(4, 3, 2, 1),
(5, 2, 3, 1),
(6, 2, 4, 1),
(7, 1, 5, 1);


INSERT INTO public."projects" (id, "name", description, begin_date, end_date, link_trello, sub_unit_id, teacher_id) VALUES 
(1, 'project_1', 'description_1', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', null, 1, 1),
(2, 'project_1', 'description_2', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', null, 1, 2);

INSERT INTO public."files_projects" (id, "name", "path", ext, modified_date, create_date, teacher_id, project_id) VALUES 
(1, 'files_projects_1', 'text_1', '1', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', 1, 1),
(2, 'files_projects_2', 'text_2', '2', '2016-09-01 09:00:00.000', '2016-09-01 09:00:00.000', 2, 2);
 
INSERT INTO public."groups" (id,specialties_id,"name") VALUES 
(1,2,'161-342');

INSERT INTO public.students (id,person_id,group_id) VALUES 
(1,1,1)
,(2,2,1)
,(3,3,1)
,(4,4,1)
,(5,5,1);

INSERT INTO public."students_projects" (id, student_id, project_id, "date") VALUES 
(1, 1, 1, '2016-09-01 09:00:00.000'),
(2, 2, 2, '2016-09-01 09:00:00.000');

