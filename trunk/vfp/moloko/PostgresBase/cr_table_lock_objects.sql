SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Table: work_schema.Lock_Objects
--DROP INDEX work_schema.FKI_OBJECTS_LOCKS;
--DROP INDEX work_schema.FKI_USERS_LOCKS;
--DROP INDEX work_schema.FKI_SESSIONS_LOCKS;
--DROP TABLE work_schema.Lock_Objects;

CREATE TABLE work_schema.Lock_Objects (
	ID			SERIAL,
	ID_Object	INTEGER NOT NULL,
	ID_Session	INTEGER NOT NULL,
	ID_User		INTEGER NOT NULL,
	ID_Row		INTEGER NOT NULL,
	Status		CHAR DEFAULT '' NOT NULL,
	Lock_On		TIMESTAMP DEFAULT now() NOT NULL,
	Lock_Off	TIMESTAMP,
	CONSTRAINT FK_OBJECTS_LOCKS FOREIGN KEY (ID_Object)
    	REFERENCES work_schema.Dict_Objects (ID) MATCH SIMPLE
    	ON UPDATE NO ACTION ON DELETE CASCADE,
	CONSTRAINT FK_SESSIONS_LOCKS FOREIGN KEY (ID_Session)
    	REFERENCES work_schema.Sessions (ID) MATCH SIMPLE
    	ON UPDATE NO ACTION ON DELETE CASCADE,
	CONSTRAINT FK_USERS_LOCKS FOREIGN KEY (ID_User)
    	REFERENCES work_schema.Dict_Users (ID) MATCH SIMPLE
    	ON UPDATE NO ACTION ON DELETE CASCADE
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE INDEX FKI_OBJECTS_LOCKS ON work_schema.Lock_Objects USING BTREE (ID_Object, ID_Row) TABLESPACE work_tablespace;
CREATE INDEX FKI_SESSIONS_LOCKS ON work_schema.Lock_Objects USING BTREE (ID_Session) TABLESPACE work_tablespace;
CREATE INDEX FKI_USERS_LOCKS ON work_schema.Lock_Objects USING BTREE (ID_User) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Lock_Objects OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Lock_Objects FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Lock_Objects TO manager_data WITH GRANT OPTION;
GRANT SELECT ON TABLE work_schema.Lock_Objects TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Lock_Objects IS 'Заблокированные объекты';
COMMENT ON COLUMN work_schema.Lock_Objects.ID_Object IS 'Объект в котором блокируется запись';
COMMENT ON COLUMN work_schema.Lock_Objects.ID_User IS 'Пользователь юлокирующий запись';
COMMENT ON COLUMN work_schema.Lock_Objects.ID_Session IS 'Сессия которая блокирует запись';
COMMENT ON COLUMN work_schema.Lock_Objects.ID_Row IS 'Блокируемая запись';
COMMENT ON COLUMN work_schema.Lock_Objects.Status IS 'Статус блокировки - L-Lock, U-Unlock';
COMMENT ON COLUMN work_schema.Lock_Objects.Lock_On IS 'Время начала блокировки';
COMMENT ON COLUMN work_schema.Lock_Objects.Lock_Off IS 'Время окончания блокировки';
