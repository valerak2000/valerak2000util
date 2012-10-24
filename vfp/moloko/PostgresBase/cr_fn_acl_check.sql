SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.acl_check
--проверяется уровень доступа на групповой объект, поскольку возможно их будет меньше
--DROP FUNCTION work_schema.acl_check(VARCHAR(100), CHAR(4), INTEGER);

CREATE OR REPLACE FUNCTION work_schema.acl_check(IN VARCHAR(100), IN CHAR(4), IN INTEGER)
  RETURNS BOOL AS $$
DECLARE
	_objectid INTEGER;
	_userid INTEGER;
	_Rights CHAR(4);
	_Inherits_Rights CHAR(4);
	_Access BOOL;
BEGIN
	_Access := pg_has_role(session_user, 'manager_data', 'usage');

	IF NOT _Access THEN
		_userid := work_schema.get_userid();

		SELECT ID INTO _objectid
		FROM work_schema.Dict_Objects
		WHERE NAME = $1
		LIMIT 1;

		IF FOUND THEN
			SELECT Rights, Inherits_Rights INTO _Rights, _Inherits_Rights
			FROM work_schema.User_Rights
			WHERE ID_Object = _objectid AND ID_User = _userid;

			IF FOUND AND (_Rights ~ $2 OR (_Inherits_Rights ~ $2
										   AND _Rights !~ 'X')) THEN
				_Access := TRUE;
			END IF;
		END IF;
	END IF;

	RETURN _Access;
END;
$$ LANGUAGE 'plpgsql' STABLE SECURITY DEFINER;

ALTER FUNCTION work_schema.acl_check(VARCHAR(100), CHAR(4), INTEGER) OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.acl_check(VARCHAR(100), CHAR(4), INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.acl_check(VARCHAR(100), CHAR(4), INTEGER) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.acl_check(VARCHAR(100), CHAR(4), INTEGER) TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.acl_check(VARCHAR(100), CHAR(4), INTEGER) IS 'Проверка уровня доступа на объект';
