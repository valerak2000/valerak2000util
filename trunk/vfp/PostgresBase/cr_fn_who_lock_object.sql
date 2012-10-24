SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: Lock_Object
--DROP FUNCTION work_schema.Who_Lock_Object(TEXT, INTEGER);

CREATE OR REPLACE FUNCTION work_schema.Who_Lock_Object(IN _Name_Object TEXT, 
												   IN _ID_Row INTEGER,
												   OUT ID_Session INTEGER,
												   OUT ID_User INTEGER,
												   OUT NAME_User VARCHAR(100))
  RETURNS SETOF RECORD AS $$
DECLARE
	_id_obj INTEGER;
	_row_lock work_schema.Lock_Objects%ROWTYPE;
BEGIN
	SELECT ID INTO _id_obj
	FROM work_schema.Dict_Objects
	WHERE NAME = _Name_Object;

	IF FOUND THEN
		FOR _row_lock IN SELECT *
						 FROM work_schema.Lock_Objects
						 WHERE ID_Object = _id_obj AND ID_Row = _ID_Row
						 	   AND Status = 'L'
		LOOP
			ID_Session := _row_lock.ID_Session;
			ID_User := _row_lock.ID_User;
			NAME_User := (SELECT NAME
						  FROM work_schema.Dict_Users
						  WHERE ID = _row_lock.ID_User
						  LIMIT 1);

			RETURN NEXT;
		END LOOP;
	END IF;
END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT STABLE SECURITY DEFINER;

ALTER FUNCTION work_schema.Who_Lock_Object(TEXT, INTEGER) OWNER TO admin_user;
GRANT EXECUTE ON FUNCTION work_schema.Who_Lock_Object(TEXT, INTEGER) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.Who_Lock_Object(TEXT, INTEGER) TO worker_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.Who_Lock_Object(TEXT, INTEGER) TO list_users WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.Who_Lock_Object(TEXT, INTEGER) IS 'Кто заблокировал объект?';
