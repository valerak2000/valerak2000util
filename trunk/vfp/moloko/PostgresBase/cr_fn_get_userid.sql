SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.get_userid()
--DROP FUNCTION work_schema.get_userid();

CREATE OR REPLACE FUNCTION work_schema.get_userid()
  RETURNS INT4 AS $$
DECLARE
	_userid INT4;
BEGIN
	SELECT Dict_Users.ID INTO _userid
	FROM work_schema.Dict_Users 
	WHERE System_Name = session_user AND CanLogin
	LIMIT 1;

	RETURN _userid;
END;
$$ LANGUAGE 'plpgsql' STABLE SECURITY DEFINER;

ALTER FUNCTION work_schema.get_userid() OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.get_userid() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.get_userid() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.get_userid() TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.get_userid() IS 'ID пользователя текущей сессии';
