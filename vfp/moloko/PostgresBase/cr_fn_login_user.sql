SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.login_user()
--DROP FUNCTION work_schema.login_user();

CREATE OR REPLACE FUNCTION work_schema.login_user()
  RETURNS INTEGER AS $$
DECLARE
	_id_row INTEGER;
	_session_row work_schema.Sessions%ROWTYPE;
	_userid INTEGER;
	_msg_row work_schema.Messages%ROWTYPE;
	_msg_send BOOL;
	_msg_last TIMESTAMP;
BEGIN
	_userid := work_schema.get_userid();

	IF _userid IS NULL THEN
		_id_row := NULL;
	ELSE
		--зафиксировать текущую сессию
		_id_row := nextval('work_schema.Sessions_id_seq'::regclass);

		INSERT INTO work_schema.Sessions (ID, ID_Process, ID_User, Session_ON,
										  Client_IP, Client_Port, Status)
					  			  VALUES (_id_row, pg_backend_pid(), _userid, now(),
					  			  		  inet_client_addr()::cidr, inet_client_port(), 'A');
		--проверить все активные сессии на присутствие в pg_stat_activity
		--если отсутствуют, то послать сесии сообщение с требованием доложить об активности
		FOR _session_row IN SELECT *
							FROM work_schema.Sessions AS s
							WHERE s.Status IN ('A', 'W')
							      AND NOT EXISTS (SELECT *
												  FROM pg_catalog.pg_stat_activity
							 					  WHERE datname = current_database()
							 							AND procpid = s.ID_Process
							 							AND CAST(client_addr AS CIDR) = s.Client_IP
							 							AND client_port=s.Client_Port
							 							AND usesysid=(SELECT System_OID
							 								   		 		   			 FROM work_schema.Dict_Users
							 								   		 		   			 WHERE ID=s.ID_User))
		LOOP
			CONTINUE WHEN _session_row.ID = _id_row;
			--вытащить все сообщения на активацию зависшему процессу
			_msg_send := FALSE;
			_msg_last := TIMESTAMP '1900-01-01';

			FOR _msg_row IN SELECT *
							FROM work_schema.Messages
							WHERE ID_Session_To = _session_row.ID
							      AND TypeMsg IN ('A', 'C')
			LOOP
				--установить статус необработан сообщению
				IF _msg_last < _msg_row.Time_Send THEN
					_msg_last := _msg_row.Time_Send;
				END IF;

				IF _msg_row.Status = 'L' THEN
				--просроченное
					_msg_send := TRUE;

					IF (now() - _msg_row.Time_Send) >= INTERVAL '1 hour' THEN
						UPDATE work_schema.Messages SET Time_Read = now(),
													    Status='N'
						WHERE ID = _msg_row.ID;
					END IF;
				ELSEIF _msg_row.Status = 'R' THEN
					IF (now() - _msg_row.Time_Read) <= INTERVAL '1 hour' THEN
					--свежий ответ
						_msg_send := TRUE;
					END IF;
				ELSEIF _msg_row.Status = 'N' THEN
					_msg_send := TRUE;
				END IF;
			END LOOP;

			IF _msg_send = TRUE AND (now() - _msg_last) >= INTERVAL '1 hour' THEN
				--закрыть данную сессию поскольку просроченна
				UPDATE work_schema.Sessions SET Session_OFF = now(), Status = 'D'
				WHERE ID = _session_row.ID;
			ELSEIF _msg_send = FALSE THEN
				--послать сообщение данной сессии
				PERFORM work_schema.send_session_messages(_session_row.ID, _id_row, 'C', NULL);

				UPDATE work_schema.Sessions SET Status = 'W'
				WHERE ID = _session_row.ID;
			END IF;
		END LOOP;
	END IF;

	RETURN _id_row;
END;
$$ LANGUAGE 'plpgsql' SECURITY DEFINER;

ALTER FUNCTION work_schema.login_user() OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.login_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.login_user() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.login_user() TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.login_user() IS 'Запись информации о сессии пользователя';
