SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

CREATE OR REPLACE FUNCTION work_schema.update_acl()
  RETURNS "trigger" AS $$
DECLARE
	_stracl TEXT;
	_Rights CHAR(4);
	_IRights CHAR(4);
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		_stracl := work_schema.get_acl(NEW.ID_User, NEW.ID_Object);

		IF _stracl ~ '(V|I|U|D)' THEN
			NEW.Inherits_Rights := '';

			IF _stracl ~ 'V' THEN
				NEW.Inherits_Rights := 'V';
			END IF;

			IF _stracl ~ 'I' THEN
				NEW.Inherits_Rights := NEW.Inherits_Rights || 'I';
			END IF;

			IF _stracl ~ 'U' THEN
				NEW.Inherits_Rights := NEW.Inherits_Rights || 'U';
			END IF;

			IF _stracl ~ 'D' THEN
				NEW.Inherits_Rights := NEW.Inherits_Rights || 'D';
			END IF;
		ELSE
			NEW.Inherits_Rights := NULL;
		END IF;
		--изменить наследуемые права с NEW.ID_User для всех детей NEW.ID_Object
		UPDATE work_schema.User_Rights SET Inherits_Rights = Inherits_Rights
		FROM (SELECT ID
			  FROM work_schema.Link_Objects
			  WHERE PID = NEW.ID_Object) AS lobj
		WHERE ID_User = NEW.ID_User AND ID_Object = lobj.ID;
		--изменить наследуемые права с NEW.ID_Object для всех детей NEW.ID_User
		UPDATE work_schema.User_Rights SET Inherits_Rights = Inherits_Rights
		FROM (SELECT ID
			  FROM work_schema.Link_Users
			  WHERE PID = NEW.ID_User) AS lusr
		WHERE ID_User = lusr.ID AND ID_Object = NEW.ID_Object;

		RETURN NEW;
	ELSEIF TG_OP = 'DELETE' THEN
		--изменить наследуемые права с OLD.ID_User для всех детей OLD.ID_Object
		UPDATE work_schema.User_Rights SET Inherits_Rights = Inherits_Rights
		FROM (SELECT ID
			  FROM work_schema.Link_Objects
			  WHERE PID = OLD.ID_Object) AS lobj
		WHERE ID_User = OLD.ID_User AND ID_Object=lobj.ID;
		--изменить наследуемые права с OLD.ID_Object для всех детей OLD.ID_User
		UPDATE work_schema.User_Rights SET Inherits_Rights = Inherits_Rights
		FROM (SELECT ID
			  FROM work_schema.Link_Users
			  WHERE PID = OLD.ID_User) AS lusr
		WHERE ID_User = lusr.ID AND ID_Object = OLD.ID_Object;

		RETURN OLD;
	END IF;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

COMMENT ON FUNCTION work_schema.update_acl() IS 'Обновить наследуемые права';
