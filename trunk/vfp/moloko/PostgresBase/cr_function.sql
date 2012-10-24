--pg_stat_get_backend_activity(int4) 'Statistics: Current query of backend'
--pg_stat_get_backend_activity_start(int4) 'Statistics: Start time for current query of backend'
--pg_stat_get_backend_client_addr(int4) 'Statistics: Address of client connected to backend'
--pg_stat_get_backend_client_port(int4) 'Statistics: Port number of client connected to backend'
--pg_stat_get_backend_pid(int4) 'Statistics: PID of backend'
--pg_stat_get_backend_idset() 'Statistics: Currently active backend IDs'
--pg_stat_get_db_numbackends(oid) 'Statistics: Number of backends in database'
SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: Lock_Object
--Блокировать объект
--DROP FUNCTION work_schema.Lock_Object()

CREATE OR REPLACE FUNCTION work_schema.Lock_Object(_ID_Session work_schema.Sessions.ID%TYPE,
												   _Name_Object VARCHAR(100), 
												   _ID_Row INT4)
  RETURNS BOOL AS $$
DECLARE
	_IDObj work_schema.Dict_Objects.ID%TYPE;
	_Exists BOOL;
	_userid work_schema.Dict_Users.ID%TYPE;
BEGIN
	_userid := work_schema.get_userid();

	IF _userid IS NOT NULL THEN
		SELECT ID INTO _IDObj
		FROM work_schema.Dict_Objects
		WHERE NAME = _Name_Object;

		IF FOUND THEN
			INSERT INTO work_schema.Lock_Objects (ID_Object, ID_Session, ID_User, ID_Row, Status)
										  VALUES (_IDObj, _ID_Session, _userid, _ID_Row, 'L')
		END IF;
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT VOLATILE SECURITY DEFINER;

COMMENT ON FUNCTION work_schema.Lock_Object() IS 'Заблокировать объект';

-- Function: List_Login_Users
--Список подключенных пользователей

