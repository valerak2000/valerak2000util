SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Table: work_schema.User_Rights
--DROP INDEX work_schema.FKI_USERS_USER_RIGHTS;
--DROP INDEX work_schema.FKI_OBJECTS_USER_RIGHTS;
--DROP TABLE work_schema.User_Rights;

CREATE TABLE work_schema.User_Rights (
	ID_Object		INTEGER NOT NULL,
	ID_User			INTEGER NOT NULL,
	Rights			CHAR(4) DEFAULT 'X',
	Inherits_Rights	CHAR(4) DEFAULT 'X',
	CONSTRAINT FK_OBJECTS_USER_RIGHTS FOREIGN KEY (ID_Object)
    	REFERENCES work_schema.Dict_Objects (ID) MATCH SIMPLE
    	ON UPDATE NO ACTION ON DELETE CASCADE,
	CONSTRAINT FK_USERS_USER_RIGHTS FOREIGN KEY (ID_User)
    	REFERENCES work_schema.Dict_Users (ID) MATCH SIMPLE
    	ON UPDATE NO ACTION ON DELETE CASCADE
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE INDEX FKI_OBJECTS_USER_RIGHTS ON work_schema.User_Rights USING BTREE (ID_Object) TABLESPACE work_tablespace;
CREATE INDEX FKI_USERS_USER_RIGHTS ON work_schema.User_Rights USING BTREE (ID_User) TABLESPACE work_tablespace;

ALTER TABLE work_schema.User_Rights OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.User_Rights FROM PUBLIC;
GRANT ALL ON TABLE work_schema.User_Rights TO manager_data WITH GRANT OPTION;
GRANT SELECT ON TABLE work_schema.User_Rights TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.User_Rights IS 'Права пользователей на объекты';
COMMENT ON COLUMN work_schema.User_Rights.ID_Object IS 'Объект';
COMMENT ON COLUMN work_schema.User_Rights.ID_User IS 'Пользователь';
COMMENT ON COLUMN work_schema.User_Rights.Rights IS 'ACL доступа: V-View, I-Insert, U-Update, D-Delete, X-Нет никаких прав';
COMMENT ON COLUMN work_schema.User_Rights.Inherits_Rights IS 'ACL доступа предков';
