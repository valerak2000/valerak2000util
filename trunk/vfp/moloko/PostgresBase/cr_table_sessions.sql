SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Table: work_schema.Sessions
--DROP INDEX work_schema.FKI_USERS_SESSIONS;
--DROP TABLE work_schema.Sessions;

CREATE TABLE work_schema.Sessions (
	ID					 SERIAL,
	ID_User              INTEGER,
	ID_Process			 INTEGER NOT NULL,
	Client_IP            CIDR NOT NULL,
	Client_Port          INTEGER NOT NULL,
	Session_ON           TIMESTAMP DEFAULT now() NOT NULL,
	Session_OFF          TIMESTAMP,
	Status		         CHAR NOT NULL DEFAULT 'A',
	CONSTRAINT PK_SESSIONS PRIMARY KEY (ID),
	CONSTRAINT FK_USERS_SESSIONS FOREIGN KEY (ID_User)
		REFERENCES work_schema.Dict_Users (ID) MATCH SIMPLE
    	  ON UPDATE NO ACTION ON DELETE SET NULL
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE INDEX FKI_USERS_SESSIONS ON work_schema.Sessions USING BTREE (ID_User) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Sessions OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Sessions FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Sessions TO manager_data WITH GRANT OPTION;
GRANT SELECT ON TABLE work_schema.Sessions TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Sessions IS 'Таблица логов сессий';
COMMENT ON COLUMN work_schema.Sessions.ID IS 'ID сессии';
COMMENT ON COLUMN work_schema.Sessions.ID_Process IS 'PID fork-a сессий';
COMMENT ON COLUMN work_schema.Sessions.ID_User IS 'Пользователь открывший сессию';
COMMENT ON COLUMN work_schema.Sessions.Session_ON IS 'Время начала сессии';
COMMENT ON COLUMN work_schema.Sessions.Session_OFF IS 'Время окончания сессии';
COMMENT ON COLUMN work_schema.Sessions.Client_IP IS 'IP клиента открывшего сессию';
COMMENT ON COLUMN work_schema.Sessions.Client_Port IS 'Port клиента открывшего сессию';
COMMENT ON COLUMN work_schema.Sessions.Status IS 'Статус сессии - A-activity, C-closed, W-waiting response, D-disconnected abnormaly';
