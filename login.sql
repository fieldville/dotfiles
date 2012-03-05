-- set heading off
-- set timing on
set colsep ' '
set trimout on
set trimspool on
set time on
set wrap off
set linesize 2000
set pagesize 50
set autoprint on
set serveroutput on
set underline off
set null '<null>'

set termout off
column sid0 new_value sid1
column user new_value uid1
select user from dual;
select rtrim(instance_name, chr(0)) sid0 from v$instance;
set termout on

set sqlprompt '&uid1@&sid1> '
