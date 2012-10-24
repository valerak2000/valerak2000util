SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Table: work_schema.Messages
--DROP INDEX work_schema.FKI_SESSIONS_MESSAGES_TO;
--DROP INDEX work_schema.FKI_SESSIONS_MESSAGES_FROM;
--DROP TABLE work_schema.Messages;

CREATE TABLE work_schema.Messages (
	ID                   SERIAL,
	ID_Session_To        INTEGER NOT NULL,
	ID_Session_From      INTEGER NOT NULL,
	TypeMsg	             CHAR NOT NULL,
	Time_Send	         TIMESTAMP DEFAULT now() NOT NULL,
	Time_Read   	     TIMESTAMP,
	Message              TEXT,
	Status               CHAR NOT NULL,
	CONSTRAINT PK_MESSAGES PRIMARY KEY (ID),
	CONSTRAINT FK_SESSIONS_MESSAGES_TO FOREIGN KEY (ID_Session_To)
		REFERENCES work_schema.Sessions (ID) MATCH SIMPLE
    	  ON UPDATE NO ACTION ON DELETE CASCADE,
	CONSTRAINT FK_SESSIONS_MESSAGES_FROM FOREIGN KEY (ID_Session_From)
		REFERENCES work_schema.Sessions (ID) MATCH SIMPLE
    	  ON UPDATE NO ACTION ON DELETE CASCADE
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE INDEX FKI_SESSIONS_MESSAGES_TO ON work_schema.Messages USING BTREE (ID_Session_To) TABLESPACE work_tablespace;
CREATE INDEX FKI_SESSIONS_MESSAGES_FROM ON work_schema.Messages USING BTREE (ID_Session_From) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Messages OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Messages FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Messages TO manager_data WITH GRANT OPTION;
GRANT SELECT ON TABLE work_schema.Messages TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Messages IS 'Служебные сообщения';
COMMENT ON COLUMN work_schema.Messages.ID IS 'ID сообщения';
COMMENT ON COLUMN work_schema.Messages.ID_Session_To IS 'ID сессии получателя сообщения';
COMMENT ON COLUMN work_schema.Messages.ID_Session_From IS 'ID сессии отправителя сообщение';
COMMENT ON COLUMN work_schema.Messages.TypeMsg IS 'Тип сообщения - M-text message, A-abort programm, C-Check activity';
COMMENT ON COLUMN work_schema.Messages.Time_Send IS 'Время отправки сообщения';
COMMENT ON COLUMN work_schema.Messages.Time_Read IS 'Время обработки сообщения';
COMMENT ON COLUMN work_schema.Messages.Message IS 'Текст сообщения';
COMMENT ON COLUMN work_schema.Messages.Status IS 'Статус сообщения - L-listening answers, R-reply ok, N-not read';
