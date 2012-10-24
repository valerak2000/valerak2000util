SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.get_acl
--DROP FUNCTION work_schema.get_acl(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION work_schema.get_acl(_ID_User INTEGER, _ID_Object INTEGER)
  RETURNS TEXT AS $$
DECLARE
	_recusr RECORD;
	_recobj RECORD;
	_stracl TEXT := '';
	_Rights work_schema.User_Rights.Rights%TYPE;
	_IRights work_schema.User_Rights.Inherits_Rights%TYPE;
	_Path_User Public.LTREE;
	_Path_Object Public.LTREE;
	_CntRep INTEGER;
	_I INTEGER;
BEGIN
	_stracl := '';

	FOR _recusr IN SELECT PATH
				   FROM work_schema.Link_Users
				   WHERE ID_Dict = _ID_User
	LOOP
		_Path_User := _recusr.PATH;

		_I := 1;
		_CntRep := Public.nlevel(_Path_User) - 1;

		WHILE _I<=_CntRep LOOP
		--просмотреть права на объект всех предков пользователя
			SELECT Rights, Inherits_Rights INTO _Rights, _IRights
			FROM work_schema.User_Rights
			WHERE ID_User = Public.subpath(_Path_User, -_I, 1)
				  AND ID_Object = _ID_Object;

			IF FOUND THEN
				IF _Rights IS NOT NULL THEN
				 	_stracl := _stracl || _Rights;
			 	END IF;

			 	IF _IRights IS NOT NULL THEN
	 				_stracl := _stracl || _IRights;
 				END IF;

 				_stracl := _stracl || ',';

 				EXIT;
			END IF;

			_I := _I + 1;
		END LOOP;
	END LOOP;

	FOR _recobj IN SELECT PATH
				   FROM work_schema.Link_Objects
				   WHERE ID_Dict = _ID_Object
	LOOP
		_Path_Object := _recobj.PATH;

		_I := 1;
		_CntRep := Public.nlevel(_Path_Object) - 1;

		WHILE _I <= _CntRep LOOP
		--просмотреть права на объект всех предков объекта
			SELECT Rights, Inherits_Rights INTO _Rights, _IRights
			FROM work_schema.User_Rights
			WHERE ID_User = _ID_User AND ID_Object = Public.subpath(_Path_Object, -_I, 1);

			IF FOUND THEN
				IF _Rights IS NOT NULL THEN
				 	_stracl := _stracl || _Rights;
			 	END IF;

			 	IF _IRights IS NOT NULL THEN
	 				_stracl := _stracl || _IRights;
	 			END IF;

	 			_stracl := _stracl || ',';

 				EXIT;
			END IF;

			_I := _I + 1;
		END LOOP;
	END LOOP;

	RETURN _stracl;
END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT STABLE SECURITY DEFINER;

ALTER FUNCTION work_schema.get_acl(INTEGER, INTEGER) OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.get_acl(INTEGER, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.get_acl(INTEGER, INTEGER) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.get_acl(INTEGER, INTEGER) TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.get_acl(INTEGER, INTEGER) IS 'Список доступных прав пользователя на объект';
