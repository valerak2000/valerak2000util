SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- View: work_schema.View_Users
--DROP VIEW work_schema.View_Users;

CREATE OR REPLACE VIEW work_schema.View_Users AS
    SELECT lu.ID AS LID, lu.PID, lu.SORTID, lu.LEVEL, lu.CHLCNT, lu.ID_TABLE, du.*
    FROM work_schema.Link_Users AS lu JOIN work_schema.Dict_Users AS du ON du.ID = lu.ID_Dict
    WHERE work_schema.acl_check('Справочник пользователей', 'V', lu.PID);

ALTER TABLE work_schema.View_Users OWNER TO admin_user;
GRANT ALL ON TABLE work_schema.View_Users TO manager_data WITH GRANT OPTION;
GRANT ALL ON TABLE work_schema.View_Users TO worker_data WITH GRANT OPTION;
