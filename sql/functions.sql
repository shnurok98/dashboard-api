CREATE OR REPLACE FUNCTION public.pr_projects_s(i_project_id int) returns json
	LANGUAGE plpgsql
AS $$
	declare 
		v_sql text;
		v_json json;
	begin
		
		return (SELECT 
		    row_to_json(t, true) project
		  FROM (
		    SELECT p.*, (
		      SELECT array_to_json(array_agg(row_to_json(child))) from (
		        select sp.student_id, ps."name" , ps.surname
		        from students_projects sp, students S, personalities ps
		        where sp.project_id = p.id AND sp.student_id = S.id AND S.person_id = ps.id
		      ) child
		    ) students
		    FROM projects p 
		    WHERE p.id = i_project_id
		  ) t); 
	END;
$$;

-- создание проподавателя
-- SELECT public.pr_teachers_i('новый'::text,'препод'::text,'отчество'::text,'2020-04-09 23:20:27','phone'::text,'norbert'::text,1::smallint,'i_position'::text,null,null,null::real,1,1::real,1::real,1::real,'i_login'::text,'i_password'::text,'i_salt'::text, 1::smallint, 1);

CREATE OR REPLACE FUNCTION public.pr_teachers_i(i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_status smallint, i_position text, i_rank_id integer, i_degree_id integer, i_rate real, i_hours_worked integer, i_rinc real, i_web_of_science real, i_scopus real, i_login text, i_password text, i_salt text, i_role smallint, i_sub_unit_id integer)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
declare 
	v_person_id integer;
	v_sql record;
	v_role text;
	r_teacher json;
begin 
	INSERT INTO public.personalities 
		("name", surname, patronymic, birthday, phone, email, status) 
	VALUES 
		(i_name, i_surname, i_patronymic, i_birthday, i_phone, i_email, i_status) 
	RETURNING id 
	INTO v_person_id;
	
	INSERT INTO public.teachers 
		(person_id, position, rank_id,degree_id,rate,hours_worked,rinc,web_of_science,scopus,login,password,salt) 
	VALUES 
		(v_person_id, i_position ,i_rank_id ,i_degree_id ,i_rate ,i_hours_worked ,i_rinc ,i_web_of_science ,i_scopus ,i_login ,i_password ,i_salt ) 
	RETURNING * 
	INTO v_sql;
	
	INSERT INTO public.rights_roles
	("role", teacher_id, sub_unit_id)
	VALUES(i_role, (select v_sql.id), i_sub_unit_id)
	returning "role"
	into v_role;


	select row_to_json(v_sql) into r_teacher;

	
	return r_teacher;
end;
$function$
;

-- UPDATE teachers
-- SELECT public.pr_teachers_u(120,'Benedict'::text,'Cemberbetch'::text,'kekovich'::text,'2020-04-09 23:20:27','8 800'::text,'cumberbetxh'::text,'actor'::text,null,null,null,1,1::real,1::real,1::real);
create or replace function public.pr_teachers_u(
i_teacher_id integer,
i_name text, 
i_surname text, 
i_patronymic text, 
i_birthday timestamp, 
i_phone text, 
i_email text,
i_position text,
i_rank_id integer,
i_degree_id integer,
i_rate real,
i_hours_worked integer,
i_rinc real,
i_web_of_science real,
i_scopus real) 
returns integer as $$
declare 
	v_person_id integer;
	v_teacher_id integer;
begin 
	select t.person_id, t.id
	from teachers t
	where t.id = i_teacher_id 
	into v_person_id, v_teacher_id;
	
	UPDATE public.personalities
	SET "name" = i_name, surname = i_surname, patronymic = i_patronymic, birthday = i_birthday, phone = i_phone, email = i_email
	WHERE id = v_person_id;

	UPDATE public.teachers
	SET "position" = i_position, rank_id = i_rank_id, degree_id = i_degree_id, rate = i_rate, hours_worked = i_hours_worked, rinc = i_rinc, web_of_science = i_web_of_science, scopus = i_scopus
	WHERE id = i_teacher_id;

	return v_teacher_id;
end;
$$ language plpgsql;
	

-- INSERT students
-- SELECT public.pr_students_i('Игорь'::text,'Степаненко'::text,'Сергеевич'::text,'2020-04-09 23:20:27','999'::text,'stepa@twex'::text, 1::smallint, 1);
create or replace function public.pr_students_i(
i_name text, 
i_surname text, 
i_patronymic text, 
i_birthday timestamp, 
i_phone text, 
i_email text,
i_status smallint,
i_group_id integer) 
returns integer as $$
declare 
	v_person_id integer;
	r_student_id integer;
begin 
	INSERT INTO public.personalities 
		("name", surname, patronymic, birthday, phone, email, status) 
	VALUES 
		(i_name, i_surname, i_patronymic, i_birthday, i_phone, i_email, i_status) 
	RETURNING id 
	INTO v_person_id;
	
	INSERT INTO public.students 
		(person_id, group_id) 
	VALUES 
		(v_person_id, i_group_id) 
	RETURNING id 
	INTO r_student_id;
	

	return r_student_id;
end;
$$ language plpgsql;


-- UPDATE students
-- SELECT public.pr_students_u(100,'Не Игорь'::text,'Степаненко'::text,'Сергеевич'::text,'2020-04-09 23:20:27','999'::text,'stepa@twex'::text, 1::smallint, 100);
create or replace function public.pr_students_u(
i_student_id integer,
i_name text, 
i_surname text, 
i_patronymic text, 
i_birthday timestamp, 
i_phone text, 
i_email text,
i_status smallint,
i_group_id integer) 
returns integer as $$
declare 
	v_person_id integer;
begin 
	select s.person_id
	from students s
	where s.id = i_student_id
	into v_person_id;
	
	UPDATE public.personalities
	SET "name" = i_name, surname = i_surname, patronymic = i_patronymic, birthday = i_birthday, phone = i_phone, email = i_email
	WHERE id = v_person_id;

	UPDATE public.students
	SET group_id = i_group_id 
	WHERE id = i_student_id;

	return i_student_id;
end;
$$ language plpgsql;

-- SELECT acad_dicip
-- SELECT public.pr_acadplan_s(1);
CREATE OR REPLACE FUNCTION public.pr_acadplan_s(i_acadplan_id int) returns json
	LANGUAGE plpgsql
AS $$
	declare 
		v_sql text;
		v_json json;
	begin
		
		return (SELECT 
		    row_to_json(t, true) acad_plan
		  FROM (
		    SELECT P.*, (
		      SELECT array_to_json(array_agg(row_to_json(child))) from (
		        select D.*
		        from acad_discipline D 
		        where D.acad_plan_id = P.id
		      ) child
		    ) disciplines
		    FROM acad_plan P 
		    WHERE P.id = i_acadplan_id
		  ) t); 
	END;
$$;

-- SELECT dep_load
-- SELECT public.pr_depload_s(1);
CREATE OR REPLACE FUNCTION public.pr_depload_s(i_depload_id int) returns json
	LANGUAGE plpgsql
AS $$
	declare 
		v_sql text;
		v_json json;
	begin
		
		return (SELECT 
		    row_to_json(t, true) dep_load
		  FROM (
		    SELECT L.*, (
		      SELECT array_to_json(array_agg(row_to_json(child))) from (
		        select D.*, (
							select array_to_json(array_agg(row_to_json(gr_child))) from (
								select G.id, G."name", (select count(S.id) from students S where S.group_id = G.id)
								from "groups" G, disciplines_groups DG
								where G.id = DG.group_id AND DG.discipline_id = D.id
							) gr_child
						) "groups"
		        from disciplines D 
		        where D.dep_load_id = L.id
		      ) child
		    ) disciplines
		    FROM dep_load L 
		    WHERE L.id = i_depload_id
		  ) t); 
	END;
$$;

-- insert acad_plan
-- SELECT public.pr_acadplan_i($1::jsonb) acad_plan_id;
create or replace function public.pr_acadplan_i(
i_acadplan jsonb
) 
returns integer as $$
declare 
	v_acadplan_id integer;
	v_disciplines jsonb;
	v_arr_cnt int;

	v_acadblock_id integer;
	v_acadpart_id integer;
	v_acadmodule_id integer;

	v_exams integer[];
	v_zachets integer[];
	v_semesters integer[];
begin 
	INSERT INTO acad_plan
	(modified_date, specialties_id)
	values ( (i_acadplan->>'modified_date')::timestamp ,(i_acadplan->>'specialties_id')::integer)
	returning id into v_acadplan_id;

	select i_acadplan->'disciplines' into v_disciplines;

	v_arr_cnt = jsonb_array_length(v_disciplines);

	for i in 0..(v_arr_cnt-1) loop
	
		insert into acad_block ("name", "code") 
		values ( (v_disciplines->i)->>'acad_block_name', (v_disciplines->i)->>'acad_block_code' )
		on conflict ("name", "code") do update set "name" = (v_disciplines->i)->>'acad_block_name' 
		returning id into v_acadblock_id;
		
		insert into acad_part ("name", "code") 
		values ( (v_disciplines->i)->>'acad_part_name', (v_disciplines->i)->>'acad_part_code' )
		on conflict ("name", "code") do update set "name" = (v_disciplines->i)->>'acad_part_name' 
		returning id into v_acadpart_id;
	
		insert into acad_module ("name", "code") 
		values ( (v_disciplines->i)->>'acad_module_name', (v_disciplines->i)->>'acad_module_code' )
		on conflict ("name", "code") do update set "name" = (v_disciplines->i)->>'acad_module_name' 
		returning id into v_acadmodule_id;
	
--		string_to_array(  trim( both '[]' from ('[68, 68, 34, 34]'::jsonb)::text ) , ',', 'null' )
	
		select string_to_array( trim(both '[]' from ((v_disciplines->i)->>'exams')::text ), ', ', 'null' ),
			string_to_array( trim(both '[]' from ((v_disciplines->i)->>'zachets')::text ), ', ', 'null' ),
			string_to_array( trim(both '[]' from ((v_disciplines->i)->>'semesters')::text ), ', ', 'null' )
			into v_exams, v_zachets, v_semesters;
	
		insert into acad_discipline (
			"name",
			"code",
			"zet",
		 	"hours_lec",
		 	"hours_lab",
		 	"hours_sem",
		 	"acad_plan_id",
		 	"acad_block_id",
		 	"acad_part_id",
		 	"acad_module_id",
		 	"exams",
		 	"zachets",
		 	"semesters",
		 	"is_optional"
		) 
		values ( 
			(v_disciplines->i)->>'name', 
			(v_disciplines->i)->>'code', 
			((v_disciplines->i)->>'zet')::integer,
			((v_disciplines->i)->>'hours_lec')::integer,
			((v_disciplines->i)->>'hours_lab')::integer,
			((v_disciplines->i)->>'hours_sem')::integer,
			v_acadplan_id,
			v_acadblock_id,
			v_acadpart_id,
			v_acadmodule_id,
			v_exams,
			v_zachets,
			v_semesters,
			((v_disciplines->i)->>'is_optional')::boolean
		);
	
	end loop;

	return v_acadplan_id;
end;
$$ language plpgsql;

-- INSERT DEP LOAD
-- SELECT public.pr_depload_i($1::jsonb) id;
create or replace function public.pr_depload_i(
i_depload jsonb
) 
returns integer as $$
declare 
	v_depload_id integer;
	v_disciplines jsonb;
	v_groups jsonb;

	v_dis_cnt int;
	v_gr_cnt int;

	v_dis_id int;
	v_gr_id int;
begin 
	INSERT INTO dep_load
	(department_id, begin_date, end_date, modified_date)
	VALUES(
		(i_depload->>'department_id')::integer, 
		(i_depload->>'begin_date')::timestamp, 
		(i_depload->>'end_date')::timestamp, 
		(i_depload->>'modified_date')::timestamp)
	returning id into v_depload_id;

	

	select i_depload->'disciplines' into v_disciplines;
	v_dis_cnt = jsonb_array_length(v_disciplines);

	

	for i in 0..(v_dis_cnt-1) loop
	
		insert into disciplines (
			"name",
			hours_con_project,
			hours_lec,
			hours_sem,
			hours_lab,
			hours_con_exam,
			hours_zachet,
			hours_exam,
			hours_kurs_project,
			hours_gek,
			hours_ruk_prakt,
			hours_ruk_vkr,
			hours_ruk_mag,
			hours_ruk_aspirant,
			semester_num,
			acad_discipline_id,
			dep_load_id,
			is_approved
		) 
		values ( 
			(v_disciplines->i)->>'name', 
			((v_disciplines->i)->>'hours_con_project')::real, 
			((v_disciplines->i)->>'hours_lec')::real,
			((v_disciplines->i)->>'hours_sem')::real,
			((v_disciplines->i)->>'hours_lab')::real,
			((v_disciplines->i)->>'hours_con_exam')::real,
			((v_disciplines->i)->>'hours_zachet')::real,
			((v_disciplines->i)->>'hours_exam')::real,
			((v_disciplines->i)->>'hours_kurs_project')::real,
			((v_disciplines->i)->>'hours_gek')::real,
			((v_disciplines->i)->>'hours_ruk_prakt')::real,
			((v_disciplines->i)->>'hours_ruk_vkr')::real,
			((v_disciplines->i)->>'hours_ruk_mag')::real,
			((v_disciplines->i)->>'hours_ruk_aspirant')::real,
			((v_disciplines->i)->>'semester_num')::integer,
			((v_disciplines->i)->>'acad_discipline_id')::integer,
			v_depload_id,
			((v_disciplines->i)->>'is_approved')::boolean
		)
		returning id into v_dis_id;
	
		select (v_disciplines->i)->'groups' into v_groups;
	
		v_gr_cnt = jsonb_array_length(v_groups);
	
		for j in 0..(v_gr_cnt-1) loop
			
			select id from "groups" where "name" = v_groups->>j into v_gr_id;
			insert into disciplines_groups (discipline_id, group_id) values (v_dis_id, v_gr_id);
		
		end loop;
	
	end loop;

	return v_depload_id;
end;
$$ language plpgsql;

-- UPDATE discipline
-- SELECT public.pr_discipline_u(${+req.params.discipline_id}, ${req.body});
create or replace function public.pr_discipline_u(
	i_discipline_id integer,
	i_discipline jsonb
) 
returns integer as $$
declare 
	v_groups jsonb;

	v_gr_cnt int;

	v_gr_id int;
begin 
	
	UPDATE disciplines
	SET 
		"name" = 				i_discipline->>'name', 
		hours_con_project = 	(i_discipline->>'hours_con_project')::real, 
		hours_lec = 			(i_discipline->>'hours_lec')::real,
		hours_sem = 			(i_discipline->>'hours_sem')::real, 
		hours_lab = 			(i_discipline->>'hours_lab')::real,
		hours_con_exam = 		(i_discipline->>'hours_con_exam')::real,
		hours_zachet = 			(i_discipline->>'hours_zachet')::real,
		hours_exam = 			(i_discipline->>'hours_exam')::real,
		hours_kurs_project = 	(i_discipline->>'hours_kurs_project')::real,
		hours_gek = 			(i_discipline->>'hours_gek')::real,
		hours_ruk_prakt = 		(i_discipline->>'hours_ruk_prakt')::real,
		hours_ruk_vkr = 		(i_discipline->>'hours_ruk_vkr')::real,
		hours_ruk_mag = 		(i_discipline->>'hours_ruk_mag')::real, 
		hours_ruk_aspirant = 	(i_discipline->>'hours_ruk_aspirant')::real,
		semester_num = 			(i_discipline->>'semester_num')::integer,
		acad_discipline_id = 	(i_discipline->>'acad_discipline_id')::integer,
		is_approved = 			(i_discipline->>'is_approved')::boolean
	WHERE id = i_discipline_id;
	
	delete from disciplines_groups where discipline_id = i_discipline_id ;

	select i_discipline->'groups' into v_groups;
	
	v_gr_cnt = jsonb_array_length(v_groups);

	for j in 0..(v_gr_cnt-1) loop
		
		select id from "groups" where "name" = v_groups->>j into v_gr_id;
		insert into disciplines_groups (discipline_id, group_id) values (i_discipline_id, v_gr_id);
	
	end loop;

	return i_discipline_id;
end;
$$ language plpgsql;

-- Добавление студентов к проекту

create or replace function public.pr_projects_students_i(
i_project_id integer,
i_students jsonb
) 
returns integer as $$
declare 
	v_arr_cnt int;
	v_students jsonb;
begin 
	select i_students->'students_ids' into v_students;
	
	v_arr_cnt = jsonb_array_length(v_students);

	for i in 0..(v_arr_cnt-1) loop
	
		INSERT INTO students_projects
		(student_id, project_id, "date")
		VALUES((v_students->>i)::integer, i_project_id, current_timestamp);

	end loop;

	return i_project_id;
end;
$$ language plpgsql;