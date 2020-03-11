--truncate table semestr restart identity;

--alter sequence semestr_id_seq restart with 1;

--select table_name from information_schema."tables" where table_schema = 'public' ;

TRUNCATE TABLE 
files_acad_plan,
acad_block,
acad_part,
acad_module,
acad_plan,
discipline,
ranks,
personalities,
degree,
files_ind_plan,
teachers,
files_rpd,
department,
rights_roles,
sub_unit,
dep_load,
dis_load,
project_activities,
specialties,
files_proj_act,
groups,
students,
stud_on_proj
RESTART identity;
