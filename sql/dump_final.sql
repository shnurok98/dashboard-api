--
-- PostgreSQL database dump
--

-- Dumped from database version 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pr_acadplan_i(jsonb); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_acadplan_i(i_acadplan jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_acadplan_i(i_acadplan jsonb) OWNER TO diplom_user;

--
-- Name: pr_acadplan_s(integer); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_acadplan_s(i_acadplan_id integer) RETURNS json
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


ALTER FUNCTION public.pr_acadplan_s(i_acadplan_id integer) OWNER TO diplom_user;

--
-- Name: pr_depload_i(jsonb); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_depload_i(i_depload jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_depload_i(i_depload jsonb) OWNER TO diplom_user;

--
-- Name: pr_depload_s(integer); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_depload_s(i_depload_id integer) RETURNS json
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


ALTER FUNCTION public.pr_depload_s(i_depload_id integer) OWNER TO diplom_user;

--
-- Name: pr_discipline_u(integer, jsonb); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_discipline_u(i_discipline_id integer, i_discipline jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_discipline_u(i_discipline_id integer, i_discipline jsonb) OWNER TO diplom_user;

--
-- Name: pr_projects_s(integer); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_projects_s(i_project_id integer) RETURNS json
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


ALTER FUNCTION public.pr_projects_s(i_project_id integer) OWNER TO diplom_user;

--
-- Name: pr_projects_students_i(integer, jsonb); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_projects_students_i(i_project_id integer, i_students jsonb) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_projects_students_i(i_project_id integer, i_students jsonb) OWNER TO diplom_user;

--
-- Name: pr_students_i(text, text, text, timestamp without time zone, text, text, smallint, integer); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_students_i(i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_status smallint, i_group_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_students_i(i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_status smallint, i_group_id integer) OWNER TO diplom_user;

--
-- Name: pr_students_u(integer, text, text, text, timestamp without time zone, text, text, smallint, integer); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_students_u(i_student_id integer, i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_status smallint, i_group_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_students_u(i_student_id integer, i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_status smallint, i_group_id integer) OWNER TO diplom_user;

--
-- Name: pr_teachers_i(text, text, text, timestamp without time zone, text, text, smallint, text, integer, integer, real, integer, real, real, real, text, text, text, smallint, integer); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_teachers_i(i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_status smallint, i_position text, i_rank_id integer, i_degree_id integer, i_rate real, i_hours_worked integer, i_rinc real, i_web_of_science real, i_scopus real, i_login text, i_password text, i_salt text, i_role smallint, i_sub_unit_id integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_teachers_i(i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_status smallint, i_position text, i_rank_id integer, i_degree_id integer, i_rate real, i_hours_worked integer, i_rinc real, i_web_of_science real, i_scopus real, i_login text, i_password text, i_salt text, i_role smallint, i_sub_unit_id integer) OWNER TO diplom_user;

--
-- Name: pr_teachers_u(integer, text, text, text, timestamp without time zone, text, text, text, integer, integer, real, integer, real, real, real); Type: FUNCTION; Schema: public; Owner: diplom_user
--

CREATE FUNCTION public.pr_teachers_u(i_teacher_id integer, i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_position text, i_rank_id integer, i_degree_id integer, i_rate real, i_hours_worked integer, i_rinc real, i_web_of_science real, i_scopus real) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.pr_teachers_u(i_teacher_id integer, i_name text, i_surname text, i_patronymic text, i_birthday timestamp without time zone, i_phone text, i_email text, i_position text, i_rank_id integer, i_degree_id integer, i_rate real, i_hours_worked integer, i_rinc real, i_web_of_science real, i_scopus real) OWNER TO diplom_user;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acad_block; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.acad_block (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    code character varying(25) NOT NULL
);


ALTER TABLE public.acad_block OWNER TO diplom_user;

--
-- Name: acad_block_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.acad_block_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acad_block_id_seq OWNER TO diplom_user;

--
-- Name: acad_block_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.acad_block_id_seq OWNED BY public.acad_block.id;


--
-- Name: acad_discipline; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.acad_discipline (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    code character varying(25) NOT NULL,
    zet integer,
    hours_lec integer,
    hours_lab integer,
    hours_sem integer,
    acad_plan_id integer NOT NULL,
    acad_block_id integer NOT NULL,
    acad_part_id integer,
    acad_module_id integer,
    exams integer[],
    zachets integer[],
    semesters integer[] NOT NULL,
    is_optional boolean NOT NULL
);


ALTER TABLE public.acad_discipline OWNER TO diplom_user;

--
-- Name: COLUMN acad_discipline.zet; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.acad_discipline.zet IS 'Всего ЗЕТ';


--
-- Name: acad_discipline_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.acad_discipline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acad_discipline_id_seq OWNER TO diplom_user;

--
-- Name: acad_discipline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.acad_discipline_id_seq OWNED BY public.acad_discipline.id;


--
-- Name: acad_module; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.acad_module (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    code character varying(25) NOT NULL
);


ALTER TABLE public.acad_module OWNER TO diplom_user;

--
-- Name: acad_module_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.acad_module_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acad_module_id_seq OWNER TO diplom_user;

--
-- Name: acad_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.acad_module_id_seq OWNED BY public.acad_module.id;


--
-- Name: acad_part; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.acad_part (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    code character varying(25) NOT NULL
);


ALTER TABLE public.acad_part OWNER TO diplom_user;

--
-- Name: acad_part_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.acad_part_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acad_part_id_seq OWNER TO diplom_user;

--
-- Name: acad_part_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.acad_part_id_seq OWNED BY public.acad_part.id;


--
-- Name: acad_plan; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.acad_plan (
    id integer NOT NULL,
    modified_date timestamp without time zone,
    specialties_id integer NOT NULL
);


ALTER TABLE public.acad_plan OWNER TO diplom_user;

--
-- Name: COLUMN acad_plan.modified_date; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.acad_plan.modified_date IS 'Дата последнего изменения';


--
-- Name: acad_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.acad_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acad_plan_id_seq OWNER TO diplom_user;

--
-- Name: acad_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.acad_plan_id_seq OWNED BY public.acad_plan.id;


--
-- Name: degree; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.degree (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.degree OWNER TO diplom_user;

--
-- Name: TABLE degree; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON TABLE public.degree IS 'Степень';


--
-- Name: degree_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.degree_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.degree_id_seq OWNER TO diplom_user;

--
-- Name: degree_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.degree_id_seq OWNED BY public.degree.id;


--
-- Name: dep_load; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.dep_load (
    id integer NOT NULL,
    department_id integer NOT NULL,
    begin_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    modified_date timestamp without time zone
);


ALTER TABLE public.dep_load OWNER TO diplom_user;

--
-- Name: COLUMN dep_load.begin_date; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.dep_load.begin_date IS 'Начальный год';


--
-- Name: COLUMN dep_load.end_date; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.dep_load.end_date IS 'Конечный год';


--
-- Name: dep_load_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.dep_load_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dep_load_id_seq OWNER TO diplom_user;

--
-- Name: dep_load_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.dep_load_id_seq OWNED BY public.dep_load.id;


--
-- Name: department; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.department (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.department OWNER TO diplom_user;

--
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_id_seq OWNER TO diplom_user;

--
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.department_id_seq OWNED BY public.department.id;


--
-- Name: disciplines; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.disciplines (
    id bigint NOT NULL,
    name character varying(150) NOT NULL,
    hours_con_project real,
    hours_lec real,
    hours_sem real,
    hours_lab real,
    hours_con_exam real,
    hours_zachet real,
    hours_exam real,
    hours_kurs_project real,
    hours_gek real,
    hours_ruk_prakt real,
    hours_ruk_vkr real,
    hours_ruk_mag real,
    hours_ruk_aspirant real,
    semester_num smallint NOT NULL,
    acad_discipline_id integer,
    dep_load_id integer NOT NULL,
    is_approved boolean NOT NULL
);


ALTER TABLE public.disciplines OWNER TO diplom_user;

--
-- Name: COLUMN disciplines.hours_con_project; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_con_project IS 'Консультация проекта';


--
-- Name: COLUMN disciplines.hours_con_exam; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_con_exam IS 'Консультация экзамен';


--
-- Name: COLUMN disciplines.hours_zachet; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_zachet IS 'Зачет';


--
-- Name: COLUMN disciplines.hours_exam; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_exam IS 'Экзамен';


--
-- Name: COLUMN disciplines.hours_kurs_project; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_kurs_project IS 'Курсовой проект';


--
-- Name: COLUMN disciplines.hours_gek; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_gek IS 'ГЭК';


--
-- Name: COLUMN disciplines.hours_ruk_prakt; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_ruk_prakt IS 'Руководство практикой';


--
-- Name: COLUMN disciplines.hours_ruk_vkr; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_ruk_vkr IS 'Руководство ВКР';


--
-- Name: COLUMN disciplines.hours_ruk_mag; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_ruk_mag IS 'Руководство магистрами';


--
-- Name: COLUMN disciplines.hours_ruk_aspirant; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.hours_ruk_aspirant IS 'Руководство аспирантом';


--
-- Name: COLUMN disciplines.semester_num; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.semester_num IS 'Номер семестра (1 или 2)';


--
-- Name: COLUMN disciplines.acad_discipline_id; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.acad_discipline_id IS 'ID дисциплины из учебного плана';


--
-- Name: COLUMN disciplines.is_approved; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.disciplines.is_approved IS 'Подтверждены различия с учебным планом, либо различий нету';


--
-- Name: disciplines_groups; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.disciplines_groups (
    id integer NOT NULL,
    discipline_id bigint NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.disciplines_groups OWNER TO diplom_user;

--
-- Name: disciplines_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.disciplines_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.disciplines_groups_id_seq OWNER TO diplom_user;

--
-- Name: disciplines_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.disciplines_groups_id_seq OWNED BY public.disciplines_groups.id;


--
-- Name: disciplines_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.disciplines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.disciplines_id_seq OWNER TO diplom_user;

--
-- Name: disciplines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.disciplines_id_seq OWNED BY public.disciplines.id;


--
-- Name: disciplines_teachers; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.disciplines_teachers (
    id integer NOT NULL,
    discipline_id bigint NOT NULL,
    teacher_id integer
);


ALTER TABLE public.disciplines_teachers OWNER TO diplom_user;

--
-- Name: disciplines_teachers_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.disciplines_teachers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.disciplines_teachers_id_seq OWNER TO diplom_user;

--
-- Name: disciplines_teachers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.disciplines_teachers_id_seq OWNED BY public.disciplines_teachers.id;


--
-- Name: files_acad_plan; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.files_acad_plan (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    path text NOT NULL,
    ext character varying(10) NOT NULL,
    modified_date timestamp without time zone NOT NULL,
    teacher_id integer,
    sub_unit_id integer NOT NULL,
    acad_plan_id integer NOT NULL
);


ALTER TABLE public.files_acad_plan OWNER TO diplom_user;

--
-- Name: files_acad_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.files_acad_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_acad_plan_id_seq OWNER TO diplom_user;

--
-- Name: files_acad_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.files_acad_plan_id_seq OWNED BY public.files_acad_plan.id;


--
-- Name: files_dep_load; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.files_dep_load (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    path text NOT NULL,
    ext character varying(10) NOT NULL,
    modified_date timestamp without time zone NOT NULL,
    teacher_id integer,
    sub_unit_id integer NOT NULL,
    dep_load_id integer NOT NULL
);


ALTER TABLE public.files_dep_load OWNER TO diplom_user;

--
-- Name: files_dep_load_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.files_dep_load_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_dep_load_id_seq OWNER TO diplom_user;

--
-- Name: files_dep_load_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.files_dep_load_id_seq OWNED BY public.files_dep_load.id;


--
-- Name: files_ind_plan; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.files_ind_plan (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    path text NOT NULL,
    ext character varying(10) NOT NULL,
    modified_date timestamp without time zone NOT NULL,
    teacher_id integer,
    sub_unit_id integer NOT NULL
);


ALTER TABLE public.files_ind_plan OWNER TO diplom_user;

--
-- Name: files_ind_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.files_ind_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_ind_plan_id_seq OWNER TO diplom_user;

--
-- Name: files_ind_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.files_ind_plan_id_seq OWNED BY public.files_ind_plan.id;


--
-- Name: files_projects; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.files_projects (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    path text NOT NULL,
    ext character varying(10) NOT NULL,
    modified_date timestamp without time zone NOT NULL,
    teacher_id integer,
    sub_unit_id integer NOT NULL,
    project_id integer NOT NULL
);


ALTER TABLE public.files_projects OWNER TO diplom_user;

--
-- Name: files_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.files_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_projects_id_seq OWNER TO diplom_user;

--
-- Name: files_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.files_projects_id_seq OWNED BY public.files_projects.id;


--
-- Name: files_rpd; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.files_rpd (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    path text NOT NULL,
    ext character varying(10) NOT NULL,
    modified_date timestamp without time zone NOT NULL,
    teacher_id integer,
    sub_unit_id integer NOT NULL,
    discipline_id integer NOT NULL
);


ALTER TABLE public.files_rpd OWNER TO diplom_user;

--
-- Name: files_rpd_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.files_rpd_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_rpd_id_seq OWNER TO diplom_user;

--
-- Name: files_rpd_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.files_rpd_id_seq OWNED BY public.files_rpd.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    specialties_id integer NOT NULL,
    name character varying(20) NOT NULL
);


ALTER TABLE public.groups OWNER TO diplom_user;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_id_seq OWNER TO diplom_user;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: personalities; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.personalities (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    patronymic character varying(50),
    birthday timestamp without time zone,
    phone character varying(20),
    email character varying(40),
    status smallint NOT NULL
);


ALTER TABLE public.personalities OWNER TO diplom_user;

--
-- Name: COLUMN personalities.status; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.personalities.status IS '1 - студент, 2 - преподаватель';


--
-- Name: personalities_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.personalities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personalities_id_seq OWNER TO diplom_user;

--
-- Name: personalities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.personalities_id_seq OWNED BY public.personalities.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    name character varying(250) NOT NULL,
    description text NOT NULL,
    begin_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    link_trello text,
    sub_unit_id integer NOT NULL,
    teacher_id integer
);


ALTER TABLE public.projects OWNER TO diplom_user;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO diplom_user;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: ranks; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.ranks (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.ranks OWNER TO diplom_user;

--
-- Name: TABLE ranks; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON TABLE public.ranks IS 'Звание';


--
-- Name: ranks_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.ranks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ranks_id_seq OWNER TO diplom_user;

--
-- Name: ranks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.ranks_id_seq OWNED BY public.ranks.id;


--
-- Name: rights_roles; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.rights_roles (
    id integer NOT NULL,
    role smallint NOT NULL,
    teacher_id integer NOT NULL,
    sub_unit_id integer NOT NULL
);


ALTER TABLE public.rights_roles OWNER TO diplom_user;

--
-- Name: TABLE rights_roles; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON TABLE public.rights_roles IS 'Права выданные определенным преподавателям к определенным подразделениям';


--
-- Name: COLUMN rights_roles.role; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.rights_roles.role IS '1 - пользователь, 2 - преподаватель, 3 - РОП, 4 - админ';


--
-- Name: rights_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.rights_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rights_roles_id_seq OWNER TO diplom_user;

--
-- Name: rights_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.rights_roles_id_seq OWNED BY public.rights_roles.id;


--
-- Name: specialties; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.specialties (
    id integer NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    profile character varying(100) NOT NULL,
    educ_form character varying(20) NOT NULL,
    educ_programm smallint NOT NULL,
    educ_years integer NOT NULL,
    year_join timestamp without time zone NOT NULL,
    sub_unit_id integer
);


ALTER TABLE public.specialties OWNER TO diplom_user;

--
-- Name: COLUMN specialties.profile; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.specialties.profile IS 'Профиль';


--
-- Name: COLUMN specialties.educ_form; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.specialties.educ_form IS 'очная, очно-заочная и тд';


--
-- Name: COLUMN specialties.educ_programm; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.specialties.educ_programm IS '1 - бакалавр, 2 - магистр';


--
-- Name: COLUMN specialties.educ_years; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.specialties.educ_years IS 'Срок обучения';


--
-- Name: COLUMN specialties.year_join; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.specialties.year_join IS 'Год набора';


--
-- Name: specialties_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.specialties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.specialties_id_seq OWNER TO diplom_user;

--
-- Name: specialties_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.specialties_id_seq OWNED BY public.specialties.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.students (
    id integer NOT NULL,
    person_id integer NOT NULL,
    group_id integer
);


ALTER TABLE public.students OWNER TO diplom_user;

--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_id_seq OWNER TO diplom_user;

--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: students_projects; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.students_projects (
    id integer NOT NULL,
    student_id integer NOT NULL,
    project_id integer NOT NULL,
    date date NOT NULL
);


ALTER TABLE public.students_projects OWNER TO diplom_user;

--
-- Name: students_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.students_projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_projects_id_seq OWNER TO diplom_user;

--
-- Name: students_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.students_projects_id_seq OWNED BY public.students_projects.id;


--
-- Name: sub_unit; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.sub_unit (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    department_id integer NOT NULL
);


ALTER TABLE public.sub_unit OWNER TO diplom_user;

--
-- Name: TABLE sub_unit; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON TABLE public.sub_unit IS 'Подразделения ( условные САПР, ВЕБ и т.д. ), проекты ПД делятся согласно этим подразделениям.';


--
-- Name: sub_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.sub_unit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sub_unit_id_seq OWNER TO diplom_user;

--
-- Name: sub_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.sub_unit_id_seq OWNED BY public.sub_unit.id;


--
-- Name: teachers; Type: TABLE; Schema: public; Owner: diplom_user
--

CREATE TABLE public.teachers (
    id integer NOT NULL,
    person_id integer NOT NULL,
    "position" character varying(100) NOT NULL,
    rank_id integer,
    degree_id integer,
    rate real,
    hours_worked integer,
    rinc real,
    web_of_science real,
    scopus real,
    login character varying(25) NOT NULL,
    password character varying(200) NOT NULL,
    salt character varying(200) NOT NULL
);


ALTER TABLE public.teachers OWNER TO diplom_user;

--
-- Name: COLUMN teachers.rate; Type: COMMENT; Schema: public; Owner: diplom_user
--

COMMENT ON COLUMN public.teachers.rate IS 'ставка';


--
-- Name: teachers_id_seq; Type: SEQUENCE; Schema: public; Owner: diplom_user
--

CREATE SEQUENCE public.teachers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teachers_id_seq OWNER TO diplom_user;

--
-- Name: teachers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diplom_user
--

ALTER SEQUENCE public.teachers_id_seq OWNED BY public.teachers.id;


--
-- Name: acad_block id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_block ALTER COLUMN id SET DEFAULT nextval('public.acad_block_id_seq'::regclass);


--
-- Name: acad_discipline id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_discipline ALTER COLUMN id SET DEFAULT nextval('public.acad_discipline_id_seq'::regclass);


--
-- Name: acad_module id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_module ALTER COLUMN id SET DEFAULT nextval('public.acad_module_id_seq'::regclass);


--
-- Name: acad_part id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_part ALTER COLUMN id SET DEFAULT nextval('public.acad_part_id_seq'::regclass);


--
-- Name: acad_plan id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_plan ALTER COLUMN id SET DEFAULT nextval('public.acad_plan_id_seq'::regclass);


--
-- Name: degree id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.degree ALTER COLUMN id SET DEFAULT nextval('public.degree_id_seq'::regclass);


--
-- Name: dep_load id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.dep_load ALTER COLUMN id SET DEFAULT nextval('public.dep_load_id_seq'::regclass);


--
-- Name: department id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.department ALTER COLUMN id SET DEFAULT nextval('public.department_id_seq'::regclass);


--
-- Name: disciplines id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines ALTER COLUMN id SET DEFAULT nextval('public.disciplines_id_seq'::regclass);


--
-- Name: disciplines_groups id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_groups ALTER COLUMN id SET DEFAULT nextval('public.disciplines_groups_id_seq'::regclass);


--
-- Name: disciplines_teachers id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_teachers ALTER COLUMN id SET DEFAULT nextval('public.disciplines_teachers_id_seq'::regclass);


--
-- Name: files_acad_plan id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan ALTER COLUMN id SET DEFAULT nextval('public.files_acad_plan_id_seq'::regclass);


--
-- Name: files_dep_load id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load ALTER COLUMN id SET DEFAULT nextval('public.files_dep_load_id_seq'::regclass);


--
-- Name: files_ind_plan id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_ind_plan ALTER COLUMN id SET DEFAULT nextval('public.files_ind_plan_id_seq'::regclass);


--
-- Name: files_projects id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects ALTER COLUMN id SET DEFAULT nextval('public.files_projects_id_seq'::regclass);


--
-- Name: files_rpd id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_rpd ALTER COLUMN id SET DEFAULT nextval('public.files_rpd_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: personalities id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.personalities ALTER COLUMN id SET DEFAULT nextval('public.personalities_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: ranks id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.ranks ALTER COLUMN id SET DEFAULT nextval('public.ranks_id_seq'::regclass);


--
-- Name: rights_roles id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.rights_roles ALTER COLUMN id SET DEFAULT nextval('public.rights_roles_id_seq'::regclass);


--
-- Name: specialties id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.specialties ALTER COLUMN id SET DEFAULT nextval('public.specialties_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: students_projects id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students_projects ALTER COLUMN id SET DEFAULT nextval('public.students_projects_id_seq'::regclass);


--
-- Name: sub_unit id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.sub_unit ALTER COLUMN id SET DEFAULT nextval('public.sub_unit_id_seq'::regclass);


--
-- Name: teachers id; Type: DEFAULT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.teachers ALTER COLUMN id SET DEFAULT nextval('public.teachers_id_seq'::regclass);


--
-- Data for Name: acad_block; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.acad_block (id, name, code) FROM stdin;
1	БЛОК 1. Дисциплины (модули)	Б.1
2	БЛОК 2. Практика	Б.2
3	БЛОК 3. Государственная итоговая аттестация	Б.3
100	БЛОК 1. Дисциплины (модули)	A
103	БЛОК 1. Дисциплины (модули)	А
\.


--
-- Data for Name: acad_discipline; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.acad_discipline (id, name, code, zet, hours_lec, hours_lab, hours_sem, acad_plan_id, acad_block_id, acad_part_id, acad_module_id, exams, zachets, semesters, is_optional) FROM stdin;
100	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	100	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
101	Математический анализ	A.1.1.2	4	36	\N	36	100	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
102	Дискретная математика	A.1.1.3	4	36	\N	36	100	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
103	Иностранный язык	А.1.2.1	12	\N	\N	204	100	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
104	Технический перевод	А.1.2.2	6	\N	\N	106	100	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
105	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	100	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
106	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	100	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
107	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	100	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
108	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	100	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
109	Философия	А.1.4.1	2	\N	\N	36	100	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
110	История России	А.1.4.2	1	\N	\N	\N	100	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
111	Всеобщая история	А.1.4.3	1	\N	\N	\N	100	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
112	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	100	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
113	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	100	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
114	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	100	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
115	Проектная деятельность	А.1.5.2	10	\N	10	\N	100	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
116	Проектный менеджмент	А.1.5.3	4	34	34	\N	100	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
117	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	100	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
118	Инженерное проектирование	А.1.6.1	5	\N	10	\N	100	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
119	Основы ИКТ	А.1.7.1	4	\N	72	\N	100	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
120	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	100	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
121	Базы данных	А.1.8.1	3	18	36	\N	100	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
122	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	100	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
123	Мобильная разработка	А.1.8.3	4	\N	72	\N	100	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
124	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	100	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
125	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	100	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
126	Теория вероятностей	А.2.1.2	4	36	\N	36	100	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
127	Основы программирования	А.2.2.1	4	\N	72	\N	100	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
128	Веб-разработка	А.2.2.2	2	\N	36	\N	100	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
129	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	100	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
130	Защита информации	А.2.2.4	4	\N	72	\N	100	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
131	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	100	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
132	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	100	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
133	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	100	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
134	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	100	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
135	Разработка ТЭО	А.2.3.5	4	36	36	\N	100	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
136	Инженерная графика	А.2.3.1	4	18	36	\N	100	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
137	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	100	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
138	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	100	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
139	Основы измерения деталей	А.2.3.4	2	\N	36	\N	100	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
140	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	100	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
141	Конструкторская документация	А.2.3.6	2	\N	36	\N	100	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
142	Электротехника и электроника	А.2.3.7	4	36	\N	36	100	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
143	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	100	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
144	Физика	А.2.3.9	8	72	36	36	100	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
145	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	100	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
146	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	100	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
147	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	100	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
148	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	100	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
149	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	100	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
150	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	100	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
151	Программирование в САПР	А.2.6.1	6	\N	108	\N	100	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
152	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	100	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
153	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	100	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
154	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	100	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
155	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	100	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
156	Организация производства в САПР	А.2.7.1	2	\N	36	\N	100	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
157	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	100	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
158	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	100	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
985	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	117	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
986	Математический анализ	A.1.1.2	4	36	\N	36	117	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
987	Дискретная математика	A.1.1.3	4	36	\N	36	117	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
988	Иностранный язык	А.1.2.1	12	\N	\N	204	117	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
989	Технический перевод	А.1.2.2	6	\N	\N	106	117	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
990	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	117	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
991	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	117	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
992	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	117	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
993	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	117	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
994	Философия	А.1.4.1	2	\N	\N	36	117	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
995	История России	А.1.4.2	1	\N	\N	\N	117	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
996	Всеобщая история	А.1.4.3	1	\N	\N	\N	117	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
997	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	117	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
998	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	117	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
999	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	117	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
1000	Проектная деятельность	А.1.5.2	10	\N	10	\N	117	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
1001	Проектный менеджмент	А.1.5.3	4	34	34	\N	117	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
1002	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	117	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
1003	Инженерное проектирование	А.1.6.1	5	\N	10	\N	117	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
1004	Основы ИКТ	А.1.7.1	4	\N	72	\N	117	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
1005	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	117	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
1006	Базы данных	А.1.8.1	3	18	36	\N	117	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
1007	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	117	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1008	Мобильная разработка	А.1.8.3	4	\N	72	\N	117	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1009	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	117	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
1010	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	117	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
1011	Теория вероятностей	А.2.1.2	4	36	\N	36	117	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
1012	Основы программирования	А.2.2.1	4	\N	72	\N	117	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
1013	Веб-разработка	А.2.2.2	2	\N	36	\N	117	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1014	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	117	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
1015	Защита информации	А.2.2.4	4	\N	72	\N	117	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
1016	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	117	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
1017	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	117	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1018	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	117	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
1019	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	117	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
1020	Разработка ТЭО	А.2.3.5	4	36	36	\N	117	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1021	Инженерная графика	А.2.3.1	4	18	36	\N	117	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
1022	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	117	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
1023	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	117	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
1024	Основы измерения деталей	А.2.3.4	2	\N	36	\N	117	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
1025	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	117	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
1026	Конструкторская документация	А.2.3.6	2	\N	36	\N	117	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1027	Электротехника и электроника	А.2.3.7	4	36	\N	36	117	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
1028	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	117	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1029	Физика	А.2.3.9	8	72	36	36	117	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
1030	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	117	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
1031	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	117	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
1032	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	117	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
1033	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	117	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1034	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	117	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
1035	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	117	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1036	Программирование в САПР	А.2.6.1	6	\N	108	\N	117	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
1037	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	117	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1038	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	117	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
1039	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	117	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
1040	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	117	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
1041	Организация производства в САПР	А.2.7.1	2	\N	36	\N	117	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
1042	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	117	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1043	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	117	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1044	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	118	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
1045	Математический анализ	A.1.1.2	4	36	\N	36	118	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
1046	Дискретная математика	A.1.1.3	4	36	\N	36	118	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
1047	Иностранный язык	А.1.2.1	12	\N	\N	204	118	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
1048	Технический перевод	А.1.2.2	6	\N	\N	106	118	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
1049	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	118	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
1050	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	118	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
1051	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	118	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
1052	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	118	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1053	Философия	А.1.4.1	2	\N	\N	36	118	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
1054	История России	А.1.4.2	1	\N	\N	\N	118	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
1055	Всеобщая история	А.1.4.3	1	\N	\N	\N	118	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
1056	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	118	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
1057	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	118	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
1058	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	118	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
1059	Проектная деятельность	А.1.5.2	10	\N	10	\N	118	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
1060	Проектный менеджмент	А.1.5.3	4	34	34	\N	118	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
1061	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	118	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
1062	Инженерное проектирование	А.1.6.1	5	\N	10	\N	118	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
1063	Основы ИКТ	А.1.7.1	4	\N	72	\N	118	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
1064	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	118	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
1065	Базы данных	А.1.8.1	3	18	36	\N	118	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
1066	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	118	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1067	Мобильная разработка	А.1.8.3	4	\N	72	\N	118	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1068	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	118	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
1069	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	118	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
1070	Теория вероятностей	А.2.1.2	4	36	\N	36	118	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
1071	Основы программирования	А.2.2.1	4	\N	72	\N	118	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
1072	Веб-разработка	А.2.2.2	2	\N	36	\N	118	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1073	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	118	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
1074	Защита информации	А.2.2.4	4	\N	72	\N	118	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
1075	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	118	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
1076	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	118	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1077	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	118	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
1078	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	118	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
1079	Разработка ТЭО	А.2.3.5	4	36	36	\N	118	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1080	Инженерная графика	А.2.3.1	4	18	36	\N	118	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
1081	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	118	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
1082	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	118	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
1083	Основы измерения деталей	А.2.3.4	2	\N	36	\N	118	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
1084	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	118	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
1085	Конструкторская документация	А.2.3.6	2	\N	36	\N	118	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1086	Электротехника и электроника	А.2.3.7	4	36	\N	36	118	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
1087	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	118	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1088	Физика	А.2.3.9	8	72	36	36	118	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
1089	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	118	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
1090	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	118	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
1091	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	118	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
1092	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	118	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1093	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	118	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
1094	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	118	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
1095	Программирование в САПР	А.2.6.1	6	\N	108	\N	118	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
1096	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	118	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
1097	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	118	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
1098	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	118	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
1099	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	118	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
1100	Организация производства в САПР	А.2.7.1	2	\N	36	\N	118	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
1101	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	118	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
1102	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	118	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
\.


--
-- Data for Name: acad_module; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.acad_module (id, name, code) FROM stdin;
1	Модуль "Инностранный язык"	Б.1.1.1
2	Модуль "Русский язык и культура речи"	Б.1.1.2
3	Модуль "Навыки эффективной презентации"	Б.1.1.3
4	Модуль "Безопасность жизнедеятельности"	Б.1.1.4
100	Модуль "Обязательная математическая подготовка"	A.1.1
103	Модуль "Иностранный язык"	А.1.2
105	Модуль "Коммуникация в ИТ"	А.1.3
109	Модуль "Общая подготовка"	А.1.4
114	Модуль "Проектная деятельность в ИТ-индустрии"	А.1.5
118	Модуль "Инженерное проектирование в ИТ"	А.1.6
119	Модуль "Эксплуатация средств ВТ"	А.1.7
121	Модуль "Основы ИТ"	А.1.8
124	Модуль "Основы ИТ"	А.1.9
125	Модуль "Профильная математическая подготовка"	А.2.1
127	Модуль "Основы ИТ"	А.2.2
131	Модуль "Проектирование ПО и ИС"	А.2.3
136	Модуль "Базовая машиностроительная подготовка"	А.2.3
145	Модуль "Бизнес-компетенции"	А.2.4
147	Модуль "Трехмерное  моделирование в САПР"	А.2.5
151	Модуль "Программирование и разработка приложений  САПР"	А.2.6
155	Модуль "Элективные дисциплины"	А.2.7
\.


--
-- Data for Name: acad_part; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.acad_part (id, name, code) FROM stdin;
1	Базовая часть	Б.1.1
2	Вариативная часть	Б.1.2
3	Дисциплины по выбору студента	Б.1.ДВ
100	Обязательная часть	A.1
103	Обязательная часть	А.1
125	Часть, формируемая участниками образовательных отношений	А.2
\.


--
-- Data for Name: acad_plan; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.acad_plan (id, modified_date, specialties_id) FROM stdin;
100	2020-06-14 00:32:19	100
117	2020-06-14 11:44:38	116
118	2020-06-14 13:01:33	119
\.


--
-- Data for Name: degree; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.degree (id, name) FROM stdin;
1	Кандидат наук
2	Доктор наук
\.


--
-- Data for Name: dep_load; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.dep_load (id, department_id, begin_date, end_date, modified_date) FROM stdin;
103	100	2020-09-01 00:00:00	2020-12-31 00:00:00	2020-06-14 00:43:01
104	101	2021-01-03 00:00:00	2022-01-03 00:00:00	2020-06-14 00:47:56
105	102	2020-09-01 00:00:00	2020-12-31 00:00:00	2020-06-14 11:46:03
106	103	2017-05-25 00:00:00	2017-05-31 00:00:00	2020-06-14 13:01:18
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.department (id, name) FROM stdin;
1	Информатика и вычислительная техника
2	Проектная деятельность
100	Веб-технологии
101	Информационная безопастность
102	Машиностроение
103	Новая кафедра
\.


--
-- Data for Name: disciplines; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.disciplines (id, name, hours_con_project, hours_lec, hours_sem, hours_lab, hours_con_exam, hours_zachet, hours_exam, hours_kurs_project, hours_gek, hours_ruk_prakt, hours_ruk_vkr, hours_ruk_mag, hours_ruk_aspirant, semester_num, acad_discipline_id, dep_load_id, is_approved) FROM stdin;
103	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	103	f
104	Информационная безопасность	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
105	Мобильная интеграция	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
106	Основы права в Веб	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	103	f
107	Поисковая оптимизация	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
108	Программирование в системах информационной безопасности	\N	\N	\N	136	1	\N	5.4000001	\N	\N	\N	\N	\N	\N	1	\N	103	f
109	Проектирование Веб-сервисов	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
110	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	103	f
111	Статистические методы веб-аналитики	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
112	Веб-аналитика	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
113	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	103	f
114	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
115	Проектирование информационных систем	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	103	f
116	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	103	f
117	Разработка в КИС	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
118	Реклама в Веб и Социальных медиа	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
119	Трехмерные модели в веб-приложениях	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	103	f
120	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	104	f
121	Информационная безопасность	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
122	Мобильная интеграция	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
123	Основы права в Веб	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	104	f
124	Поисковая оптимизация	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
125	Программирование в системах информационной безопасности	\N	\N	\N	136	1	\N	5.4000001	\N	\N	\N	\N	\N	\N	1	\N	104	f
126	Проектирование Веб-сервисов	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
127	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	104	f
128	Статистические методы веб-аналитики	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
129	Веб-аналитика	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
130	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	104	f
131	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
132	Проектирование информационных систем	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	104	f
133	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	104	f
134	Разработка в КИС	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
135	Реклама в Веб и Социальных медиа	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
136	Трехмерные модели в веб-приложениях	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	104	f
137	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	105	f
138	Информационная безопасность	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
139	Мобильная интеграция	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
140	Основы права в Веб	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	105	f
141	Поисковая оптимизация	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
142	Программирование в системах информационной безопасности	\N	\N	\N	136	1	\N	5.4000001	\N	\N	\N	\N	\N	\N	1	\N	105	f
143	Проектирование Веб-сервисов	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
144	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	105	f
145	Статистические методы веб-аналитики	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
146	Веб-аналитика	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
147	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	105	f
148	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
149	Проектирование информационных систем	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	105	f
150	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	105	f
151	Разработка в КИС	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
152	Реклама в Веб и Социальных медиа	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
153	Трехмерные модели в веб-приложениях	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	105	f
154	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	106	f
155	Информационная безопасность	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
156	Мобильная интеграция	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
157	Основы права в Веб	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	106	f
158	Поисковая оптимизация	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
159	Программирование в системах информационной безопасности	\N	\N	\N	136	1	\N	5.4000001	\N	\N	\N	\N	\N	\N	1	\N	106	f
160	Проектирование Веб-сервисов	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
161	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	106	f
162	Статистические методы веб-аналитики	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
163	Веб-аналитика	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
164	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	106	f
165	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
166	Проектирование информационных систем	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	106	f
167	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	106	f
168	Разработка в КИС	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
169	Реклама в Веб и Социальных медиа	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
170	Трехмерные модели в веб-приложениях	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	106	f
\.


--
-- Data for Name: disciplines_groups; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.disciplines_groups (id, discipline_id, group_id) FROM stdin;
103	103	100
104	103	101
105	104	100
106	104	101
107	105	100
108	105	101
109	106	100
110	106	101
111	107	100
112	107	101
113	108	102
114	109	100
115	109	101
116	110	100
117	110	101
118	111	100
119	111	101
120	112	100
121	112	101
122	113	100
123	113	101
124	114	100
125	114	101
126	115	100
127	115	101
128	116	100
129	116	101
130	117	100
131	117	101
132	118	100
133	118	101
134	119	100
135	119	101
136	120	100
137	120	101
138	121	100
139	121	101
140	122	100
141	122	101
142	123	100
143	123	101
144	124	100
145	124	101
146	125	102
147	126	100
148	126	101
149	127	100
150	127	101
151	128	100
152	128	101
153	129	100
154	129	101
155	130	100
156	130	101
157	131	100
158	131	101
159	132	100
160	132	101
161	133	100
162	133	101
163	134	100
164	134	101
165	135	100
166	135	101
167	136	100
168	136	101
169	137	100
170	137	101
171	138	100
172	138	101
173	139	100
174	139	101
175	140	100
176	140	101
177	141	100
178	141	101
179	142	102
180	143	100
181	143	101
182	144	100
183	144	101
184	145	100
185	145	101
186	146	100
187	146	101
188	147	100
189	147	101
190	148	100
191	148	101
192	149	100
193	149	101
194	150	100
195	150	101
196	151	100
197	151	101
198	152	100
199	152	101
200	153	100
201	153	101
202	154	100
203	154	101
204	155	100
205	155	101
206	156	100
207	156	101
208	157	100
209	157	101
210	158	100
211	158	101
212	159	102
213	160	100
214	160	101
215	161	100
216	161	101
217	162	100
218	162	101
219	163	100
220	163	101
221	164	100
222	164	101
223	165	100
224	165	101
225	166	100
226	166	101
227	167	100
228	167	101
229	168	100
230	168	101
231	169	100
232	169	101
233	170	100
234	170	101
\.


--
-- Data for Name: disciplines_teachers; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.disciplines_teachers (id, discipline_id, teacher_id) FROM stdin;
100	112	1
\.


--
-- Data for Name: files_acad_plan; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_acad_plan (id, name, path, ext, modified_date, teacher_id, sub_unit_id, acad_plan_id) FROM stdin;
100	AUP_-_FGOS_3__-_09_03_01_-_SAPR.xlsx	/uploads/upload_40cb340594a3a170be4a089fe28ec83b	.xlsx	2020-07-14 00:48:13.121	1	1	100
101	AUP_-_FGOS_3__-_09_03_01_-_SAPR.xlsx	/uploads/upload_929183ee88229a5b4da49a7ab48f846e	.xlsx	2020-07-14 11:41:48.466	1	1	117
102	AUP_-_FGOS_3__-_09_03_01_-_SAPR.xlsx	/uploads/upload_d47665cc35ead6cd2a0d3282531be804	.xlsx	2020-07-14 12:58:44.742	1	1	118
\.


--
-- Data for Name: files_dep_load; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_dep_load (id, name, path, ext, modified_date, teacher_id, sub_unit_id, dep_load_id) FROM stdin;
100	тестовая нагрузка.xls	/uploads/upload_ffd27963cb25d9f053199137d1dd5d65	.xls	2020-07-14 00:47:01.323	1	1	104
101	тестовая нагрузка.xls	/uploads/upload_8c566cec2b482b0f3005655f3073825c	.xls	2020-07-14 00:47:14.792	1	1	103
102	тестовая нагрузка.xls	/uploads/upload_b60ef0cd6299986047c5cd4ceb13baa5	.xls	2020-07-14 11:43:13.464	1	1	105
103	тестовая нагрузка.xls	/uploads/upload_909041bdf8d700636343fe7e5775bafc	.xls	2020-07-14 12:58:28.35	1	1	106
\.


--
-- Data for Name: files_ind_plan; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_ind_plan (id, name, path, ext, modified_date, teacher_id, sub_unit_id) FROM stdin;
100	тестовая нагрузка.xls	/uploads/upload_2a038314275639c1799dccde4de348d2	.xls	2020-07-14 02:08:37.073	1	1
102	Индивидуальный план.rar	/uploads/upload_300d1efce04598963e39bdea63fd626c	.rar	2020-07-14 12:17:46.905	1	1
103	Индивидуальный план.rar	/uploads/upload_56175027e0163a7ffb7f7b00d1fbfa1d	.rar	2020-07-14 12:23:01.119	1	1
104	Индивидуальный план.rar	/uploads/upload_d81595d05c7e6d1a956ee7b4878ffc76	.rar	2020-07-14 12:25:34.66	1	1
105	test.txt	/uploads/upload_6e662f9a0feedd0408b99175eddecc6f	.txt	2020-07-14 12:27:36.311	1	1
106	Индивидуальный план.rar	/uploads/upload_b02f582b32f9dfb8a4bd7a2c782cc4a5	.rar	2020-07-14 12:32:00.186	1	1
107	test.txt	/uploads/upload_90327af9baf1e2fd7e0a32c51c362660	.txt	2020-07-14 12:47:17.875	1	1
108	Индивидуальный план.rar	/uploads/upload_9a2294654aa299134f53b5119b0a29c8	.rar	2020-07-14 12:54:59.844	1	1
\.


--
-- Data for Name: files_projects; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_projects (id, name, path, ext, modified_date, teacher_id, sub_unit_id, project_id) FROM stdin;
100	Ссылка.txt	/uploads/upload_053bb2f5ab68ee4d7c25b49fb67b849e	.txt	2020-07-14 02:07:52.953	1	1	100
101	тест.xlsx	/uploads/upload_9c0a00fa9093ee2fa48f30463c82d060	.xlsx	2020-07-14 02:08:09.14	1	1	101
102	Индивидуальный план.rar	/uploads/upload_4163a65b963d8b0012c664ae7c0b14ad	.rar	2020-07-14 12:56:19.529	1	1	102
\.


--
-- Data for Name: files_rpd; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_rpd (id, name, path, ext, modified_date, teacher_id, sub_unit_id, discipline_id) FROM stdin;
100	тест.xlsx	/uploads/upload_062c5363ef9eaeed2a4295453fbd68fa	.xlsx	2020-07-14 02:09:28.46	1	1	112
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.groups (id, specialties_id, name) FROM stdin;
1	2	161-342
100	100	171-331
101	100	171-332
102	100	171-361
\.


--
-- Data for Name: personalities; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.personalities (id, name, surname, patronymic, birthday, phone, email, status) FROM stdin;
1	Игорь	Степаненко	Сергеевич	1998-06-03 00:00:00	8(800)555-3535	stepanenko@mail.ru	1
2	Александр	Буравов	Николаевич	1998-10-25 00:00:00	8(800)555-3535	buravov@mail.ru	1
3	Алексей	Тремаскин	Владимирович	1998-12-10 00:00:00	8(800)555-3535	tremaskin@mail.ru	1
4	Павел	Бабушкин	Михайлович	1996-11-30 00:00:00	8(800)555-3535	babushkin@mail.ru	1
5	Алина	Борзикова	Александровна	1998-03-05 00:00:00	8(800)555-3535	borzikova@mail.ru	1
53	Дмитрий	Холодов	Алексеевич	\N	8(800)555-3535	holodov@mail.ru	2
55	Анастасия	Ковалева	Александровна	\N	8(800)555-3535	kovaleva@mail.ru	2
100	Иван	Иванов	Иванович	1998-06-03 00:00:00	+89996578833	te@yandex.ru	1
101	Дмитрий	Лысенко	Иванович	1998-09-03 00:00:00	+78238765432	ty@yandex.ru	1
102	Евгений	Сирков	Дмитриевич	1997-12-03 00:00:00	98887776655	ui@yandex.ru	1
103	Иван	Иванов	Иванович	2020-04-09 00:00:00	8(000)000-00-00	maiddddddl@mail.ru	2
106	Николай	Николаев	Николаевич	2020-04-09 00:00:00	8(000)000-00-00	nikolaev@mail.ru	2
56	Андрей	Джунковский	Владимирович	\N	8(800)555-3535	djunkovski@mail.ru	2
57	Виктор	Лянг	Федорович	\N	8(800)555-3535	lyang@mail.ru	2
54	Антон	Толстиков	Витальевич	\N	8(800)555-3535	tolstikov@mail.ru	2
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.projects (id, name, description, begin_date, end_date, link_trello, sub_unit_id, teacher_id) FROM stdin;
100	Создание лодки	Спроектировать лодку	2020-05-02 00:00:00	2020-05-30 00:00:00	trello.com/887663	1	1
101	Создание весов	Смоделировать весы	2021-02-03 00:00:00	2021-04-01 00:00:00	trello.com/9988766	1	2
102	Новый проект	Описание нового проекта	2020-05-04 00:00:00	2020-05-25 00:00:00	trello.com/87722	1	3
1	Луноход	Спроектировать луноход	2016-08-29 00:00:00	2016-08-29 00:00:00	trello.com/87722	1	1
2	База данных цифровых моделей	Сформировать базу данных	2016-08-30 00:00:00	2016-08-30 00:00:00	trello.com/997762	1	2
\.


--
-- Data for Name: ranks; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.ranks (id, name) FROM stdin;
1	Аспирант
2	Ассистент
3	Ведущий научный сотрудник
4	Главный научный сотрудник
5	Докторант
6	Доцент
7	Младший научный сотрудник
\.


--
-- Data for Name: rights_roles; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.rights_roles (id, role, teacher_id, sub_unit_id) FROM stdin;
2	4	1	1
4	3	2	1
5	2	3	1
6	2	4	1
7	1	5	1
100	3	100	2
101	3	102	3
\.


--
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.specialties (id, code, name, profile, educ_form, educ_programm, educ_years, year_join, sub_unit_id) FROM stdin;
2	09.03.01	Информатика и вычислительная техника	Интеграция и программирование в САПР	Очная	1	4	2016-09-01 00:00:00	1
100	09.02.03	Веб-технологии	Разбработка веб-сайтов	Очная	1	4	2020-09-01 00:00:00	2
116	10.03.01	Информационная безопастность	Безопастность веб-приложений	Очная	1	4	2017-05-23 00:00:00	2
118	new	new specialty	new	new	1	4	2020-04-08 00:00:00	3
119	01.22.04	Новая специальность	Новый профиль	Очная	1	4	2017-05-31 00:00:00	1
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.students (id, person_id, group_id) FROM stdin;
1	1	1
2	2	1
3	3	1
4	4	1
5	5	1
100	100	100
101	101	101
102	102	102
\.


--
-- Data for Name: students_projects; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.students_projects (id, student_id, project_id, date) FROM stdin;
1	1	1	2016-09-01
2	2	2	2016-09-01
100	1	100	2020-07-14
101	5	101	2020-07-14
102	102	2	2020-07-14
103	101	102	2020-07-14
104	5	102	2020-07-14
105	102	1	2020-07-15
\.


--
-- Data for Name: sub_unit; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.sub_unit (id, name, department_id) FROM stdin;
1	САПР	1
2	ВЕБ	1
3	КИС	1
4	ИБ	2
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.teachers (id, person_id, "position", rank_id, degree_id, rate, hours_worked, rinc, web_of_science, scopus, login, password, salt) FROM stdin;
1	53	Преподаватель	\N	\N	\N	\N	\N	\N	\N	holodov	$2b$12$WJPfMpLjWz/fRtn21qiy4eyuprgS2YCNSmlUmwOdjZHUjVq33Q7Hi	$2b$12$WJPfMpLjWz/fRtn21qiy4e
3	55	Преподаватель	\N	\N	\N	\N	\N	\N	\N	kovaleva	$2b$12$IH8kIKTXrM3UXyDs1JyFOe3.oBjDWnAo2zMVO2Q0MLR8hINLEH7wm	$2b$12$IH8kIKTXrM3UXyDs1JyFOe
100	103	Преподаватель	\N	\N	0.25	300	0.100000001	0.100000001	0.100000001	ivanov	$2b$12$VKunaopvr6xP8eN7vZm/p.DV5GFCZ7zmrcoNX75CjsdOs8X79lffW	$2b$12$VKunaopvr6xP8eN7vZm/p.
102	106	Преподаватель	\N	\N	0.25	300	0.100000001	0.100000001	0.100000001	nikolaev	$2b$12$E64WXaxTCG9m0k6u.dqTDeFJUymgAN3NhlA6xBBl7yENhl8irgbdW	$2b$12$E64WXaxTCG9m0k6u.dqTDe
4	56	Преподаватель	\N	\N	\N	\N	\N	\N	\N	djunkovski	$2b$12$Qh.8rPRjF.eYOiGPo6F.ReKE32vdJmHdvifhQTvxzKTv.8ycU73IC	$2b$12$Qh.8rPRjF.eYOiGPo6F.Re
5	57	Преподаватель	\N	\N	\N	\N	\N	\N	\N	lyang	$2b$12$S6ARaLllzdaHhpMPLTvn8uU9ycBlW92zxuO.R1ImCULrMoWkqyn0u	$2b$12$S6ARaLllzdaHhpMPLTvn8u
2	54	Преподаватель	\N	\N	\N	\N	\N	\N	\N	tolstikov	$2b$12$H2FY2xgNEANnRv69.gXSruq35I50F6wm5OslvDN0uFk.ky09wJ/MW	$2b$12$H2FY2xgNEANnRv69.gXSru
\.


--
-- Name: acad_block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_block_id_seq', 1102, true);


--
-- Name: acad_discipline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_discipline_id_seq', 1102, true);


--
-- Name: acad_module_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_module_id_seq', 1102, true);


--
-- Name: acad_part_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_part_id_seq', 1102, true);


--
-- Name: acad_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_plan_id_seq', 118, true);


--
-- Name: degree_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.degree_id_seq', 100, false);


--
-- Name: dep_load_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.dep_load_id_seq', 106, true);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.department_id_seq', 103, true);


--
-- Name: disciplines_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.disciplines_groups_id_seq', 234, true);


--
-- Name: disciplines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.disciplines_id_seq', 170, true);


--
-- Name: disciplines_teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.disciplines_teachers_id_seq', 100, true);


--
-- Name: files_acad_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_acad_plan_id_seq', 102, true);


--
-- Name: files_dep_load_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_dep_load_id_seq', 103, true);


--
-- Name: files_ind_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_ind_plan_id_seq', 108, true);


--
-- Name: files_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_projects_id_seq', 102, true);


--
-- Name: files_rpd_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_rpd_id_seq', 100, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.groups_id_seq', 104, true);


--
-- Name: personalities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.personalities_id_seq', 106, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.projects_id_seq', 102, true);


--
-- Name: ranks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.ranks_id_seq', 100, false);


--
-- Name: rights_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.rights_roles_id_seq', 101, true);


--
-- Name: specialties_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.specialties_id_seq', 119, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.students_id_seq', 102, true);


--
-- Name: students_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.students_projects_id_seq', 105, true);


--
-- Name: sub_unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.sub_unit_id_seq', 100, false);


--
-- Name: teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.teachers_id_seq', 102, true);


--
-- Name: acad_block acad_block_name_code_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_block
    ADD CONSTRAINT acad_block_name_code_key UNIQUE (name, code);


--
-- Name: acad_block acad_block_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_block
    ADD CONSTRAINT acad_block_pkey PRIMARY KEY (id);


--
-- Name: acad_discipline acad_discipline_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_discipline
    ADD CONSTRAINT acad_discipline_pkey PRIMARY KEY (id);


--
-- Name: acad_module acad_module_name_code_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_module
    ADD CONSTRAINT acad_module_name_code_key UNIQUE (name, code);


--
-- Name: acad_module acad_module_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_module
    ADD CONSTRAINT acad_module_pkey PRIMARY KEY (id);


--
-- Name: acad_part acad_part_name_code_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_part
    ADD CONSTRAINT acad_part_name_code_key UNIQUE (name, code);


--
-- Name: acad_part acad_part_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_part
    ADD CONSTRAINT acad_part_pkey PRIMARY KEY (id);


--
-- Name: acad_plan acad_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_plan
    ADD CONSTRAINT acad_plan_pkey PRIMARY KEY (id);


--
-- Name: acad_plan acad_plan_specialties_id_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_plan
    ADD CONSTRAINT acad_plan_specialties_id_key UNIQUE (specialties_id);


--
-- Name: degree degree_name_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.degree
    ADD CONSTRAINT degree_name_key UNIQUE (name);


--
-- Name: degree degree_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.degree
    ADD CONSTRAINT degree_pkey PRIMARY KEY (id);


--
-- Name: dep_load dep_load_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.dep_load
    ADD CONSTRAINT dep_load_pkey PRIMARY KEY (id);


--
-- Name: department department_name_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_name_key UNIQUE (name);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- Name: disciplines_groups disciplines_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_groups
    ADD CONSTRAINT disciplines_groups_pkey PRIMARY KEY (id);


--
-- Name: disciplines disciplines_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines
    ADD CONSTRAINT disciplines_pkey PRIMARY KEY (id);


--
-- Name: disciplines_teachers disciplines_teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_teachers
    ADD CONSTRAINT disciplines_teachers_pkey PRIMARY KEY (id);


--
-- Name: files_acad_plan files_acad_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan
    ADD CONSTRAINT files_acad_plan_pkey PRIMARY KEY (id);


--
-- Name: files_dep_load files_dep_load_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load
    ADD CONSTRAINT files_dep_load_pkey PRIMARY KEY (id);


--
-- Name: files_ind_plan files_ind_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_ind_plan
    ADD CONSTRAINT files_ind_plan_pkey PRIMARY KEY (id);


--
-- Name: files_projects files_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects
    ADD CONSTRAINT files_projects_pkey PRIMARY KEY (id);


--
-- Name: files_rpd files_rpd_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_rpd
    ADD CONSTRAINT files_rpd_pkey PRIMARY KEY (id);


--
-- Name: groups groups_name_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_name_key UNIQUE (name);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: personalities personalities_email_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.personalities
    ADD CONSTRAINT personalities_email_key UNIQUE (email);


--
-- Name: personalities personalities_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.personalities
    ADD CONSTRAINT personalities_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: ranks ranks_name_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT ranks_name_key UNIQUE (name);


--
-- Name: ranks ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: rights_roles rights_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.rights_roles
    ADD CONSTRAINT rights_roles_pkey PRIMARY KEY (id);


--
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- Name: students students_person_id_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_person_id_key UNIQUE (person_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: students_projects students_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students_projects
    ADD CONSTRAINT students_projects_pkey PRIMARY KEY (id);


--
-- Name: sub_unit sub_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.sub_unit
    ADD CONSTRAINT sub_unit_pkey PRIMARY KEY (id);


--
-- Name: teachers teachers_login_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_login_key UNIQUE (login);


--
-- Name: teachers teachers_person_id_key; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_person_id_key UNIQUE (person_id);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);


--
-- Name: acad_discipline acad_discipline_acad_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_discipline
    ADD CONSTRAINT acad_discipline_acad_block_id_fkey FOREIGN KEY (acad_block_id) REFERENCES public.acad_block(id);


--
-- Name: acad_discipline acad_discipline_acad_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_discipline
    ADD CONSTRAINT acad_discipline_acad_module_id_fkey FOREIGN KEY (acad_module_id) REFERENCES public.acad_module(id);


--
-- Name: acad_discipline acad_discipline_acad_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_discipline
    ADD CONSTRAINT acad_discipline_acad_part_id_fkey FOREIGN KEY (acad_part_id) REFERENCES public.acad_part(id);


--
-- Name: acad_discipline acad_discipline_acad_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_discipline
    ADD CONSTRAINT acad_discipline_acad_plan_id_fkey FOREIGN KEY (acad_plan_id) REFERENCES public.acad_plan(id) ON DELETE CASCADE;


--
-- Name: acad_plan acad_plan_specialties_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_plan
    ADD CONSTRAINT acad_plan_specialties_id_fkey FOREIGN KEY (specialties_id) REFERENCES public.specialties(id) ON DELETE CASCADE;


--
-- Name: dep_load dep_load_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.dep_load
    ADD CONSTRAINT dep_load_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: disciplines disciplines_acad_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines
    ADD CONSTRAINT disciplines_acad_discipline_id_fkey FOREIGN KEY (acad_discipline_id) REFERENCES public.acad_discipline(id);


--
-- Name: disciplines disciplines_dep_load_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines
    ADD CONSTRAINT disciplines_dep_load_id_fkey FOREIGN KEY (dep_load_id) REFERENCES public.dep_load(id) ON DELETE CASCADE;


--
-- Name: disciplines_groups disciplines_groups_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_groups
    ADD CONSTRAINT disciplines_groups_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.disciplines(id);


--
-- Name: disciplines_groups disciplines_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_groups
    ADD CONSTRAINT disciplines_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: disciplines_teachers disciplines_teachers_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_teachers
    ADD CONSTRAINT disciplines_teachers_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.disciplines(id);


--
-- Name: disciplines_teachers disciplines_teachers_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_teachers
    ADD CONSTRAINT disciplines_teachers_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: files_acad_plan files_acad_plan_acad_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan
    ADD CONSTRAINT files_acad_plan_acad_plan_id_fkey FOREIGN KEY (acad_plan_id) REFERENCES public.acad_plan(id);


--
-- Name: files_acad_plan files_acad_plan_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan
    ADD CONSTRAINT files_acad_plan_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id) ON DELETE CASCADE;


--
-- Name: files_acad_plan files_acad_plan_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan
    ADD CONSTRAINT files_acad_plan_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- Name: files_dep_load files_dep_load_dep_load_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load
    ADD CONSTRAINT files_dep_load_dep_load_id_fkey FOREIGN KEY (dep_load_id) REFERENCES public.dep_load(id) ON DELETE CASCADE;


--
-- Name: files_dep_load files_dep_load_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load
    ADD CONSTRAINT files_dep_load_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_dep_load files_dep_load_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load
    ADD CONSTRAINT files_dep_load_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- Name: files_ind_plan files_ind_plan_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_ind_plan
    ADD CONSTRAINT files_ind_plan_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_ind_plan files_ind_plan_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_ind_plan
    ADD CONSTRAINT files_ind_plan_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- Name: files_projects files_projects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects
    ADD CONSTRAINT files_projects_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: files_projects files_projects_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects
    ADD CONSTRAINT files_projects_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_projects files_projects_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects
    ADD CONSTRAINT files_projects_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- Name: files_rpd files_rpd_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_rpd
    ADD CONSTRAINT files_rpd_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.disciplines(id);


--
-- Name: files_rpd files_rpd_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_rpd
    ADD CONSTRAINT files_rpd_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_rpd files_rpd_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_rpd
    ADD CONSTRAINT files_rpd_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- Name: groups groups_specialties_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_specialties_id_fkey FOREIGN KEY (specialties_id) REFERENCES public.specialties(id) ON DELETE CASCADE;


--
-- Name: projects projects_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: projects projects_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE SET NULL;


--
-- Name: rights_roles rights_roles_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.rights_roles
    ADD CONSTRAINT rights_roles_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: rights_roles rights_roles_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.rights_roles
    ADD CONSTRAINT rights_roles_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id) ON DELETE CASCADE;


--
-- Name: specialties specialties_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: students students_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- Name: students students_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.personalities(id);


--
-- Name: students_projects students_projects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students_projects
    ADD CONSTRAINT students_projects_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: students_projects students_projects_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students_projects
    ADD CONSTRAINT students_projects_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;


--
-- Name: sub_unit sub_unit_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.sub_unit
    ADD CONSTRAINT sub_unit_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(id);


--
-- Name: teachers teachers_degree_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_degree_id_fkey FOREIGN KEY (degree_id) REFERENCES public.degree(id);


--
-- Name: teachers teachers_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.personalities(id);


--
-- Name: teachers teachers_rank_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_rank_id_fkey FOREIGN KEY (rank_id) REFERENCES public.ranks(id);


--
-- PostgreSQL database dump complete
--

