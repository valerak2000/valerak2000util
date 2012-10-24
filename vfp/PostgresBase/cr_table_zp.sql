SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET check_function_bodies = false;
SET client_min_messages = warning;

SET default_tablespace = 'work_tablespace';
SET default_with_oids = false;
SET search_path = work_schema, public;

-- Table: work_schema.dict_employer
--DROP INDEX work_schema.NAME_EMPLOYERS;
--DROP TABLE work_schema.Dict_Employers;

CREATE TABLE work_schema.Dict_Employers (
	ID 			SERIAL,
	NAME		VARCHAR(100) NOT NULL,
	Surname		VARCHAR(100) NOT NULL,
	Firstname	VARCHAR(100) NOT NULL,
	Lastname	VARCHAR(100) NOT NULL,
	Inn			CHAR(12) NOT NULL,
	Ogrn		CHAR(15) NOT NULL,
	Date_born	DATE DEFAULT now() NOT NULL,
	Date_nalog	DATE DEFAULT now() NOT NULL,
	Address_live VARCHAR(100) NOT NULL,
	Address_born VARCHAR(100) NOT NULL,
	Address_registration	VARCHAR(100) NOT NULL,
	Passport	VARCHAR(50) NOT NULL,
	Okato		CHAR(10) NOT NULL,
	IsWork		BOOL DEFAULT false NOT NULL,
	CONSTRAINT	PK_DICT_EMPLOYERS PRIMARY KEY (ID)
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE UNIQUE INDEX NAME_EMPLOYERS ON work_schema.Dict_Employers USING BTREE (NAME) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Dict_Employers OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Dict_Employers FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Dict_Employers TO manager_data WITH GRANT OPTION;
GRANT INSERT,UPDATE,DELETE ON TABLE work_schema.Dict_Employers TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Dict_Employers IS 'Справочник предпринимателей';
COMMENT ON COLUMN work_schema.Dict_Employers.NAME IS 'Предприниматель';
COMMENT ON COLUMN work_schema.Dict_Employers.Surname IS 'Фамилия';
COMMENT ON COLUMN work_schema.Dict_Employers.Firstname IS 'Имя';
COMMENT ON COLUMN work_schema.Dict_Employers.Lastname IS 'Отчество';
COMMENT ON COLUMN work_schema.Dict_Employers.Inn IS 'ИНН';
COMMENT ON COLUMN work_schema.Dict_Employers.Ogrn IS 'ОГРН';
COMMENT ON COLUMN work_schema.Dict_Employers.Date_born IS 'Дата рождения';
COMMENT ON COLUMN work_schema.Dict_Employers.Date_nalog IS 'Дата постановки на налоговый учет';
COMMENT ON COLUMN work_schema.Dict_Employers.Address_live IS 'Адрес проживания';
COMMENT ON COLUMN work_schema.Dict_Employers.Address_born IS 'Место рождения';
COMMENT ON COLUMN work_schema.Dict_Employers.Address_registration IS 'Адрес регистрации';
COMMENT ON COLUMN work_schema.Dict_Employers.Passport IS 'Серия и номер паспорта';
COMMENT ON COLUMN work_schema.Dict_Employers.Okato IS 'ОКАТО';
COMMENT ON COLUMN work_schema.Dict_Employers.IsWork IS 'Работает';

-- Function: work_schema.upd_Dict_Employers
--DROP FUNCTION work_schema.upd_Dict_Employers();

CREATE OR REPLACE FUNCTION work_schema.upd_Dict_Employers()
  RETURNS "trigger" AS $$
BEGIN
	IF TG_OP IN ('INSERT', 'UPDATE') THEN
		NEW.NAME:=initcap(NEW.Surname||' '||NEW.Firstname||' '||NEW.Lastname);
		--
		RETURN NEW;
	ELSE
		RETURN OLD;
	END IF;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

ALTER FUNCTION work_schema.upd_Dict_Employers() OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.upd_Dict_Employers() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.upd_Dict_Employers() TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.upd_Dict_Employers() TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.upd_Dict_Employers() IS 'Действия перед вставкой в справочник предпринимателей';

-- Trigger: work_schema.tr_upd_Dict_Employers
--DROP TRIGGER tr_upd_Dict_Employers ON work_schema.Dict_Employers;

CREATE TRIGGER tr_upd_Dict_Employers
  BEFORE INSERT OR UPDATE OR DELETE
  ON work_schema.Dict_Employers
  FOR EACH ROW EXECUTE PROCEDURE work_schema.upd_Dict_Employers();

-- Table: work_schema.link_employer
--DROP INDEX work_schema.FKI_PID_LINK_EMPLOYERS;
--DROP INDEX work_schema.FKI_ID_LINK_EMPLOYERS;
--DROP INDEX work_schema.PATH_GIST_EMPLOYERS;
--DROP INDEX work_schema.PID_SORTID_EMPLOYERS;
--DROP TABLE work_schema.Link_Employers;

CREATE TABLE work_schema.Link_Employers (
	ID 			SERIAL,
	PID 		INTEGER,
	PATH        Public.LTREE NOT NULL,
	ID_DICT		INTEGER NOT NULL,
	SORTID 		INTEGER NOT NULL DEFAULT 0,
	LEVEL 		SMALLINT NOT NULL DEFAULT 0,
	CHLCNT		INTEGER NOT NULL DEFAULT 0,
	ID_TABLE 	OID,
	CONSTRAINT 	PK_LINK_EMPLOYERS PRIMARY KEY (ID),
	CONSTRAINT 	FK_LINK_EMPLOYERS FOREIGN KEY (PID)
		REFERENCES work_schema.Link_Employers (ID) MATCH SIMPLE
		ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT 	FK_ID_LINK_EMPLOYERS FOREIGN KEY (ID_DICT)
		REFERENCES work_schema.Dict_Employers (ID) MATCH SIMPLE
		ON UPDATE NO ACTION ON DELETE CASCADE
) WITHOUT OIDS
TABLESPACE work_tablespace;

CREATE INDEX FKI_LINK_EMPLOYERS ON work_schema.Link_Employers USING BTREE (PID) TABLESPACE work_tablespace;
CREATE INDEX FKI_ID_LINK_EMPLOYERS ON work_schema.Link_Employers USING BTREE (ID_DICT) TABLESPACE work_tablespace;
CREATE INDEX PATH_GIST_EMPLOYERS ON work_schema.Link_Employers USING GIST (PATH) TABLESPACE work_tablespace;
CREATE INDEX PID_SORTID_EMPLOYERS ON work_schema.Link_Employers USING BTREE (PID, SORTID) TABLESPACE work_tablespace;

ALTER TABLE work_schema.Link_Employers OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON TABLE work_schema.Link_Employers FROM PUBLIC;
GRANT ALL ON TABLE work_schema.Link_Employers TO manager_data WITH GRANT OPTION;
GRANT INSERT,UPDATE,DELETE ON TABLE work_schema.Link_Employers TO worker_data WITH GRANT OPTION;

COMMENT ON TABLE work_schema.Link_Employers IS 'Дерево предпринимателей';
COMMENT ON COLUMN work_schema.Link_Employers.PATH IS 'Путь от корня к ветке';
COMMENT ON COLUMN work_schema.Link_Employers.ID_DICT IS 'Ссылка на элемент справочника';
COMMENT ON COLUMN work_schema.Link_Employers.SORTID IS 'Порядок сортировки в группе';
COMMENT ON COLUMN work_schema.Link_Employers.LEVEL IS 'Уровень ветки';
COMMENT ON COLUMN work_schema.Link_Employers.CHLCNT IS 'Количество дочерних веток';

-- Trigger: work_schema.tr_upd_Link_Employers
--DROP TRIGGER tr_upd_Link_Employers ON work_schema.Link_Employers;

CREATE TRIGGER tr_upd_Link_Employers
  BEFORE INSERT OR UPDATE
  ON work_schema.Link_Employers
  FOR EACH ROW EXECUTE PROCEDURE work_schema.update_link('work_schema', 'Dict_Employers');

-- Trigger: work_schema.tr_del_Link_Employers
--DROP TRIGGER tr_del_Link_Employers ON work_schema.Link_Employers;

CREATE TRIGGER tr_del_Link_Employers
  AFTER DELETE
  ON work_schema.Link_Employers
  FOR EACH ROW EXECUTE PROCEDURE work_schema.delete_link('work_schema', 'Dict_Employers');

-- View: work_schema.View_Employers
--DROP VIEW work_schema.View_Employers;

CREATE OR REPLACE VIEW work_schema.View_Employers AS
    SELECT le.ID AS LID, le.PID, le.SORTID, le.LEVEL, le.CHLCNT, le.ID_TABLE, de.*
    FROM work_schema.Link_Employers AS le JOIN work_schema.Dict_Employers AS de ON de.ID=le.ID_Dict
    WHERE work_schema.acl_check('Справочник предпринимателей', 'V', le.PID);

ALTER TABLE work_schema.View_Employers OWNER TO admin_user;
GRANT ALL ON TABLE work_schema.View_Employers TO manager_data WITH GRANT OPTION;
GRANT ALL ON TABLE work_schema.View_Employers TO worker_data WITH GRANT OPTION;
