-- v.25 | 09.03.20

INSERT INTO public.academic_plan (id) VALUES 
(1)
;INSERT INTO public.discip_blocks (id,code,"name") VALUES 
(1,'А1','Обязательная часть')
;INSERT INTO public.discip_modules (id,code,"name",block_id) VALUES 
(1,'А.1.1','Модуль "Иностранный язык"',1)
;INSERT INTO public.disciplines (id,module_id,"name",code,hours_lec,hours_lab,hours_prakt,hours_self) VALUES 
(2,1,'Технический перевод','А.1.1.1',36,0,72,36)
;INSERT INTO public.semestr (id,discipline_id,semester,is_exam) VALUES 
(1,2,1,false)
,(2,2,4,true)
;INSERT INTO public.blocks_for_acad_plan (id,acad_plan_id,discip_blocks_id) VALUES 
(1,1,1)
;INSERT INTO public.personalities (id,"name",surname,patronymic,birthday,phone,email,status) VALUES 
(1,'Игорь','Степаненко','Сергеевич','1998-06-03','8(800)555-3535','stepanenko@mail.ru',1)
,(2,'Александр','Буравов','Николаевич','1998-10-25','8(800)555-3535','buravov@mail.ru',1)
,(3,'Алексей','Тремаскин','Владимирович','1998-12-10','8(800)555-3535','tremaskin@mail.ru',1)
,(4,'Павел','Бабушкин','Михайлович','1996-11-30','8(800)555-3535','babushkin@mail.ru',1)
,(5,'Алина','Борзикова','Александровна','1998-03-05','8(800)555-3535','borzikova@mail.ru',1)
,(53,'Дмитрий','Холодов','Алексеевич',NULL,'8(800)555-3535','holodov@mail.ru',2)
,(54,'Антон','Толстиков','Витальевич',NULL,'8(800)555-3535','tolstikov@mail.ru',2)
,(55,'Анастасия','Ковалева','Александровна',NULL,'8(800)555-3535','kovaleva@mail.ru',2)
,(57,'Виктор','Лянг','Федорович',NULL,'8(800)555-3535','lyang@mail.ru',2)
,(56,'Андрей','Джунковский','Владимирович',NULL,'8(800)555-3535','djunkovski@mail.ru',2)
;INSERT INTO public.teachers (id,person_id,"position",rank_id,degree_id,rate,hours_worked,rinc,web_of_science,scopus,login,"password",salt) VALUES 
(1,53,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'holodov','$2b$12$WJPfMpLjWz/fRtn21qiy4eyuprgS2YCNSmlUmwOdjZHUjVq33Q7Hi','$2b$12$WJPfMpLjWz/fRtn21qiy4e')
,(2,54,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'tolstikov','$2b$12$H2FY2xgNEANnRv69.gXSruq35I50F6wm5OslvDN0uFk.ky09wJ/MW','$2b$12$H2FY2xgNEANnRv69.gXSru')
,(3,55,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'kovaleva','$2b$12$IH8kIKTXrM3UXyDs1JyFOe3.oBjDWnAo2zMVO2Q0MLR8hINLEH7wm','$2b$12$IH8kIKTXrM3UXyDs1JyFOe')
,(4,56,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'djunkovski','$2b$12$Qh.8rPRjF.eYOiGPo6F.ReKE32vdJmHdvifhQTvxzKTv.8ycU73IC','$2b$12$Qh.8rPRjF.eYOiGPo6F.Re')
,(5,57,'Преподаватель',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'lyang','$2b$12$S6ARaLllzdaHhpMPLTvn8uU9ycBlW92zxuO.R1ImCULrMoWkqyn0u','$2b$12$S6ARaLllzdaHhpMPLTvn8u')
;INSERT INTO public.department (id,"name") VALUES 
(1,'Информатика и вычислительная техника')
,(2,'Проектная деятельность')
;INSERT INTO public.sub_unit (id,"name",is_project,department_id) VALUES 
(1,'САПР',false,1)
,(2,'ВЕБ',false,1)
,(3,'КИС',false,1)
,(4,'Дашборд',true,2)
;INSERT INTO public.specialties (id,code,"name",profile,educ_form,educ_programm,educ_years,year_join,acad_plan_id,sub_unit_id) VALUES 
(2,'09.03.01','Информатика и вычислительная техника','Интеграция и программирование в САПР','Очная',1,4,'2016-09-01',1,1)
;INSERT INTO public."groups" (id,specialties_id,"name") VALUES 
(1,2,'161-342')
;INSERT INTO public.students (id,person_id,group_id) VALUES 
(1,1,1)
,(2,2,1)
,(3,3,1)
,(4,4,1)
,(5,5,1)
;