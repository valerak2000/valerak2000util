SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;

-- Schema: "work_schema"
-- DROP SCHEMA work_schema;

CREATE SCHEMA work_schema
  AUTHORIZATION admin_user;

GRANT ALL ON SCHEMA work_schema TO admin_user;
GRANT USAGE ON SCHEMA work_schema TO list_users WITH GRANT OPTION;
GRANT ALL ON SCHEMA work_schema TO manager_data WITH GRANT OPTION;
GRANT USAGE ON SCHEMA work_schema TO worker_data WITH GRANT OPTION;
