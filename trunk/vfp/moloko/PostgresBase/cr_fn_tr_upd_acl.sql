SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Trigger work_schema.tr_upd_acl
--DROP TRIGGER tr_upd_acl ON work_schema.User_Rights CASCADE;

CREATE TRIGGER tr_upd_acl
  BEFORE INSERT OR UPDATE OR DELETE
  ON work_schema.User_Rights
  FOR EACH ROW EXECUTE PROCEDURE work_schema.update_acl();
