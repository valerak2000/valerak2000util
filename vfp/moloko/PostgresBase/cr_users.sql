SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;
SET search_path = public, public;
SET default_with_oids = false;

--DROP ROLE admin_user;
CREATE ROLE admin_user LOGIN
  PASSWORD '1234'
  SUPERUSER INHERIT NOCREATEDB NOCREATEROLE;


--users
--DROP ROLE list_users;
CREATE ROLE list_users LOGIN
  PASSWORD '1234'
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

--DROP ROLE manager_data;
CREATE ROLE manager_data
  CREATEDB CREATEROLE
   VALID UNTIL 'infinity';

--DROP ROLE worker_data;
CREATE ROLE worker_data
   VALID UNTIL 'infinity';

GRANT manager_data TO admin_user;
GRANT worker_data TO admin_user;

--DROP ROLE work_user1;
CREATE ROLE work_user1 LOGIN
  PASSWORD '1234'
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

GRANT worker_data TO work_user1;
