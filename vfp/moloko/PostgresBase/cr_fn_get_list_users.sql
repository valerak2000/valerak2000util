SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.get_list_users()
--DROP FUNCTION work_schema.get_list_users();

CREATE OR REPLACE FUNCTION work_schema.get_list_users(OUT Full_name Dict_Users.NAME%TYPE, OUT System_name NAME)
  RETURNS SETOF RECORD AS
$BODY$
	SELECT Dict_Users.NAME, Dict_Users.System_Name
	FROM work_schema.Dict_Users
	WHERE System_OID IS NOT NULL AND CanLogin
	ORDER BY 1
$BODY$ LANGUAGE 'sql' STABLE SECURITY DEFINER;

ALTER FUNCTION work_schema.get_list_users() OWNER TO admin_user;
GRANT EXECUTE ON FUNCTION work_schema.get_list_users() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.get_list_users() TO worker_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.get_list_users() TO list_users WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.get_list_users() IS 'Список активных пользователей';
