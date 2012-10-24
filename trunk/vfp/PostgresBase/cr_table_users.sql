SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Table: work_schema.Dict_Users
--DROP INDEX work_schema.NAME_USERS;
--DROP TABLE work_schema.Dict_Users;

CREATE TABLE work_schema.Dict_Users (
	ID 			SERIAL,
	NAME 			VARCHAR(100) NOT NULL,
	System_Name 	NAME,
	System_OID	OID,
	CanLogin 		BOOL NOT NULL DEFAULT FALSE,
	MustAudit		BOOL NOT NULL DEFAULT FALSE,
	CONSTRAINT	PK_DICT_USERS PRIMARY KEY (ID)
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE UNIQUE INDEX NAME_USERS ON work_schema.Dict_Users USING BTREE (NAME) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Dict_Users OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Dict_Users FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Dict_Users TO manager_data WITH GRANT OPTION;
GRANT INSERT,UPDATE,DELETE ON TABLE work_schema.Dict_Users TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Dict_Users IS 'Справочник пользователей';
COMMENT ON COLUMN work_schema.Dict_Users.NAME IS 'Имя пользователя';
COMMENT ON COLUMN work_schema.Dict_Users.System_Name IS 'Имя системной роли';
COMMENT ON COLUMN work_schema.Dict_Users.System_OID IS 'OID системной роли';
COMMENT ON COLUMN work_schema.Dict_Users.CanLogin IS 'Может логиниться';
COMMENT ON COLUMN work_schema.Dict_Users.MustAudit IS 'Сохранять логи действий пользователя';

-- Function: work_schema.upd_Dict_Users
--DROP FUNCTION work_schema.upd_Dict_Users();

CREATE OR REPLACE FUNCTION work_schema.upd_Dict_Users()
  RETURNS "trigger" AS $$
BEGIN
	IF NEW.System_Name IS NOT NULL THEN
		--проверить чтобы не использовали еще раз System_Name
		IF EXISTS(SELECT ID
				  FROM work_schema.Dict_Users
				  WHERE ID!=NEW.ID AND System_Name=NEW.System_Name) THEN
			RAISE EXCEPTION 'Системная роль ''%'' уже используется!', NEW.System_Name;
			--
			RETURN OLD;
		END IF;
		--найти OID системной роли
		SELECT USESYSID INTO NEW.System_OID
		FROM PG_USER
		WHERE USENAME=NEW.System_Name;
		--
		IF NOT FOUND THEN
			NEW.System_OID:=NULL;
			NEW.CanLogin:=FALSE;
		END IF;
	ELSE
		NEW.System_OID:=NULL;
		NEW.CanLogin:=FALSE;
	END IF;
	--
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

ALTER FUNCTION work_schema.upd_Dict_Users() OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.upd_Dict_Users() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.upd_Dict_Users() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.upd_Dict_Users() TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.upd_Dict_Users() IS 'Действия перед вставкой в справочник пользователей';

-- Trigger: work_schema.tr_upd_Dict_Users
--DROP TRIGGER tr_upd_Dict_Users ON work_schema.Dict_Users;

CREATE TRIGGER tr_upd_Dict_Users
  BEFORE INSERT OR UPDATE
  ON work_schema.Dict_Users
  FOR EACH ROW EXECUTE PROCEDURE work_schema.upd_Dict_Users();

-- Table: work_schema.Link_Users
--DROP INDEX work_schema.FKI_PID_LINK_USERS;
--DROP INDEX work_schema.FKI_ID_LINK_USERS;
--DROP INDEX work_schema.PATH_GIST_USERS;
--DROP INDEX work_schema.PID_SORTID_USERS;
--DROP TABLE work_schema.Link_Users;

CREATE TABLE work_schema.Link_Users (
	ID 			SERIAL,
	PID 		INTEGER,
	PATH        Public.LTREE NOT NULL,
	ID_DICT		INTEGER NOT NULL,
	SORTID 		INTEGER NOT NULL DEFAULT 0,
	LEVEL 		SMALLINT NOT NULL DEFAULT 0,
	CHLCNT		INTEGER NOT NULL DEFAULT 0,
	ID_TABLE 	OID,
	CONSTRAINT 	PK_LINK_USERS PRIMARY KEY (ID),
	CONSTRAINT 	FK_LINK_USERS FOREIGN KEY (PID)
		REFERENCES work_schema.Link_Users (ID) MATCH SIMPLE
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT 	FK_ID_LINK_USERS FOREIGN KEY (ID_DICT)
		REFERENCES work_schema.Dict_Users (ID) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE CASCADE
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE INDEX FKI_LINK_USERS ON work_schema.Link_Users USING BTREE (PID) TABLESPACE work_tablespace;
CREATE INDEX FKI_ID_LINK_USERS ON work_schema.Link_Users USING BTREE (ID_DICT) TABLESPACE work_tablespace;
CREATE INDEX PATH_GIST_USERS ON work_schema.Link_Users USING GIST (PATH) TABLESPACE work_tablespace;
CREATE INDEX PID_SORTID_USERS ON work_schema.Link_Users USING BTREE (PID, SORTID) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Link_Users OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Link_Users FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Link_Users TO manager_data WITH GRANT OPTION;
GRANT INSERT,UPDATE,DELETE ON TABLE work_schema.Link_Users TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Link_Users IS 'Дерево пользователей';
COMMENT ON COLUMN work_schema.Link_Users.PATH IS 'Путь от корня к ветке';
COMMENT ON COLUMN work_schema.Link_Users.ID_DICT IS 'Ссылка на элемент справочника';
COMMENT ON COLUMN work_schema.Link_Users.SORTID IS 'Порядок сортировки в группе';
COMMENT ON COLUMN work_schema.Link_Users.LEVEL IS 'Уровень ветки';
COMMENT ON COLUMN work_schema.Link_Users.CHLCNT IS 'Количество дочерних веток';

-- Trigger: work_schema.tr_upd_Link_Users
--DROP TRIGGER tr_upd_Link_Users ON work_schema.Link_Users;

CREATE TRIGGER tr_upd_Link_Users
  BEFORE INSERT OR UPDATE
  ON work_schema.Link_Users
  FOR EACH ROW EXECUTE PROCEDURE work_schema.update_link('work_schema','Dict_Users');

-- Trigger: work_schema.tr_del_Link_Users
--DROP TRIGGER tr_del_Link_Users ON work_schema.Link_Users;

CREATE TRIGGER tr_del_Link_Users
  AFTER DELETE
  ON work_schema.Link_Users
  FOR EACH ROW EXECUTE PROCEDURE work_schema.delete_link('work_schema','Dict_Users');
