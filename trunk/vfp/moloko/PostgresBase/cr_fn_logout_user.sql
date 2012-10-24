SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.logout_user()
--DROP FUNCTION work_schema.logout_user(INTEGER);

CREATE OR REPLACE FUNCTION work_schema.logout_user(IN INTEGER)
  RETURNS BOOL AS $$
BEGIN
	--пометить сессию как удачно завершившуюс€
	UPDATE work_schema.Sessions SET Session_OFF = now(), Status = 'C'
	WHERE ID = $1;

	IF FOUND THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT SECURITY DEFINER;

ALTER FUNCTION work_schema.logout_user(INTEGER) OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.logout_user(INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.logout_user(INTEGER) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.logout_user(INTEGER) TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.logout_user(INTEGER) IS '«апись информации о закрытии сессии пользовател€';
