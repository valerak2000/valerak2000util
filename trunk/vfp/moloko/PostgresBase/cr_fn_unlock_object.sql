SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: Unlock_Object
--DROP FUNCTION work_schema.UnLock_Object(INTEGER)

CREATE OR REPLACE FUNCTION work_schema.UnLock_Object(_ID_Lock INTEGER)
  RETURNS BOOL AS $$
DECLARE
BEGIN
	UPDATE work_schema.Lock_Objects SET Status = 'U', Lock_Off = now()
	WHERE ID = _ID_Lock;

	IF FOUND THEN
		RETURN TRUE;
	END IF;

	RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT VOLATILE SECURITY DEFINER;

ALTER FUNCTION work_schema.UnLock_Object(INTEGER) OWNER TO admin_user;
GRANT EXECUTE ON FUNCTION work_schema.UnLock_Object(INTEGER) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.UnLock_Object(INTEGER) TO worker_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.UnLock_Object(INTEGER) TO list_users WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.UnLock_Object(INTEGER) IS 'Разблокировать объект';
