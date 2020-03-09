--truncate table semestr restart identity;

--alter sequence semestr_id_seq restart with 1;

--select table_name from information_schema."tables" where table_schema = 'public' ;

TRUNCATE TABLE 
discip_blocks,
semestr,
discip_modules,
disciplines,
academic_plan,
blocks_for_acad_plan,
discip_optional,
files_acad_plan,
personalities,
teachers,
ranks,
degree,
files_ind_plan,
files_proj_act,
files_rpd,
department,
sub_unit,
rights_roles,
specialties,
disciplines_year,
project_activities,
groups,
students,
stud_on_proj
RESTART identity;
