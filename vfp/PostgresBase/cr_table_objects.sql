SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Table: work_schema.Dict_Objects
--DROP INDEX work_schema.OBJECTS_NAME;
--DROP TABLE work_schema.Dict_Objects cascade;

CREATE TABLE work_schema.Dict_Objects (
	ID				SERIAL,
	NAME            VARCHAR(100) NOT NULL,
	System_Name     NAME NOT NULL,
	System_OID      OID,
	System_LinkName	NAME,
	System_LinkOID  OID,
	ID_Row          INTEGER,
	CONSTRAINT 		PK_DICT_OBJECTS PRIMARY KEY (ID)
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE UNIQUE INDEX OBJECTS_NAME ON work_schema.Dict_Objects USING BTREE (NAME) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Dict_Objects OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Dict_Objects FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Dict_Objects TO manager_data WITH GRANT OPTION;
GRANT INSERT,UPDATE,DELETE ON TABLE work_schema.Dict_Objects TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Dict_Objects IS 'Дерево описания объектов программы';
COMMENT ON COLUMN work_schema.Dict_Objects.ID IS 'ID объекта';
COMMENT ON COLUMN work_schema.Dict_Objects.NAME IS 'Наименования объекта';
COMMENT ON COLUMN work_schema.Dict_Objects.System_OID IS 'OID таблицы где расположен объект';
COMMENT ON COLUMN work_schema.Dict_Objects.System_Name IS 'Системное имя таблицы где расположен объект';
COMMENT ON COLUMN work_schema.Dict_Objects.System_LinkOID IS 'OID таблицы связей объекта';
COMMENT ON COLUMN work_schema.Dict_Objects.System_LinkName IS 'Системное имя таблицы связей объекта';
COMMENT ON COLUMN work_schema.Dict_Objects.ID_Row IS 'Ссылка на ветку объекта';

-- Function: work_schema.upd_Dict_Objects
--DROP FUNCTION work_schema.upd_Dict_Objects();

CREATE OR REPLACE FUNCTION work_schema.upd_Dict_Objects()
  RETURNS "trigger" AS $$
BEGIN
	IF NEW.System_Name IS NOT NULL THEN
  		NEW.System_OID:=(SELECT relid
						 FROM pg_stat_all_tables
						 WHERE schemaname=LOWER(substring(NEW.System_Name, 1, position('.' IN NEW.System_Name)-1)) AND
			  				   relname=LOWER(substring(NEW.System_Name, position('.' IN NEW.System_Name)+1)));
	ELSE
		RAISE NOTICE 'System_Name IS NULL';
		NEW.System_OID:=NULL;
	END IF;
	--
	IF NEW.System_LinkName IS NOT NULL THEN
  		NEW.System_LinkOID:=(SELECT relid
						 FROM pg_stat_all_tables
						 WHERE schemaname=LOWER(substring(NEW.System_LinkName, 1, position('.' IN NEW.System_LinkName)-1)) AND
			  				   relname=LOWER(substring(NEW.System_LinkName, position('.' IN NEW.System_LinkName)+1)));
	ELSE
		RAISE NOTICE 'System_LinkName IS NULL';
		NEW.System_LinkOID:=NULL;
	END IF;
	--
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

ALTER FUNCTION work_schema.upd_Dict_Objects() OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.upd_Dict_Objects() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.upd_Dict_Objects() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.upd_Dict_Objects() TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.upd_Dict_Objects() IS 'Действия перед вставкой в справочник объектов';

-- Trigger: work_schema.tr_upd_upd_Dict_Objects
--DROP TRIGGER tr_upd_upd_Dict_Objects ON work_schema.Dict_Objects;

CREATE TRIGGER tr_upd_upd_Dict_Objects
  BEFORE INSERT OR UPDATE
  ON work_schema.Dict_Objects
  FOR EACH ROW EXECUTE PROCEDURE work_schema.upd_Dict_Objects();

-- Table: work_schema.Link_Objects
--DROP INDEX work_schema.FKI_PID_LINK_OBJECTS;
--DROP INDEX work_schema.FKI_ID_LINK_OBJECTS;
--DROP INDEX work_schema.PATH_GIST_OBJECTS;
--DROP INDEX work_schema.PID_SORTID_OBJECTS;
--DROP TABLE work_schema.Link_Objects;

CREATE TABLE work_schema.Link_Objects (
	ID 			SERIAL,
	PID 		INTEGER,
	PATH        Public.LTREE NOT NULL,
	ID_DICT		INTEGER NOT NULL,
	SORTID 		INTEGER NOT NULL DEFAULT 0,
	LEVEL 		SMALLINT NOT NULL DEFAULT 0,
	CHLCNT		INTEGER NOT NULL DEFAULT 0,
	ID_TABLE 	OID,
	CONSTRAINT 	PK_LINK_OBJECTS PRIMARY KEY (ID),
	CONSTRAINT 	FK_LINK_OBJECTS FOREIGN KEY (PID)
		REFERENCES work_schema.Link_Objects (ID) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE CASCADE,
	CONSTRAINT 	FK_ID_LINK_OBJECTS FOREIGN KEY (ID_DICT)
		REFERENCES work_schema.Dict_Objects (ID) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE CASCADE
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE INDEX FKI_LINK_OBJECTS ON work_schema.Link_Objects USING BTREE (PID) TABLESPACE work_tablespace;
CREATE INDEX FKI_ID_LINK_OBJECTS ON work_schema.Link_Objects USING BTREE (ID_DICT) TABLESPACE work_tablespace;
CREATE INDEX PATH_GIST_OBJECTS ON work_schema.Link_Objects USING GIST (PATH) TABLESPACE work_tablespace;
CREATE INDEX PID_SORTID_OBJECTS ON work_schema.Link_Objects USING BTREE (PID, SORTID) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Link_Objects OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Link_Objects FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Link_Objects TO manager_data WITH GRANT OPTION;
GRANT INSERT,UPDATE,DELETE ON TABLE work_schema.Link_Objects TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Link_Objects IS 'Дерево объектов программы';
COMMENT ON COLUMN work_schema.Link_Objects.PATH IS 'Путь от корня к ветке';
COMMENT ON COLUMN work_schema.Link_Objects.ID_DICT IS 'Ссылка на элемент справочника';
COMMENT ON COLUMN work_schema.Link_Objects.SORTID IS 'Порядок сортировки в группе';
COMMENT ON COLUMN work_schema.Link_Objects.LEVEL IS 'Уровень ветки';
COMMENT ON COLUMN work_schema.Link_Objects.CHLCNT IS 'Количество дочерних веток ';

-- Trigger work_schema.tr_upd_Link_Objects
--DROP TRIGGER tr_upd_Link_Objects ON work_schema.Link_Objects;

CREATE TRIGGER tr_upd_Link_Objects
  BEFORE INSERT OR UPDATE
  ON work_schema.Link_Objects
  FOR EACH ROW EXECUTE PROCEDURE work_schema.update_link('work_schema','Dict_Objects');

-- Trigger work_schema.tr_del_Link_Objects
--DROP TRIGGER tr_del_Link_Objects ON work_schema.Link_Objects;

CREATE TRIGGER tr_del_Link_Objects
  AFTER DELETE
  ON work_schema.Link_Objects
  FOR EACH ROW EXECUTE PROCEDURE work_schema.delete_link('work_schema','Dict_Objects');
