SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: Lock_Object
--DROP FUNCTION work_schema.Lock_Object(INTEGER, VARCHAR(100), INTEGER)

CREATE OR REPLACE FUNCTION work_schema.Lock_Object(_ID_Session INTEGER,
												   _Name_Object VARCHAR(100), 
												   _ID_Row INTEGER)
  RETURNS INTEGER AS $$
DECLARE
	_id_obj INTEGER;
	_userid INTEGER;
	_id_lock INTEGER;
BEGIN
	_userid := work_schema.get_userid();

	IF _userid IS NOT NULL THEN
		SELECT ID INTO _id_obj
		FROM work_schema.Dict_Objects
		WHERE NAME = _Name_Object
		LIMIT 1;

		IF FOUND THEN
			IF NOT EXISTS(SELECT ID
						  FROM work_schema.Lock_Objects
						  WHERE ID_Object = _id_obj AND ID_Row = _ID_Row
						  	    AND Status = 'L') THEN
				_id_lock := nextval('work_schema.Lock_Objects_id_seq'::regclass);

				INSERT INTO work_schema.Lock_Objects (ID, ID_Object, ID_Session,
													  ID_User, ID_Row, Status)
											  VALUES (_id_lock, _id_obj, _ID_Session,
											          _userid, _ID_Row, 'L');

				RETURN _id_lock;
			END IF;
		END IF;
	END IF;

	RETURN -1;
END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT VOLATILE SECURITY DEFINER;

ALTER FUNCTION work_schema.Lock_Object(INTEGER, VARCHAR(100), INTEGER) OWNER TO admin_user;
GRANT EXECUTE ON FUNCTION work_schema.Lock_Object(INTEGER, VARCHAR(100), INTEGER) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.Lock_Object(INTEGER, VARCHAR(100), INTEGER) TO worker_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.Lock_Object(INTEGER, VARCHAR(100), INTEGER) TO list_users WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.Lock_Object(INTEGER, VARCHAR(100), INTEGER) IS 'Заблокировать объект';
