SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.send_user_messages()
--DROP FUNCTION work_schema.send_user_messages(INTEGER, INTEGER, CHAR, TEXT);

CREATE OR REPLACE FUNCTION work_schema.send_user_messages(IN INTEGER, IN INTEGER, IN CHAR, IN TEXT)
  RETURNS BOOL AS $$
DECLARE
	_session_row work_schema.Sessions%ROWTYPE;
BEGIN
	FOR _session_row IN SELECT *
						FROM work_schema.Sessions
						WHERE ID_User = $1 AND Status = 'A'
	LOOP
		IF _session_row.ID <> $2 THEN
			INSERT INTO work_schema.Messages (ID_Session_To, ID_Session_From,
											  TypeMsg, Time_Send, Message, Status)
									  VALUES (_session_row.ID, $2, 
									          $3, now(), $4, 'L');
		END IF;
	END LOOP;

	IF FOUND THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

ALTER FUNCTION work_schema.send_user_messages(INTEGER, INTEGER, CHAR, TEXT) OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.send_user_messages(INTEGER, INTEGER, CHAR, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.send_user_messages(INTEGER, INTEGER, CHAR, TEXT) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.send_user_messages(INTEGER, INTEGER, CHAR, TEXT) TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.send_user_messages(INTEGER, INTEGER, CHAR, TEXT) IS 'Послать сообщение пользователю';
