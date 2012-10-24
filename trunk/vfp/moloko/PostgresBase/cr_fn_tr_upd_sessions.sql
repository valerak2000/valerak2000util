SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Function: work_schema.upd_Sessions
--DROP FUNCTION work_schema.upd_Sessions();

CREATE OR REPLACE FUNCTION work_schema.upd_Sessions()
  RETURNS "trigger" AS $$
BEGIN
	IF NEW.Status IN ('C', 'D') THEN
		--сбросить все блокировки сессии
		UPDATE work_schema.Lock_Objects SET Status = 'U', Lock_Off = now()
		WHERE ID_Session = NEW.ID AND Status = 'L';
		--отменить все сообщения к данной сессии
		UPDATE work_schema.Messages SET Status = 'N', Time_Read = now()
		WHERE ID_Session_To = NEW.ID AND Status = 'L';
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

ALTER FUNCTION work_schema.upd_Sessions() OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.upd_Sessions() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.upd_Sessions() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.upd_Sessions() TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.upd_Sessions() IS 'Действия после изменения сессии';

-- Trigger: work_schema.tr_upd_Sessions
--DROP TRIGGER tr_upd_Sessions ON work_schema.Sessions;

CREATE TRIGGER tr_upd_Sessions
  AFTER UPDATE
  ON work_schema.Sessions
  FOR EACH ROW EXECUTE PROCEDURE work_schema.upd_Sessions();
 