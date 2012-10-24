SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.get_messages_to()
--DROP FUNCTION work_schema.get_messages_to(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION work_schema.get_messages_to(IN INTEGER, IN CHAR)
  RETURNS SETOF work_schema.Messages AS $$
DECLARE
	_msg_row work_schema.Messages%ROWTYPE;
	_userid INTEGER;
BEGIN
	_userid := work_schema.get_userid();

	FOR _msg_row IN SELECT *
					FROM work_schema.Messages
					WHERE ID_Session_To = $1 AND Status = $2
	LOOP
		IF _userid = (SELECT ID_User FROM work_schema.Sessions WHERE ID=$1) THEN
		--отдать только сообщени€ направленные текущему пользователю
			IF _msg_row.Status = 'L' THEN
				UPDATE work_schema.Messages SET Status = 'R', Time_Read = now()
				WHERE ID = _msg_row.ID;
			END IF;

			RETURN NEXT _msg_row;
		END IF;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT SECURITY DEFINER;

ALTER FUNCTION work_schema.get_messages_to(INTEGER, CHAR) OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.get_messages_to(INTEGER, CHAR) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.get_messages_to(INTEGER, CHAR) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.get_messages_to(INTEGER, CHAR) TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.get_messages_to(INTEGER, CHAR) IS '—писок сообщений дл€ сесии';
