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
    teacher_id integer NOT NULL
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
    teacher_id integer NOT NULL,
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
    teacher_id integer NOT NULL,
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
    teacher_id integer NOT NULL,
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
    teacher_id integer NOT NULL,
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
    teacher_id integer NOT NULL,
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
    group_id integer NOT NULL
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
1	Инностранный язык	Б.1.1.1	9	\N	\N	162	1	1	1	1	\N	{1,2,3}	{54,54,54}	f
2	Русский язык и культура речи	Б.1.1.2	2	\N	36	\N	1	1	1	2	\N	{1}	{36}	f
3	Навыки эффективной презентации	Б.1.1.3	2	\N	36	\N	1	1	1	3	\N	{2}	{NULL,36}	f
4	Безопасность жизнедеятельности	Б.1.1.4	2	18	18	\N	1	1	1	4	\N	{4}	{NULL,NULL,NULL,36}	f
100	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	102	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
101	Математический анализ	A.1.1.2	4	36	\N	36	102	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
102	Дискретная математика	A.1.1.3	4	36	\N	36	102	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
103	Иностранный язык	А.1.2.1	12	\N	\N	204	102	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
104	Технический перевод	А.1.2.2	6	\N	\N	106	102	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
105	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	102	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
106	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	102	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
107	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	102	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
108	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	102	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
109	Философия	А.1.4.1	2	\N	\N	36	102	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
110	История России	А.1.4.2	1	\N	\N	\N	102	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
111	Всеобщая история	А.1.4.3	1	\N	\N	\N	102	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
112	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	102	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
113	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	102	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
114	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	102	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
115	Проектная деятельность	А.1.5.2	10	\N	10	\N	102	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
116	Проектный менеджмент	А.1.5.3	4	34	34	\N	102	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
117	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	102	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
118	Инженерное проектирование	А.1.6.1	5	\N	10	\N	102	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
119	Основы ИКТ	А.1.7.1	4	\N	72	\N	102	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
120	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	102	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
121	Базы данных	А.1.8.1	3	18	36	\N	102	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
122	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	102	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
123	Мобильная разработка	А.1.8.3	4	\N	72	\N	102	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
124	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	102	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
125	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	102	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
126	Теория вероятностей	А.2.1.2	4	36	\N	36	102	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
127	Основы программирования	А.2.2.1	4	\N	72	\N	102	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
128	Веб-разработка	А.2.2.2	2	\N	36	\N	102	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
129	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	102	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
130	Защита информации	А.2.2.4	4	\N	72	\N	102	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
131	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	102	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
132	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	102	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
133	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	102	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
134	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	102	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
135	Разработка ТЭО	А.2.3.5	4	36	36	\N	102	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
136	Инженерная графика	А.2.3.1	4	18	36	\N	102	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
137	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	102	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
138	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	102	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
139	Основы измерения деталей	А.2.3.4	2	\N	36	\N	102	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
140	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	102	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
141	Конструкторская документация	А.2.3.6	2	\N	36	\N	102	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
142	Электротехника и электроника	А.2.3.7	4	36	\N	36	102	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
143	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	102	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
144	Физика	А.2.3.9	8	72	36	36	102	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
145	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	102	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
146	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	102	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
147	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	102	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
148	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	102	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
149	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	102	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
150	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	102	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
151	Программирование в САПР	А.2.6.1	6	\N	108	\N	102	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
152	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	102	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
153	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	102	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
154	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	102	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
155	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	102	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
156	Организация производства в САПР	А.2.7.1	2	\N	36	\N	102	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
157	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	102	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
158	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	102	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
159	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	105	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
160	Математический анализ	A.1.1.2	4	36	\N	36	105	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
161	Дискретная математика	A.1.1.3	4	36	\N	36	105	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
162	Иностранный язык	А.1.2.1	12	\N	\N	204	105	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
163	Технический перевод	А.1.2.2	6	\N	\N	106	105	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
164	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	105	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
165	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	105	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
166	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	105	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
167	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	105	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
168	Философия	А.1.4.1	2	\N	\N	36	105	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
169	История России	А.1.4.2	1	\N	\N	\N	105	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
170	Всеобщая история	А.1.4.3	1	\N	\N	\N	105	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
171	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	105	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
172	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	105	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
173	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	105	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
174	Проектная деятельность	А.1.5.2	10	\N	10	\N	105	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
175	Проектный менеджмент	А.1.5.3	4	34	34	\N	105	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
176	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	105	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
177	Инженерное проектирование	А.1.6.1	5	\N	10	\N	105	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
178	Основы ИКТ	А.1.7.1	4	\N	72	\N	105	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
179	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	105	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
180	Базы данных	А.1.8.1	3	18	36	\N	105	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
181	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	105	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
182	Мобильная разработка	А.1.8.3	4	\N	72	\N	105	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
183	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	105	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
184	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	105	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
185	Теория вероятностей	А.2.1.2	4	36	\N	36	105	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
186	Основы программирования	А.2.2.1	4	\N	72	\N	105	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
187	Веб-разработка	А.2.2.2	2	\N	36	\N	105	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
188	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	105	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
189	Защита информации	А.2.2.4	4	\N	72	\N	105	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
190	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	105	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
191	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	105	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
192	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	105	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
193	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	105	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
194	Разработка ТЭО	А.2.3.5	4	36	36	\N	105	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
195	Инженерная графика	А.2.3.1	4	18	36	\N	105	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
196	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	105	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
197	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	105	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
198	Основы измерения деталей	А.2.3.4	2	\N	36	\N	105	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
199	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	105	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
200	Конструкторская документация	А.2.3.6	2	\N	36	\N	105	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
201	Электротехника и электроника	А.2.3.7	4	36	\N	36	105	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
202	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	105	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
203	Физика	А.2.3.9	8	72	36	36	105	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
204	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	105	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
205	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	105	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
206	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	105	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
207	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	105	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
208	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	105	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
209	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	105	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
210	Программирование в САПР	А.2.6.1	6	\N	108	\N	105	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
211	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	105	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
212	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	105	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
213	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	105	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
214	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	105	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
215	Организация производства в САПР	А.2.7.1	2	\N	36	\N	105	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
216	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	105	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
217	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	105	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
218	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	106	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
219	Математический анализ	A.1.1.2	4	36	\N	36	106	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
220	Дискретная математика	A.1.1.3	4	36	\N	36	106	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
221	Иностранный язык	А.1.2.1	12	\N	\N	204	106	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
222	Технический перевод	А.1.2.2	6	\N	\N	106	106	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
223	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	106	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
224	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	106	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
225	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	106	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
226	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	106	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
227	Философия	А.1.4.1	2	\N	\N	36	106	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
228	История России	А.1.4.2	1	\N	\N	\N	106	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
229	Всеобщая история	А.1.4.3	1	\N	\N	\N	106	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
230	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	106	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
231	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	106	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
232	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	106	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
233	Проектная деятельность	А.1.5.2	10	\N	10	\N	106	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
234	Проектный менеджмент	А.1.5.3	4	34	34	\N	106	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
235	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	106	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
236	Инженерное проектирование	А.1.6.1	5	\N	10	\N	106	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
237	Основы ИКТ	А.1.7.1	4	\N	72	\N	106	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
238	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	106	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
239	Базы данных	А.1.8.1	3	18	36	\N	106	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
240	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	106	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
241	Мобильная разработка	А.1.8.3	4	\N	72	\N	106	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
242	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	106	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
243	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	106	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
244	Теория вероятностей	А.2.1.2	4	36	\N	36	106	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
245	Основы программирования	А.2.2.1	4	\N	72	\N	106	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
246	Веб-разработка	А.2.2.2	2	\N	36	\N	106	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
247	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	106	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
248	Защита информации	А.2.2.4	4	\N	72	\N	106	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
249	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	106	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
250	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	106	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
251	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	106	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
252	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	106	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
253	Разработка ТЭО	А.2.3.5	4	36	36	\N	106	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
254	Инженерная графика	А.2.3.1	4	18	36	\N	106	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
255	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	106	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
256	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	106	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
257	Основы измерения деталей	А.2.3.4	2	\N	36	\N	106	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
258	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	106	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
259	Конструкторская документация	А.2.3.6	2	\N	36	\N	106	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
260	Электротехника и электроника	А.2.3.7	4	36	\N	36	106	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
261	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	106	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
262	Физика	А.2.3.9	8	72	36	36	106	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
263	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	106	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
264	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	106	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
265	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	106	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
266	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	106	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
267	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	106	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
268	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	106	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
269	Программирование в САПР	А.2.6.1	6	\N	108	\N	106	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
270	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	106	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
271	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	106	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
272	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	106	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
273	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	106	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
274	Организация производства в САПР	А.2.7.1	2	\N	36	\N	106	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
275	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	106	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
276	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	106	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
277	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	109	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
278	Математический анализ	A.1.1.2	4	36	\N	36	109	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
279	Дискретная математика	A.1.1.3	4	36	\N	36	109	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
280	Иностранный язык	А.1.2.1	12	\N	\N	204	109	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
281	Технический перевод	А.1.2.2	6	\N	\N	106	109	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
282	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	109	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
283	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	109	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
284	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	109	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
285	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	109	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
286	Философия	А.1.4.1	2	\N	\N	36	109	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
287	История России	А.1.4.2	1	\N	\N	\N	109	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
288	Всеобщая история	А.1.4.3	1	\N	\N	\N	109	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
289	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	109	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
290	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	109	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
291	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	109	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
292	Проектная деятельность	А.1.5.2	10	\N	10	\N	109	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
293	Проектный менеджмент	А.1.5.3	4	34	34	\N	109	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
294	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	109	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
295	Инженерное проектирование	А.1.6.1	5	\N	10	\N	109	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
296	Основы ИКТ	А.1.7.1	4	\N	72	\N	109	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
297	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	109	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
298	Базы данных	А.1.8.1	3	18	36	\N	109	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
299	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	109	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
300	Мобильная разработка	А.1.8.3	4	\N	72	\N	109	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
301	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	109	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
302	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	109	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
303	Теория вероятностей	А.2.1.2	4	36	\N	36	109	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
304	Основы программирования	А.2.2.1	4	\N	72	\N	109	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
305	Веб-разработка	А.2.2.2	2	\N	36	\N	109	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
306	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	109	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
307	Защита информации	А.2.2.4	4	\N	72	\N	109	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
308	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	109	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
309	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	109	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
310	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	109	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
311	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	109	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
312	Разработка ТЭО	А.2.3.5	4	36	36	\N	109	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
313	Инженерная графика	А.2.3.1	4	18	36	\N	109	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
314	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	109	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
315	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	109	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
316	Основы измерения деталей	А.2.3.4	2	\N	36	\N	109	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
317	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	109	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
318	Конструкторская документация	А.2.3.6	2	\N	36	\N	109	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
319	Электротехника и электроника	А.2.3.7	4	36	\N	36	109	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
320	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	109	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
321	Физика	А.2.3.9	8	72	36	36	109	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
322	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	109	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
323	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	109	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
324	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	109	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
325	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	109	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
326	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	109	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
327	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	109	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
328	Программирование в САПР	А.2.6.1	6	\N	108	\N	109	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
329	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	109	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
330	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	109	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
331	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	109	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
332	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	109	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
333	Организация производства в САПР	А.2.7.1	2	\N	36	\N	109	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
334	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	109	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
335	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	109	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
336	Линейная алгебра и функция нескольких переменных	A.1.1.1	4	36	\N	36	110	100	100	100	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
337	Математический анализ	A.1.1.2	4	36	\N	36	110	100	100	100	\N	{}	{NULL,72,NULL,NULL,NULL,NULL,NULL}	f
338	Дискретная математика	A.1.1.3	4	36	\N	36	110	100	100	100	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
339	Иностранный язык	А.1.2.1	12	\N	\N	204	110	103	103	103	\N	{1,2,3}	{68,68,34,34,NULL,NULL,NULL}	f
340	Технический перевод	А.1.2.2	6	\N	\N	106	110	103	103	103	\N	{5,6}	{NULL,NULL,NULL,NULL,34,36,36}	f
341	Коммуникация в ИТ-сфере	А.1.3.1	2	\N	36	\N	110	103	103	105	\N	{1}	{36,NULL,NULL,NULL,NULL,NULL,NULL}	f
342	Навыки эффективной презентации	А.1.3.2	2	\N	36	\N	110	103	103	105	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
343	Нормативное регулирование внедрения и эксплуатации ИС	А.1.3.3	3	18	36	\N	110	103	103	105	\N	{5}	{NULL,NULL,NULL,NULL,54,NULL,NULL}	f
344	Документирование этапов жизненного цикла ИС	А.1.3.4	4	\N	72	\N	110	103	103	105	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
345	Философия	А.1.4.1	2	\N	\N	36	110	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,36}	f
346	История России	А.1.4.2	1	\N	\N	\N	110	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
347	Всеобщая история	А.1.4.3	1	\N	\N	\N	110	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
348	Безопасность жизнедеятельности	А.1.4.4	2	\N	\N	\N	110	103	103	109	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,NULL}	f
349	Физическая культура и спорт	А.1.4.5	2	\N	\N	36	110	103	103	109	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
350	Введение в проектную деятельность	А.1.5.1	4	\N	4	\N	110	103	103	114	\N	{1,2}	{2,2,NULL,NULL,NULL,NULL,NULL}	f
351	Проектная деятельность	А.1.5.2	10	\N	10	\N	110	103	103	114	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
352	Проектный менеджмент	А.1.5.3	4	34	34	\N	110	103	103	114	\N	{4}	{NULL,NULL,NULL,34,34,NULL,NULL}	f
353	Технологическое предпринимательство	А.1.5.4	4	36	36	\N	110	103	103	114	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,36}	f
354	Инженерное проектирование	А.1.6.1	5	\N	10	\N	110	103	103	118	\N	{3,4,5,6,7}	{NULL,NULL,2,2,2,2,2}	f
355	Основы ИКТ	А.1.7.1	4	\N	72	\N	110	103	103	119	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
356	Сети и телекоммуникации	А.1.7.2	4	\N	72	\N	110	103	103	119	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
357	Базы данных	А.1.8.1	3	18	36	\N	110	103	103	121	\N	{}	{NULL,NULL,54,NULL,NULL,NULL,NULL}	f
358	Математическая логика и теория алгоритмов в практике программирования	А.1.8.2	4	36	36	\N	110	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
359	Мобильная разработка	А.1.8.3	4	\N	72	\N	110	103	103	121	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
360	Элективные дисциплины по физической культуре и спорту	А.1.9	\N	\N	\N	328	110	103	103	124	\N	{}	{72,72,72,72,40,NULL,NULL}	f
361	Комплексная математика и дифференциальные уравнения	А.2.1.1	4	36	\N	36	110	103	125	125	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
362	Теория вероятностей	А.2.1.2	4	36	\N	36	110	103	125	125	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
363	Основы программирования	А.2.2.1	4	\N	72	\N	110	103	125	127	\N	{}	{72,NULL,NULL,NULL,NULL,NULL,NULL}	f
364	Веб-разработка	А.2.2.2	2	\N	36	\N	110	103	125	127	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
365	Разработка веб-приложений и баз данных	А.2.2.3	5	18	72	\N	110	103	125	127	\N	{}	{NULL,NULL,NULL,90,NULL,NULL,NULL}	f
366	Защита информации	А.2.2.4	4	\N	72	\N	110	103	125	127	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
367	Моделирование и реинжиниринг бизнес-процессов внедрения и эксплуатации САПР	А.2.3.1	3	\N	54	\N	110	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,54,NULL}	f
368	Управление нормативно-справочной информацией	А.2.3.2	4	\N	72	\N	110	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
369	Корпоративные информационные системы	А.2.3.3	3	\N	54	\N	110	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,54}	f
370	Управление жизненным циклом и документами	А.2.3.4	4	36	36	\N	110	103	125	131	\N	{}	{NULL,NULL,NULL,NULL,NULL,72,NULL}	f
371	Разработка ТЭО	А.2.3.5	4	36	36	\N	110	103	125	131	\N	{7}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
372	Инженерная графика	А.2.3.1	4	18	36	\N	110	103	125	136	\N	{}	{54,NULL,NULL,NULL,NULL,NULL,NULL}	f
373	Основы проектирования механизмов	А.2.3.2	4	\N	54	\N	110	103	125	136	\N	{}	{NULL,54,NULL,NULL,NULL,NULL,NULL}	f
374	Машиностроительное черчение	А.2.3.3	2	\N	36	\N	110	103	125	136	\N	{2}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
375	Основы измерения деталей	А.2.3.4	2	\N	36	\N	110	103	125	136	\N	{}	{NULL,36,NULL,NULL,NULL,NULL,NULL}	f
376	Основы материаловедения и сопротивления материалов	А.2.3.5	4	36	\N	36	110	103	125	136	\N	{}	{NULL,NULL,72,NULL,NULL,NULL,NULL}	f
377	Конструкторская документация	А.2.3.6	2	\N	36	\N	110	103	125	136	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
378	Электротехника и электроника	А.2.3.7	4	36	\N	36	110	103	125	136	\N	{}	{NULL,NULL,NULL,72,NULL,NULL,NULL}	f
379	Основы термо-, гидро- и газодинамики	А.2.3.8	4	36	36	\N	110	103	125	136	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
380	Физика	А.2.3.9	8	72	36	36	110	103	125	136	\N	{}	{72,72,NULL,NULL,NULL,NULL,NULL}	f
381	Тайм-менеджмент	А.2.4.1	2	\N	\N	36	110	103	125	145	\N	{6}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
382	Основы маркетинговых исследований и анализа	А.2.4.2	2	\N	\N	34	110	103	125	145	\N	{3}	{NULL,NULL,34,NULL,NULL,NULL,NULL}	f
383	Трехмерное моделирование в САПР	А.2.5.1	6	\N	108	\N	110	103	125	147	\N	{1}	{36,72,NULL,NULL,NULL,NULL,NULL}	f
384	Компьютерное моделирование деталей машин	А.2.5.2	2	\N	36	\N	110	103	125	147	\N	{}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
385	Компьютерное проектирование деталей машин	А.2.5.3	6	\N	108	\N	110	103	125	147	\N	{4,5}	{NULL,NULL,NULL,72,36,NULL,NULL}	f
386	Технология машиностроения в Inventor	А.2.5.4	4	18	54	\N	110	103	125	147	\N	{}	{NULL,NULL,NULL,NULL,72,NULL,NULL}	f
387	Программирование в САПР	А.2.6.1	6	\N	108	\N	110	103	125	151	\N	{2}	{NULL,36,72,NULL,NULL,NULL,NULL}	f
388	ИТ-практикум по сопротивлению материалов	А.2.6.2	2	\N	36	\N	110	103	125	151	\N	{3}	{NULL,NULL,36,NULL,NULL,NULL,NULL}	f
389	ИТ-практикум по электротехнике и электронике	А.2.6.3	2	\N	36	\N	110	103	125	151	\N	{4}	{NULL,NULL,NULL,36,NULL,NULL,NULL}	f
390	ИТ-практикум по термо-, гидро- и газодинамике	А.2.6.4	2	\N	36	\N	110	103	125	151	\N	{5}	{NULL,NULL,NULL,NULL,36,NULL,NULL}	f
391	Бизнес-планирование в ИТ	А.2.7.1	2	\N	36	\N	110	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
392	Организация производства в САПР	А.2.7.1	2	\N	36	\N	110	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,36,NULL}	f
393	Прикладные САПР-технологии	А.2.7.2	4	\N	72	\N	110	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
394	Прикладные облачные технологии	А.2.7.2	4	\N	72	\N	110	103	125	155	\N	{}	{NULL,NULL,NULL,NULL,NULL,NULL,72}	f
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
1	2016-09-01 09:00:00	2
102	2020-04-25 21:56:48	100
105	2020-04-28 17:08:04	101
106	2020-04-28 20:45:48	102
109	2020-04-28 20:52:05	103
110	2020-04-28 21:01:12	104
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
1	1	2016-09-01 09:00:00	2016-09-01 09:00:00	2016-09-01 09:00:00
2	2	2016-09-01 09:00:00	2016-09-01 09:00:00	2016-09-01 09:00:00
3	1	2016-09-01 09:00:00	2016-09-01 09:00:00	2016-09-01 09:00:00
4	2	2016-09-01 09:00:00	2016-09-01 09:00:00	2016-09-01 09:00:00
108	1	2016-09-01 09:00:00	2016-09-01 09:00:00	2016-09-01 09:00:00
109	1	2016-09-01 09:00:00	2016-09-01 09:00:00	2016-09-01 09:00:00
119	1	2016-09-01 09:00:00	2016-09-01 09:00:00	2020-04-25 21:27:51
120	2	2017-05-28 00:00:00	2017-05-31 00:00:00	2020-04-28 21:03:22
121	100	2017-05-31 00:00:00	2017-06-30 00:00:00	2020-04-30 01:21:18
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.department (id, name) FROM stdin;
1	Информатика и вычислительная техника
2	Проектная деятельность
100	Векторные вычисления и магия
\.


--
-- Data for Name: disciplines; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.disciplines (id, name, hours_con_project, hours_lec, hours_sem, hours_lab, hours_con_exam, hours_zachet, hours_exam, hours_kurs_project, hours_gek, hours_ruk_prakt, hours_ruk_vkr, hours_ruk_mag, hours_ruk_aspirant, semester_num, acad_discipline_id, dep_load_id, is_approved) FROM stdin;
1	Инностранный язык	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	1	f
2	Русский язык и культура речи	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	2	f
3	Навыки эффективной презентации	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	3	f
4	Безопасность жизнедеятельности	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	4	f
106	1	\N	\N	324	162	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	108	f
107	2	2	2.0999999	2.20000005	2.29999995	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	1	\N	108	f
108	3	3	3	3	3	3	3	3	3	3	3	3	3	3	1	\N	108	f
109	1	\N	\N	324	162	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	109	f
110	2	2	2.0999999	2.20000005	2.29999995	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	2.20000005	1	\N	109	f
111	3	3	3	3	3	3	3	3	3	3	3	3	3	3	1	\N	109	f
196	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	119	f
197	Информационная безопасность	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
198	Мобильная интеграция	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
199	Основы права в Веб	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	119	f
200	Поисковая оптимизация	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
201	Программирование в системах информационной безопасности	\N	\N	\N	136	1	\N	5.4000001	\N	\N	\N	\N	\N	\N	1	\N	119	f
202	Проектирование Веб-сервисов	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
203	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	119	f
204	Статистические методы веб-аналитики	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
205	Веб-аналитика	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
206	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	119	f
207	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
208	Проектирование информационных систем	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	119	f
209	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	119	f
210	Разработка в КИС	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
211	Реклама в Веб и Социальных медиа	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
212	Трехмерные модели в веб-приложениях	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	119	f
213	Авторское право	1	2	3	5	7	9	11	13	15	16	17	18	\N	1	\N	120	f
214	Большие открытые данные	\N	34	\N	68	1	\N	7.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
215	Введение в жестовую лингвистику	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
216	Введение в проектную деятельность	236	\N	\N	15	\N	11.8000002	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
217	Введение в проектную деятельность	280	\N	\N	19	\N	14	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
218	Введение в проектную деятельность	200	\N	\N	15	\N	10	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
219	Введение в психолингвистику	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
220	Веб-райтинг	\N	\N	\N	102	\N	9	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
221	Веб-райтинг	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
222	Веб-технологии	\N	\N	\N	272	3	\N	17.1000004	\N	\N	\N	\N	\N	\N	1	\N	120	f
223	Детали машин и компьютерное моделирование в Inventor	\N	\N	\N	136	\N	11.3999996	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
224	Дискретная математика	\N	34	34	\N	1	\N	8.69999981	\N	\N	\N	\N	\N	\N	1	\N	120	f
225	Инженерия требований	\N	34	\N	102	2	\N	11.3999996	\N	\N	\N	\N	\N	\N	1	\N	120	f
226	Инженерное проектирование 	\N	\N	\N	4	\N	5.80000019	\N	87	\N	\N	\N	\N	\N	1	\N	120	f
227	Инженерное проектирование 	\N	\N	\N	6	\N	\N	\N	99	\N	\N	\N	\N	\N	1	\N	120	f
228	Инженерное проектирование 	\N	\N	\N	4	\N	5	\N	75	\N	\N	\N	\N	\N	1	\N	120	f
229	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	120	f
230	Инженерное проектирование 	\N	\N	\N	8	\N	9.19999981	\N	138	\N	\N	\N	\N	\N	1	\N	120	f
231	Инженерное проектирование 	\N	\N	\N	6	\N	7.5999999	\N	114	\N	\N	\N	\N	\N	1	\N	120	f
232	Инженерное проектирование 	\N	\N	\N	6	\N	9	\N	135	\N	\N	\N	\N	\N	1	\N	120	f
233	Инженерное проектирование 	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
234	Инженерное проектирование 	\N	\N	\N	8	\N	11.3999996	\N	171	\N	\N	\N	\N	\N	1	\N	120	f
235	Инженерное проектирование 	\N	\N	\N	6	\N	9	\N	135	\N	\N	\N	\N	\N	1	\N	120	f
236	Интегрированные системы проектирования и управления (факультативная)	\N	36	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
237	Интеллектуальные методы обработки информации	\N	\N	\N	68	\N	5.80000019	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
238	Информатика и вычислительная техника	\N	10	8	\N	\N	0.200000003	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
239	Информационная безопасность	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	120	f
240	Информационные системы и технологии	\N	\N	\N	272	2	\N	15	150	\N	\N	\N	\N	\N	1	\N	120	f
241	Исследование и моделирование бизнес-процессов и структур	\N	34	34	\N	1	\N	7.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
242	Коммерциализация ИТ-проектов	\N	\N	\N	68	\N	5.80000019	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
243	Коммуникация в ИТ-сфере	\N	\N	\N	136	\N	11.8000002	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
244	Коммуникация в ИТ-сфере	\N	\N	\N	170	\N	14	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
245	Коммуникация в ИТ-сфере	\N	\N	\N	136	\N	10	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
246	Компьютерная лингвистика	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
247	Компьютерная лингвистика	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
248	Компьютерное моделирование интеллектуальных систем (факультативная)	\N	12	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
249	Компьютерный анализ  термо-,гидро-, и газодинамических процессов	\N	34	102	\N	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	1	\N	120	f
250	Лабораторный практикум по материаловедению и сопромату	\N	\N	\N	136	\N	11.3999996	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
251	Лабораторный практикум по основам термо-, гидро- и газодинамики	\N	\N	\N	136	\N	9.19999981	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
252	Математическая логика и теория алгоритмов в программировании	\N	34	102	\N	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	1	\N	120	f
253	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	11.3999996	\N	\N	\N	\N	\N	\N	1	\N	120	f
254	Математическое обеспечение искусственного интеллекта	\N	12	9	\N	\N	0.600000024	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
255	Методы искусственного интеллекта	\N	14	11	\N	2	\N	7.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
256	Методы статистического оценивания распределенных данных	\N	17	\N	17	1	\N	2.70000005	\N	\N	\N	\N	\N	\N	1	\N	120	f
257	Мобильная интеграция	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	120	f
258	Мобильная разработка	\N	\N	\N	272	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	1	\N	120	f
259	Моделирование бизнес-процессов в веб-индустрии	\N	34	\N	68	2	\N	8.69999981	\N	\N	\N	\N	\N	\N	1	\N	120	f
260	Мультимедиа технологии	\N	11	11	11	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
261	Мультимедиа технологии	\N	11	11	11	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
262	Мультимедиа-технологии	\N	\N	\N	272	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	1	\N	120	f
263	Научно-исследовательская и проектная деятельность	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
264	Научно-исследовательская и проектная деятельность	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
265	Объектно-ориентированное проектрование	\N	34	\N	102	2	\N	13.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
266	Основы баз данных	\N	17	\N	153	\N	9	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
267	Основы веб-технологий	\N	\N	\N	272	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	1	\N	120	f
268	Основы ИКТ	\N	\N	\N	272	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	1	\N	120	f
269	Основы ИКТ	\N	\N	\N	340	3	\N	21	\N	\N	\N	\N	\N	\N	1	\N	120	f
270	Основы ИКТ	\N	\N	\N	136	1	\N	8.10000038	\N	\N	\N	\N	\N	\N	1	\N	120	f
271	Основы ИКТ	\N	\N	\N	136	1	\N	7.80000019	\N	\N	\N	\N	\N	\N	1	\N	120	f
272	Основы ИКТ	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
273	Основы ИКТ	\N	\N	\N	272	2	\N	15	\N	\N	\N	\N	\N	\N	1	\N	120	f
274	Основы КИС	\N	34	\N	102	2	\N	13.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
275	Основы маркетинга в САПР	\N	17	51	\N	\N	11.3999996	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
276	Основы права в Веб	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
277	Основы программирования	\N	\N	\N	204	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	1	\N	120	f
278	Основы программирования	\N	\N	\N	340	3	\N	21	\N	\N	\N	\N	\N	\N	1	\N	120	f
279	Основы программирования	\N	\N	\N	204	2	\N	15	\N	\N	\N	\N	\N	\N	1	\N	120	f
280	Основы сетевых технологий	\N	\N	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
281	Основы сетевых технологий	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
282	Основы тестирования	\N	\N	\N	136	\N	10	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
283	Основы языкознания 	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
284	Основы языкознания 	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	850	\N	1	\N	120	f
285	Параллельное программирование	\N	18	14	\N	2	\N	4.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
286	Письменная деловая комуникация	\N	\N	102	\N	\N	9.19999981	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
287	Поисковая оптимизация	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	120	f
288	Прикладные и системные компоненты и КИС	\N	17	\N	34	1	\N	7.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
289	Принтмедиа технологии	\N	11	11	11	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
290	Программирование	\N	\N	\N	68	\N	3.79999995	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
291	Программирование	\N	\N	\N	102	\N	9	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
292	Программирование в КИС 1С	\N	\N	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
293	Программирование в системах информационной безопасности	\N	\N	\N	136	1	\N	5.4000001	\N	\N	\N	\N	\N	\N	1	\N	120	f
294	Программирование в системах информационной безопасности	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
295	Программирование веб-приложений	\N	\N	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
296	Программирование веб-приложений	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
297	Програмное обеспечение для проектирования автомобиля	\N	\N	\N	68	1	\N	6.9000001	\N	\N	\N	\N	\N	\N	1	\N	120	f
298	Програмное обеспечение для проектирования автомобиля	\N	\N	\N	102	1	\N	7.19999981	\N	\N	\N	\N	\N	\N	1	\N	120	f
299	Проектирование Веб-сервисов	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	120	f
300	Проектирование графического интерфейса оператора	\N	7	\N	25	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
301	Проектирование сайтов	\N	\N	\N	136	\N	11.8000002	\N	177	\N	\N	\N	\N	\N	1	\N	120	f
302	Проектная деятельность	\N	\N	\N	4	\N	5.80000019	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
303	Проектная деятельность	\N	\N	\N	6	\N	6.5999999	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
304	Проектная деятельность	\N	\N	\N	4	\N	5	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
305	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
306	Проектная деятельность	\N	\N	\N	8	\N	9.19999981	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
307	Проектная деятельность	\N	\N	\N	6	\N	7.5999999	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
308	Проектная деятельность	\N	\N	\N	6	\N	9	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
309	Проектная деятельность	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
310	Проектная деятельность	\N	\N	\N	8	\N	11.3999996	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
311	Проектная деятельность	\N	\N	\N	6	\N	9	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
312	Проектное управление в ИТ сфере	\N	34	\N	102	2	\N	9.89999962	\N	\N	\N	\N	\N	\N	1	\N	120	f
313	Проектное управление в ИТ сфере	\N	34	\N	68	1	\N	7.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
314	Производственная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	\N	\N	\N	1	\N	120	f
315	Производственная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	18	\N	\N	\N	1	\N	120	f
316	Психолингвистические исследования	\N	11	11	11	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
317	Разработка в КИС	\N	\N	\N	136	2	\N	8.69999981	\N	\N	\N	\N	\N	\N	1	\N	120	f
318	Разработка документации в ИТ-проектах и разработке	\N	\N	\N	136	2	\N	8.69999981	\N	\N	\N	\N	\N	\N	1	\N	120	f
319	Разработка программной документации	\N	17	\N	102	2	\N	9.89999962	\N	\N	\N	\N	\N	\N	1	\N	120	f
320	Разработка технического задания	\N	34	\N	102	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
321	Разработка ТЭО	\N	17	34	\N	\N	6.5999999	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
322	Разработка ТЭО в ИТ-сфере	\N	\N	\N	68	\N	5.80000019	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
323	Распознавание образов	\N	11	11	11	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
324	Распознавание образов	\N	11	11	11	1	\N	2.70000005	\N	\N	\N	\N	\N	\N	1	\N	120	f
325	Редактирование технических текстов	\N	11	11	11	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
326	Редактирование технических текстов	\N	11	11	11	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
327	Реинжиниринг бизнес-процессов в САПР	\N	34	\N	102	2	\N	9.89999962	\N	\N	\N	\N	\N	\N	1	\N	120	f
328	Семиотика и когнитология	\N	11	11	11	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
329	Семиотика и когнитология	\N	11	11	11	1	\N	2.70000005	\N	\N	\N	\N	\N	\N	1	\N	120	f
330	Сетевое программирование	\N	34	\N	102	2	\N	11.3999996	\N	\N	\N	\N	\N	\N	1	\N	120	f
331	Сети и системы передачи информации	\N	\N	\N	136	1	\N	8.69999981	\N	\N	\N	\N	\N	\N	1	\N	120	f
332	Системы автоматического проектирования и прототипирование	\N	17	\N	102	1	\N	7.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
333	Скрипты	\N	\N	\N	102	\N	9	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
334	Скрипты	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
335	Случайные процессы	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
336	Случайные процессы	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
337	Современные тенденции Интернет-идустрии (факультативная)	\N	\N	34	\N	\N	5.80000019	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
338	Современные технологии программирования	\N	6	\N	193	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
339	Современные технологии программирования	\N	6	\N	193	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
340	Статистические методы веб-аналитики	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	120	f
341	Стилистика (факультативная)	\N	8	26	\N	1	\N	2.0999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
342	Стилистика (факультативная)	\N	16	16	\N	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
343	Стилистика (факультативная)	\N	8	26	\N	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
344	Стилистика (факультативная)	\N	8	26	\N	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
345	Структуры данных в веб	\N	\N	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
346	Структуры данных в веб	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
347	Телемедицина	\N	11	11	11	1	\N	2.70000005	\N	\N	\N	\N	\N	\N	1	\N	120	f
348	Технические средства измерений (факультативная)	\N	8	26	\N	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
349	Технические средства измерений (факультативная)	\N	8	26	\N	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
350	Технические средства медицинских исследований	\N	11	11	11	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
351	Технологии программирования в САПР	\N	\N	\N	272	3	\N	17.1000004	\N	\N	\N	\N	\N	\N	1	\N	120	f
352	Технологическое предпринимательство	\N	17	34	\N	\N	6.5999999	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
353	Технология проектирования ИС	\N	\N	\N	136	\N	5	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
354	Трехмерное моделирование в САПР	\N	\N	\N	170	\N	14	\N	210	\N	\N	\N	\N	\N	1	\N	120	f
355	Управление жизненным циклом и документами (PLM|PDM) в САПР	\N	34	\N	136	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	1	\N	120	f
356	Управление нормативно-справочной информацией (MDM)	\N	34	\N	102	2	\N	9.89999962	\N	\N	\N	\N	\N	\N	1	\N	120	f
357	Управление программными проектами	\N	17	\N	51	\N	7.5999999	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
358	Учебная практика 	\N	\N	\N	\N	\N	\N	\N	\N	\N	6.5999999	\N	\N	\N	1	\N	120	f
359	Формальная логика	\N	\N	\N	136	2	\N	15	\N	\N	\N	\N	\N	\N	1	\N	120	f
360	Формальные системы в информационной безопасности	\N	\N	\N	34	1	\N	3	\N	\N	\N	\N	\N	\N	1	\N	120	f
361	Формальные системы в информационной безопасности	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
362	Формальные языки и грамматики	\N	11	11	11	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	1	\N	120	f
363	Формальные языки и грамматики	\N	11	11	11	1	\N	2.70000005	\N	\N	\N	\N	\N	\N	1	\N	120	f
364	Экспертные системы принятия решений	\N	\N	\N	102	\N	5	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
365	Электронный документооборот	\N	\N	\N	136	\N	10	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
366	Юзабилити сайтов	\N	\N	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	1	\N	120	f
367	Юзабилити сайтов	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	120	f
368	Автоматический перевод	\N	7	9	9	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
369	Автоматический перевод	\N	7	9	9	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
370	Администрирование серверов	\N	\N	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	2	\N	120	f
371	Администрирование серверов	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
372	Анализ и автоматическая обработка данных	\N	7	9	9	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
373	Анализ и автоматическая обработка данных	\N	7	9	9	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
374	Анатомия и физиология мозга	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
375	Анатомия и физиология человека	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
376	Базы данных	\N	17	\N	204	3	\N	17.1000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
377	Базы данных	\N	17	\N	136	\N	11.8000002	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
378	Базы данных	\N	17	\N	136	\N	10	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
379	Большие открытые данные	\N	34	\N	102	2	\N	11.3999996	\N	\N	\N	\N	\N	\N	2	\N	120	f
380	Введение в проектную деятельность	236	\N	\N	8	\N	11.8000002	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
381	Введение в проектную деятельность	280	\N	\N	19	\N	14	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
382	Введение в проектную деятельность	200	\N	\N	8	\N	10	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
383	Веб-аналитика	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
384	Веб-разработка	\N	\N	\N	272	3	\N	17.1000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
385	Веб-технологии	\N	\N	\N	153	\N	9	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
386	Вероятностные основы веб-аналитики	\N	\N	68	\N	2	\N	13.5	\N	\N	\N	\N	\N	\N	2	\N	120	f
387	Вероятностные основы веб-аналитики	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
388	Вероятностные основы веб-аналитики	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
389	Внедрение ИТ решений на предприятии (факультативная)	\N	\N	153	\N	\N	9.19999981	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
390	Внедрение ИТ решений на предприятии (факультативная)	\N	\N	102	\N	\N	7.5999999	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
391	Выпускная квалификационная работа	\N	\N	\N	\N	\N	\N	\N	\N	100	\N	348	\N	\N	2	\N	120	f
392	Выпускная квалификационная работа	\N	\N	\N	\N	\N	\N	\N	\N	38	\N	300	\N	\N	2	\N	120	f
393	Выпускная квалификационная работа	\N	\N	\N	\N	\N	\N	\N	\N	49	\N	240	300	\N	2	\N	120	f
394	Выпускная квалификационная работа	\N	\N	\N	\N	\N	\N	\N	\N	37	\N	180	225	\N	2	\N	120	f
395	Дискретная математика	\N	34	102	\N	3	\N	17.1000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
396	Защита интеллектуальной собственности	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
397	Защита интеллектуальной собственности	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
398	Инженерное проектирование 	\N	\N	\N	54	2	\N	8.69999981	87	\N	\N	\N	\N	\N	2	\N	120	f
399	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	2	\N	120	f
400	Инженерное проектирование 	\N	\N	\N	8	\N	9.19999981	\N	138	\N	\N	\N	\N	\N	2	\N	120	f
401	Инженерное проектирование 	\N	\N	\N	6	\N	7.5999999	\N	114	\N	\N	\N	\N	\N	2	\N	120	f
402	Инженерное проектирование 	\N	\N	\N	6	\N	9	\N	135	\N	\N	\N	\N	\N	2	\N	120	f
403	Инженерное проектирование 	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
404	Инженерное проектирование 	\N	\N	\N	8	\N	11.3999996	\N	171	\N	\N	\N	\N	\N	2	\N	120	f
405	Инженерное проектирование 	\N	\N	\N	6	\N	9	\N	135	\N	\N	\N	\N	\N	2	\N	120	f
406	Интеграция методов моделирования (факультативная)	\N	4	22	\N	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
407	Интеграция методов моделирования (факультативная)	\N	7	18	\N	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
408	Интернет-маркетинг	\N	\N	\N	136	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	2	\N	120	f
409	Инфокогнитивные технологии	\N	12	9	\N	2	\N	7.5	\N	\N	\N	\N	\N	\N	2	\N	120	f
410	Информационный поиск	\N	7	9	9	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
411	Информационный поиск	\N	7	9	9	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
412	Исследование и моделирование бизнес-процессов и структур	\N	34	\N	204	2	\N	11.3999996	\N	\N	\N	\N	\N	\N	2	\N	120	f
413	Коммуникация и общение	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
414	Коммуникация и общение	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
415	Корпоративные информационные системы	\N	34	\N	136	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	2	\N	120	f
416	Лабораторный практикум по электротехнике и электронике	\N	\N	\N	136	\N	11.3999996	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
417	Логика и алгоритмы	\N	7	9	9	\N	2.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
418	Логика и алгоритмы	\N	7	9	9	\N	1.79999995	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
419	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
420	Математическое обеспечение искусственного интеллекта	\N	10	8	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
421	Медицинская семиотика	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
422	Медицинские информационные системы	\N	7	9	9	1	\N	2.70000005	\N	\N	\N	\N	\N	\N	2	\N	120	f
423	Медицинские экспертные системы	\N	7	9	9	1	\N	2.70000005	\N	\N	\N	\N	\N	\N	2	\N	120	f
424	Методология искусственного интеллекта	\N	10	8	\N	\N	0.200000003	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
425	Методы планирования и обработка результатов научных экспериментов 	\N	10	8	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
426	Методы статистического оценивания распределенных данных	\N	17	\N	34	\N	4	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
427	Мобильная разработка	\N	\N	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	2	\N	120	f
428	Мобильная разработка	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
429	Мобильная разработка	\N	\N	\N	204	\N	9	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
430	Моделирование бизнес-процессов в веб-индустрии	\N	\N	\N	102	\N	9	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
431	Моделирование бизнес-процессов в веб-индустрии	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
432	Моделирование бизнес-процессов в САПР	\N	34	102	\N	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	2	\N	120	f
433	Навыки эффективной презентации	\N	\N	\N	136	\N	11.8000002	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
434	Навыки эффективной презентации	\N	\N	\N	170	\N	14	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
435	Навыки эффективной презентации	\N	\N	\N	68	\N	5.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
436	Навыки эффективной презентации	\N	\N	\N	136	\N	10	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
437	Научно-исследовательская практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	\N	\N	\N	2	\N	120	f
438	Научно-исследовательская практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	\N	\N	\N	2	\N	120	f
439	Обработка изображений	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
440	Обработка изображений	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
441	Обучающие системы	\N	7	9	9	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
442	Основы веб-разработки на стороне клиента	\N	\N	\N	272	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	2	\N	120	f
443	Основы измерений деталей	\N	\N	\N	170	3	\N	21	\N	\N	\N	\N	\N	\N	2	\N	120	f
444	Основы инженерного проектирования	\N	\N	\N	8	\N	11.8000002	\N	177	\N	\N	\N	\N	\N	2	\N	120	f
445	Основы инженерного проектирования	\N	\N	\N	8	\N	10	\N	150	\N	\N	\N	\N	\N	2	\N	120	f
446	Основы моделирования информационных процессов	\N	\N	\N	272	2	\N	15	\N	\N	\N	\N	\N	\N	2	\N	120	f
447	Основы проектирования механизмов	\N	\N	\N	255	3	\N	21	\N	\N	\N	\N	\N	\N	2	\N	120	f
448	Основы серверной веб-разработки	\N	\N	\N	272	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	2	\N	120	f
449	Основы сетевых технологий	\N	\N	\N	272	3	\N	17.1000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
450	Основы сетевых технологий	\N	\N	\N	136	1	\N	8.10000038	\N	\N	\N	\N	\N	\N	2	\N	120	f
451	Основы сетевых технологий	\N	\N	\N	136	1	\N	7.80000019	\N	\N	\N	\N	\N	\N	2	\N	120	f
452	Основы сетевых технологий	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
453	Педагогическая практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	15	\N	\N	\N	2	\N	120	f
454	Письменная инженерная коммуникация в ИТ-сфере	\N	\N	\N	136	2	\N	15	\N	\N	\N	\N	\N	\N	2	\N	120	f
455	Преддипломная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	35	\N	\N	\N	2	\N	120	f
456	Преддипломная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	99	\N	\N	\N	2	\N	120	f
457	Преддипломная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	83	\N	\N	\N	2	\N	120	f
458	Преддипломная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	14	\N	\N	\N	2	\N	120	f
459	Преддипломная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	11	\N	\N	\N	2	\N	120	f
460	Прикладное программирование	\N	\N	\N	272	2	\N	15	\N	\N	\N	\N	\N	\N	2	\N	120	f
461	Прикладные и системные компоненты и КИС	\N	17	\N	102	2	\N	11.3999996	\N	\N	\N	\N	\N	\N	2	\N	120	f
462	Программирование в САПР	\N	\N	\N	170	\N	14	\N	210	\N	\N	\N	\N	\N	2	\N	120	f
463	Программная инженерия	\N	34	\N	136	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	2	\N	120	f
464	Программная инженерия	\N	\N	\N	102	2	\N	13.5	\N	\N	\N	\N	\N	\N	2	\N	120	f
465	Программная инженерия	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
466	Программная инженерия	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
467	Программная инженерия	\N	34	\N	204	2	\N	13.5	\N	\N	\N	\N	\N	\N	2	\N	120	f
468	Проектирование интеллектуальных систем	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
469	Проектирование интеллектуальных систем	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
470	Проектирование информационных систем	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
471	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
472	Проектная деятельность	\N	\N	\N	8	\N	9.19999981	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
473	Проектная деятельность	\N	\N	\N	6	\N	7.5999999	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
474	Проектная деятельность	\N	\N	\N	6	\N	9	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
475	Проектная деятельность	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
476	Проектная деятельность	\N	\N	\N	8	\N	11.3999996	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
477	Проектная деятельность	\N	\N	\N	6	\N	9	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
478	Производственная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	72	\N	\N	\N	2	\N	120	f
479	Производственная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	54	\N	\N	\N	2	\N	120	f
480	Производственная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	72	\N	\N	\N	2	\N	120	f
481	Производственная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	7.80000019	\N	\N	\N	2	\N	120	f
482	Производственная практика	\N	\N	\N	\N	\N	\N	\N	\N	\N	7.80000019	\N	\N	\N	2	\N	120	f
483	Психодидактика интелектуальных систем	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
484	Разработка в КИС	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
485	Разработка технического задания	\N	\N	\N	\N	2	\N	11.3999996	\N	\N	\N	\N	\N	\N	2	\N	120	f
486	Разработка ТЭО	\N	\N	68	\N	\N	7.5999999	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
487	Реклама в Веб и Социальных медиа	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
488	Сети и телекоммуникации	\N	\N	\N	272	2	\N	17.7000008	\N	\N	\N	\N	\N	\N	2	\N	120	f
489	Сети и телекоммуникации	\N	\N	\N	272	2	\N	15	\N	\N	\N	\N	\N	\N	2	\N	120	f
490	Системы общения на ЕЯ	\N	7	9	9	1	\N	3.5999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
491	Современные тенденции ИТ-индустрии (факультативная)	\N	34	\N	\N	\N	11.8000002	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
492	Современные тенденции ИТ-индустрии (факультативная)	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
493	Современные тенденции ИТ-индустрии (факультативная)	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
494	Стандарты и нормы автоматизированных систем	\N	14	\N	27	\N	5	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
495	Статистические методы	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
496	Статистические методы	\N	11	11	23	\N	3.4000001	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
497	Техническое зрение	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
498	Техническое зрение	\N	11	11	23	1	\N	5.0999999	\N	\N	\N	\N	\N	\N	2	\N	120	f
499	Технологии машиностроения в  Inventor	\N	23	68	91	3	\N	13.8000002	\N	\N	\N	\N	\N	\N	2	\N	120	f
500	Технология деловой коммуникации	\N	\N	34	\N	\N	6	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
501	Технология проектирования ИС	\N	\N	\N	102	\N	7.5999999	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
502	Трехмерное моделирование в САПР	\N	\N	\N	340	3	\N	21	\N	\N	\N	\N	\N	\N	2	\N	120	f
503	Трехмерные модели в веб-приложениях	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	2	\N	120	f
504	Управление веб-проектами	\N	\N	\N	102	2	\N	13.5	\N	\N	\N	\N	\N	\N	2	\N	120	f
505	Управление веб-проектами	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
506	Управление веб-проектами	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
507	Управление репутацией в Интернет	\N	\N	\N	102	\N	9	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
508	Управление репутацией в Интернет	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	120	f
509	Учебная практика 	\N	\N	\N	\N	\N	\N	\N	\N	\N	32	\N	\N	\N	2	\N	120	f
510	Учебная практика 	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	\N	\N	\N	2	\N	120	f
511	Учебная практика 	\N	\N	\N	\N	\N	\N	\N	\N	\N	16	\N	\N	\N	2	\N	120	f
512	Учебная практика 	\N	\N	\N	\N	\N	\N	\N	\N	\N	6.5999999	\N	\N	\N	2	\N	120	f
513	Учебная практика 	\N	\N	\N	\N	\N	\N	\N	\N	\N	6.5999999	\N	\N	\N	2	\N	120	f
514	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	121	f
515	Информационная безопасность	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
516	Мобильная интеграция	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
517	Основы права в Веб	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	121	f
518	Поисковая оптимизация	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
519	Программирование в системах информационной безопасности	\N	\N	\N	136	1	\N	5.4000001	\N	\N	\N	\N	\N	\N	1	\N	121	f
520	Проектирование Веб-сервисов	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
521	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	121	f
522	Статистические методы веб-аналитики	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
523	Веб-аналитика	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
524	Инженерное проектирование 	\N	\N	\N	6	\N	8.39999962	\N	126	\N	\N	\N	\N	\N	1	\N	121	f
525	Математическая логика и теория алгоритмов в программировании	\N	34	68	\N	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
526	Проектирование информационных систем	\N	\N	\N	102	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	121	f
527	Проектная деятельность	\N	\N	\N	6	\N	8.39999962	\N	\N	\N	\N	\N	\N	\N	1	\N	121	f
528	Разработка в КИС	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
529	Реклама в Веб и Социальных медиа	\N	34	\N	102	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
530	Трехмерные модели в веб-приложениях	\N	\N	\N	204	2	\N	12.6000004	\N	\N	\N	\N	\N	\N	1	\N	121	f
\.


--
-- Data for Name: disciplines_groups; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.disciplines_groups (id, discipline_id, group_id) FROM stdin;
107	106	102
108	106	1
109	107	102
110	107	1
111	108	102
112	108	1
113	109	115
114	109	116
115	110	102
116	110	1
117	111	102
118	111	1
279	196	115
280	196	116
281	197	115
282	197	116
283	198	115
284	198	116
285	199	115
286	199	116
287	200	115
288	200	116
289	201	178
290	202	115
291	202	116
292	203	115
293	203	116
294	204	115
295	204	116
296	205	115
297	205	116
298	206	115
299	206	116
300	207	115
301	207	116
302	208	115
303	208	116
304	209	115
305	209	116
306	210	115
307	210	116
308	211	115
309	211	116
310	212	115
311	212	116
312	514	115
313	514	116
314	515	115
315	515	116
316	516	115
317	516	116
318	517	115
319	517	116
320	518	115
321	518	116
322	519	178
323	520	115
324	520	116
325	521	115
326	521	116
327	522	115
328	522	116
329	523	115
330	523	116
331	524	115
332	524	116
333	525	115
334	525	116
335	526	115
336	526	116
337	527	115
338	527	116
339	528	115
340	528	116
341	529	115
342	529	116
343	530	115
344	530	116
\.


--
-- Data for Name: disciplines_teachers; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.disciplines_teachers (id, discipline_id, teacher_id) FROM stdin;
100	523	1
101	523	1
102	514	2
103	109	101
\.


--
-- Data for Name: files_acad_plan; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_acad_plan (id, name, path, ext, modified_date, teacher_id, sub_unit_id, acad_plan_id) FROM stdin;
100	AUP_-_FGOS_3__-_09_03_01_-_SAPR.xlsx	/uploads/upload_f6af030fff96449ed6c21cf0fbd64207	.xlsx	2020-05-28 20:59:05.826	1	1	110
\.


--
-- Data for Name: files_dep_load; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_dep_load (id, name, path, ext, modified_date, teacher_id, sub_unit_id, dep_load_id) FROM stdin;
100	Инфокогнитивные технологии_v1.0.xls	/uploads/upload_b70ba57f31ca3794a113dcd707534a50	.xls	2020-05-28 21:01:17.461	1	1	120
101	тестовая нагрузка.xls	/uploads/upload_aa392b65eab77e3a8e52968c5b696163	.xls	2020-05-30 01:19:10.224	1	1	121
\.


--
-- Data for Name: files_ind_plan; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_ind_plan (id, name, path, ext, modified_date, teacher_id, sub_unit_id) FROM stdin;
100	export_202003080019.sql	/uploads/upload_1bd81544b333efa5db7bfcb42f24d050	.sql	2020-05-28 14:40:37.965	1	1
101	export_202003080019.sql	/uploads/upload_9e28d5ee2517c060405e4df14aee6d1f	.sql	2020-05-28 15:00:41.064	1	1
102	export_202003080019.sql	/uploads/upload_bd35be8d62a6c353ec6d6a784c78e97d	.sql	2020-05-28 15:01:22.423	1	1
103	default.conf	/uploads/upload_86b9c276539da17df6b76086e2512559	.conf	2020-05-28 15:42:22.981	1	1
104	default.conf	/uploads/upload_3a051c447f5d5c7ec3baf6e7a7eada58	.conf	2020-05-28 15:49:30.418	1	1
105	default.conf	/uploads/upload_65af9fa1c23788309ac283e48ce05621	.conf	2020-05-28 15:50:03.026	1	1
106	default.conf	/uploads/upload_9c49047642f86f75611dcf9eb342ad10	.conf	2020-05-28 16:08:28.078	1	1
107	default.conf	/uploads/upload_4857cacccb24cb4826b4bf2a896ec2bc	.conf	2020-05-28 16:09:19.725	1	1
108	RPD.rar	/uploads/upload_1e029c77e63bc5b5f0d35b150b87619b	.rar	2020-05-28 16:16:58.363	1	1
109	default.conf	/uploads/upload_2dc54c05df5eeda4d5b6f2b03e754f22	.conf	2020-05-29 01:05:41.008	2	1
110	default.conf	/uploads/upload_2d00f3a5a8059ee44ba5f1c1216606dc	.conf	2020-05-29 01:05:42.371	2	1
113	Новый текстовый документ.txt	/uploads/upload_0ab10a5d8eaf9f3df367a0b3c299174c	.txt	2020-05-29 18:37:22.624	1	1
114	Новый текстовый документ.txt	/uploads/upload_f2e330f6b200c083c45ebcf378e15200	.txt	2020-05-29 18:47:10.561	1	1
115	Новый текстовый документ.txt	/uploads/upload_f9f4893523664d59d0b2fe09801e2c26	.txt	2020-05-29 18:51:03.434	1	1
116	тестовая нагрузка.xls	/uploads/upload_04c1b4c2f6a8ea051db69747eeacc0c7	.xls	2020-05-29 21:41:00.429	1	1
\.


--
-- Data for Name: files_projects; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_projects (id, name, path, ext, modified_date, teacher_id, sub_unit_id, project_id) FROM stdin;
\.


--
-- Data for Name: files_rpd; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.files_rpd (id, name, path, ext, modified_date, teacher_id, sub_unit_id, discipline_id) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.groups (id, specialties_id, name) FROM stdin;
1	2	161-342
102	2	161-341
103	2	161-351
104	2	191-321
105	2	191-322
106	2	191-362
107	2	191-361
108	2	181-321
109	2	181-322
110	2	181-324
111	2	181-325
112	2	181-326
113	2	171-371
114	2	171-372
115	2	171-331
116	2	171-332
117	2	181-361
118	2	181-362
119	2	19А-311
120	2	151-311
121	2	184-322
122	2	191-351
123	2	161-721
124	2	171-362
125	2	181-142
126	2	181-311
127	2	184-342
130	2	181-323
131	2	191-311
132	2	161-321
133	2	161-322
134	2	161-331
141	2	171-334
142	2	171-335
145	2	17А-312
157	2	184-321
160	2	18А-312
164	2	191-323
165	2	191-324
166	2	191-325
167	2	191-331
169	2	191-352
172	2	194-321
173	2	194-322
175	2	171-333
178	2	171-361
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
54	Антон	Толстиков	Витальевич	\N	8(800)555-3535	tolstikov@mail.ru	2
55	Анастасия	Ковалева	Александровна	\N	8(800)555-3535	kovaleva@mail.ru	2
57	Виктор	Лянг	Федорович	\N	8(800)555-3535	lyang@mail.ru	2
56	Андрей	Джунковский	Владимирович	\N	8(800)555-3535	djunkovski@mail.ru	2
101	Игорь	Степаненко	Сергеевич	1998-03-06 00:00:00	8(800)555-36-36	stepanenko@yandex.ru	2
102	Алина	Борзикова	Александровна	2020-05-03 00:00:00	8(800)555-35-35	borz@mail.ru	2
103	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_1@mail.ru	1
104	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_2@mail.ru	1
105	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_3@mail.ru	1
106	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_4@mail.ru	1
107	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_5@mail.ru	1
108	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_6@mail.ru	1
109	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_7@mail.ru	1
110	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_8@mail.ru	1
111	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_9@mail.ru	1
112	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_10@mail.ru	1
113	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_11@mail.ru	1
114	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mail_12@mail.ru	1
115	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_1@mail.ru	1
116	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_2@mail.ru	1
117	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_3@mail.ru	1
118	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_4@mail.ru	1
119	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_5@mail.ru	1
120	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_6@mail.ru	1
121	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_7@mail.ru	1
122	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_8@mail.ru	1
123	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_9@mail.ru	1
124	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_10@mail.ru	1
125	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_11@mail.ru	1
126	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_12@mail.ru	1
127	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_13@mail.ru	1
128	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_14@mail.ru	1
129	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_maill_15@mail.ru	1
130	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_1@mail.ru	1
131	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_2@mail.ru	1
132	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_3@mail.ru	1
133	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_4@mail.ru	1
134	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_5@mail.ru	1
135	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_6@mail.ru	1
136	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_7@mail.ru	1
137	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_8@mail.ru	1
138	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_9@mail.ru	1
139	Игорь	Tremaskin	Vladimirovich	2020-04-09 00:00:00	8(926)213-12-33	my_mailll_10@mail.ru	1
140	Антон	Толстиков	Витальевич	1998-06-03 00:00:00	+7-915-173-28-48	temonavto997@yandex.ru	1
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.projects (id, name, description, begin_date, end_date, link_trello, sub_unit_id, teacher_id) FROM stdin;
1	Лодка	Описание лодки	2016-09-01 00:00:00	2016-09-01 00:00:00	asd	1	1
100	Космический корабль	Будут летать на луну	2020-05-29 00:00:00	2021-06-25 00:00:00	trello.com/id485677	1	100
101	Учебный курс Inventor	Создаётся учебный курс по inventor	2020-05-01 00:00:00	2020-05-27 00:00:00	trello/inventor	1	100
102	Аналитическая панель	asdasdasd	2020-05-02 00:00:00	2020-05-31 00:00:00	asdasd	1	101
2	Самолет	Описание самолета	2016-08-31 00:00:00	2021-08-31 00:00:00	asdasd	1	2
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
1	2	1	1
2	4	1	1
3	2	2	1
4	3	2	1
5	2	3	1
6	2	4	1
7	1	5	1
100	4	100	1
101	4	101	1
\.


--
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.specialties (id, code, name, profile, educ_form, educ_programm, educ_years, year_join, sub_unit_id) FROM stdin;
2	09.03.01	Информатика и вычислительная техника	Интеграция и программирование в САПР	Очная	1	4	2016-09-01 00:00:00	1
100	09.03.011	Веб-технологии	ВЕБ	очная	1	4	2019-09-01 09:00:00	1
101	01.011.100	Маги и волшебники	Огненная магия	Заочная	1	4	2017-05-05 00:00:00	1
102	01.09.06	Разработка двигателей	САПР	Очно-заочная	1	4	2017-05-28 00:00:00	1
103	02.02.03	Программирование плат	Платы для чипирования Россиян	Очная	1	4	2020-04-18 00:00:00	1
104	92.04.88	Машиностроение	Строение тяжелых белазов	Очно-заочная	1	4	2017-05-14 00:00:00	1
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
100	103	115
101	104	115
102	105	115
103	106	115
104	107	115
105	108	115
106	109	115
107	110	115
108	111	115
109	112	115
110	113	115
111	114	115
112	115	116
113	116	116
114	117	116
115	118	116
116	119	116
117	120	116
118	121	116
119	122	116
120	123	116
121	124	116
122	125	116
123	126	116
124	127	116
125	128	116
126	129	116
127	130	178
128	131	178
129	132	178
130	133	178
131	134	178
132	135	178
133	136	178
134	137	178
135	138	178
136	139	178
137	140	175
\.


--
-- Data for Name: students_projects; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.students_projects (id, student_id, project_id, date) FROM stdin;
1	1	1	2016-09-01
2	2	2	2016-09-01
100	3	1	2020-05-29
101	5	1	2020-05-29
102	3	100	2020-05-29
103	5	100	2020-05-29
104	129	1	2020-06-02
105	130	1	2020-06-02
106	127	1	2020-06-02
107	128	1	2020-06-02
108	129	1	2020-06-02
109	136	100	2020-06-02
110	135	100	2020-06-02
\.


--
-- Data for Name: sub_unit; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.sub_unit (id, name, department_id) FROM stdin;
1	САПР	1
2	ВЕБ	1
3	КИС	1
4	Дашборд	2
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: diplom_user
--

COPY public.teachers (id, person_id, "position", rank_id, degree_id, rate, hours_worked, rinc, web_of_science, scopus, login, password, salt) FROM stdin;
1	53	Преподаватель	\N	\N	\N	\N	\N	\N	\N	holodov	$2b$12$WJPfMpLjWz/fRtn21qiy4eyuprgS2YCNSmlUmwOdjZHUjVq33Q7Hi	$2b$12$WJPfMpLjWz/fRtn21qiy4e
2	54	Преподаватель	\N	\N	\N	\N	\N	\N	\N	tolstikov	$2b$12$H2FY2xgNEANnRv69.gXSruq35I50F6wm5OslvDN0uFk.ky09wJ/MW	$2b$12$H2FY2xgNEANnRv69.gXSru
3	55	Преподаватель	\N	\N	\N	\N	\N	\N	\N	kovaleva	$2b$12$IH8kIKTXrM3UXyDs1JyFOe3.oBjDWnAo2zMVO2Q0MLR8hINLEH7wm	$2b$12$IH8kIKTXrM3UXyDs1JyFOe
4	56	Преподаватель	\N	\N	\N	\N	\N	\N	\N	djunkovski	$2b$12$Qh.8rPRjF.eYOiGPo6F.ReKE32vdJmHdvifhQTvxzKTv.8ycU73IC	$2b$12$Qh.8rPRjF.eYOiGPo6F.Re
5	57	Преподаватель	\N	\N	\N	\N	\N	\N	\N	lyang	$2b$12$S6ARaLllzdaHhpMPLTvn8uU9ycBlW92zxuO.R1ImCULrMoWkqyn0u	$2b$12$S6ARaLllzdaHhpMPLTvn8u
100	101	Преподаватель	\N	\N	0.25	300	0.100000001	0.100000001	0.100000001	stepanenko	$2b$12$Zuvnt/BSEvowit3q0Cz6aeYeLbTFG6Ry9YPSRjxcdcsbNQV38Urwi	$2b$12$Zuvnt/BSEvowit3q0Cz6ae
101	102	Преподаватель	\N	\N	0.25	300	0.100000001	0.100000001	0.100000001	borz	$2b$12$4DuF0NnGmKZzKJTbCnuGh.K1C/SMNjvlvFuvEkQD8uPvnDRulUUQK	$2b$12$4DuF0NnGmKZzKJTbCnuGh.
\.


--
-- Name: acad_block_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_block_id_seq', 394, true);


--
-- Name: acad_discipline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_discipline_id_seq', 394, true);


--
-- Name: acad_module_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_module_id_seq', 394, true);


--
-- Name: acad_part_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_part_id_seq', 394, true);


--
-- Name: acad_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.acad_plan_id_seq', 110, true);


--
-- Name: degree_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.degree_id_seq', 100, false);


--
-- Name: dep_load_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.dep_load_id_seq', 121, true);


--
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.department_id_seq', 100, true);


--
-- Name: disciplines_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.disciplines_groups_id_seq', 344, true);


--
-- Name: disciplines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.disciplines_id_seq', 530, true);


--
-- Name: disciplines_teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.disciplines_teachers_id_seq', 103, true);


--
-- Name: files_acad_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_acad_plan_id_seq', 101, true);


--
-- Name: files_dep_load_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_dep_load_id_seq', 101, true);


--
-- Name: files_ind_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_ind_plan_id_seq', 116, true);


--
-- Name: files_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_projects_id_seq', 100, false);


--
-- Name: files_rpd_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.files_rpd_id_seq', 100, false);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.groups_id_seq', 179, true);


--
-- Name: personalities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.personalities_id_seq', 140, true);


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

SELECT pg_catalog.setval('public.specialties_id_seq', 104, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.students_id_seq', 137, true);


--
-- Name: students_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.students_projects_id_seq', 110, true);


--
-- Name: sub_unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.sub_unit_id_seq', 100, false);


--
-- Name: teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diplom_user
--

SELECT pg_catalog.setval('public.teachers_id_seq', 101, true);


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
    ADD CONSTRAINT acad_discipline_acad_plan_id_fkey FOREIGN KEY (acad_plan_id) REFERENCES public.acad_plan(id);


--
-- Name: acad_plan acad_plan_specialties_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.acad_plan
    ADD CONSTRAINT acad_plan_specialties_id_fkey FOREIGN KEY (specialties_id) REFERENCES public.specialties(id);


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
    ADD CONSTRAINT disciplines_dep_load_id_fkey FOREIGN KEY (dep_load_id) REFERENCES public.dep_load(id);


--
-- Name: disciplines_groups disciplines_groups_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_groups
    ADD CONSTRAINT disciplines_groups_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.disciplines(id);


--
-- Name: disciplines_groups disciplines_groups_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_groups
    ADD CONSTRAINT disciplines_groups_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: disciplines_teachers disciplines_teachers_discipline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_teachers
    ADD CONSTRAINT disciplines_teachers_discipline_id_fkey FOREIGN KEY (discipline_id) REFERENCES public.disciplines(id);


--
-- Name: disciplines_teachers disciplines_teachers_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.disciplines_teachers
    ADD CONSTRAINT disciplines_teachers_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- Name: files_acad_plan files_acad_plan_acad_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan
    ADD CONSTRAINT files_acad_plan_acad_plan_id_fkey FOREIGN KEY (acad_plan_id) REFERENCES public.acad_plan(id);


--
-- Name: files_acad_plan files_acad_plan_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan
    ADD CONSTRAINT files_acad_plan_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_acad_plan files_acad_plan_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_acad_plan
    ADD CONSTRAINT files_acad_plan_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- Name: files_dep_load files_dep_load_dep_load_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load
    ADD CONSTRAINT files_dep_load_dep_load_id_fkey FOREIGN KEY (dep_load_id) REFERENCES public.dep_load(id);


--
-- Name: files_dep_load files_dep_load_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load
    ADD CONSTRAINT files_dep_load_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_dep_load files_dep_load_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_dep_load
    ADD CONSTRAINT files_dep_load_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- Name: files_ind_plan files_ind_plan_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_ind_plan
    ADD CONSTRAINT files_ind_plan_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_ind_plan files_ind_plan_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_ind_plan
    ADD CONSTRAINT files_ind_plan_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- Name: files_projects files_projects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects
    ADD CONSTRAINT files_projects_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: files_projects files_projects_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects
    ADD CONSTRAINT files_projects_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: files_projects files_projects_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.files_projects
    ADD CONSTRAINT files_projects_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


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
    ADD CONSTRAINT files_rpd_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- Name: groups groups_specialties_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_specialties_id_fkey FOREIGN KEY (specialties_id) REFERENCES public.specialties(id);


--
-- Name: projects projects_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: projects projects_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- Name: rights_roles rights_roles_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.rights_roles
    ADD CONSTRAINT rights_roles_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: rights_roles rights_roles_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.rights_roles
    ADD CONSTRAINT rights_roles_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.teachers(id);


--
-- Name: specialties specialties_sub_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_sub_unit_id_fkey FOREIGN KEY (sub_unit_id) REFERENCES public.sub_unit(id);


--
-- Name: students students_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- Name: students students_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.personalities(id);


--
-- Name: students_projects students_projects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students_projects
    ADD CONSTRAINT students_projects_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: students_projects students_projects_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diplom_user
--

ALTER TABLE ONLY public.students_projects
    ADD CONSTRAINT students_projects_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id);


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

