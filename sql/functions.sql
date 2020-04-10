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
	select jsonb_set(r_teacher::jsonb, '{role}'::text, v_role::jsonb) into r_teacher;
	
	return r_teacher;
end;
$function$
;
