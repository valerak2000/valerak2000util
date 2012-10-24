SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: List_Lock_Objects
--DROP FUNCTION work_schema.List_Lock_Objects()

CREATE OR REPLACE FUNCTION work_schema.List_Lock_Objects()
  RETURNS SETOF work_schema.Lock_Objects AS
$BODY$
	SELECT *
	FROM work_schema.Lock_Objects
	WHERE Status = 'L'
$BODY$ LANGUAGE 'sql' STABLE SECURITY DEFINER;

ALTER FUNCTION work_schema.List_Lock_Objects() OWNER TO admin_user;
GRANT EXECUTE ON FUNCTION work_schema.List_Lock_Objects() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.List_Lock_Objects() TO worker_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.List_Lock_Objects() TO list_users WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.List_Lock_Objects() IS 'Список заблокированных объектов';
