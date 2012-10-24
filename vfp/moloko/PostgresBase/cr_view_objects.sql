SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- View: work_schema.View_Objects
--DROP VIEW work_schema.View_Objects;

CREATE OR REPLACE VIEW work_schema.View_Objects AS
    SELECT lobj.ID AS LID, lobj.PID, lobj.SORTID, lobj.LEVEL, lobj.CHLCNT, lobj.ID_TABLE, dobj.*
    FROM work_schema.Link_Objects AS lobj JOIN work_schema.Dict_Objects AS dobj ON dobj.ID = lobj.ID_Dict
    WHERE work_schema.acl_check('Справочник объектов', 'V', lobj.PID);

ALTER TABLE work_schema.View_Objects OWNER TO admin_user;
GRANT ALL ON TABLE work_schema.View_Objects TO manager_data WITH GRANT OPTION;
GRANT ALL ON TABLE work_schema.View_Objects TO worker_data WITH GRANT OPTION;
