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
		        select sp.student_id
		        from students_projects sp
		        where sp.project_id = p.id
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
begin 
	select t.person_id
	from teachers t
	where t.id = i_teacher_id 
	into v_person_id;
	
	UPDATE public.personalities
	SET "name" = i_name, surname = i_surname, patronymic = i_patronymic, birthday = i_birthday, phone = i_phone, email = i_email
	WHERE id = v_person_id;

	UPDATE public.teachers
	SET "position" = i_position, rank_id = i_rank_id, degree_id = i_degree_id, rate = i_rate, hours_worked = i_hours_worked, rinc = i_rinc, web_of_science = i_web_of_science, scopus = i_scopus
	WHERE id = i_teacher_id;

	return i_teacher_id;
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
		        select D.*
		        from disciplines D 
		        where D.dep_load_id = L.id
		      ) child
		    ) disciplines
		    FROM dep_load L 
		    WHERE L.id = i_depload_id
		  ) t); 
	END;
$$;