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
$$