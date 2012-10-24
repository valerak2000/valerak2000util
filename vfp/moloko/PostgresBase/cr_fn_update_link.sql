SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.update_link
--DROP FUNCTION work_schema.update_link()

CREATE OR REPLACE FUNCTION work_schema.update_link()
  RETURNS "trigger" AS $$
DECLARE
	_Level SMALLINT;
	_Path Public.LTREE;
	_strtree TEXT;
	_RowCnt INTEGER;
BEGIN
	IF TG_OP = 'INSERT' AND NEW.PID IS NOT NULL THEN
		EXECUTE 'UPDATE ' || TG_ARGV[0] || '.' || TG_RELNAME
				|| ' SET CHLCNT = CHLCNT + 1 WHERE ID = ' || NEW.PID;
	ELSEIF TG_OP = 'UPDATE' THEN
		IF OLD.PID IS NOT NULL THEN
			IF NEW.PID IS NOT NULL THEN
				IF OLD.PID <> NEW.PID THEN
					EXECUTE 'UPDATE ' || TG_ARGV[0] || '.' || TG_RELNAME
							|| ' SET CHLCNT = CHLCNT - 1 WHERE ID = ' || OLD.PID;
					EXECUTE 'UPDATE ' || TG_ARGV[0] || '.' || TG_RELNAME
							|| ' SET CHLCNT = CHLCNT + 1 WHERE ID = ' || NEW.PID;
				END IF;
			ELSE
				EXECUTE 'UPDATE ' || TG_ARGV[0] || '.' || TG_RELNAME
						|| ' SET CHLCNT = CHLCNT - 1 WHERE ID = ' || OLD.PID;
			END IF;
		ELSE
			IF NEW.PID IS NOT NULL THEN
				EXECUTE 'UPDATE ' || TG_ARGV[0] || '.' || TG_RELNAME
						|| ' SET CHLCNT = CHLCNT + 1 WHERE ID = ' || NEW.PID;
			END IF;
		END IF;
	END IF;

	IF NEW.PID IS NULL THEN
		GET DIAGNOSTICS _RowCnt = ROW_COUNT;

		EXECUTE 'SELECT ID FROM ' || TG_ARGV[0] || '.' || TG_RELNAME 
				|| ' WHERE PID IS NULL AND ID_DICT = ' || NEW.ID_DICT;

		IF _RowCnt > 1 THEN
		--есть цикл
			RAISE EXCEPTION 'Cycle in table % for rowid=%', TG_RELNAME, NEW.ID;
			RETURN NULL;
		END IF;
		--PATH
		NEW.PATH := CAST('' AS Public.LTREE) || NEW.ID::TEXT;
		--LEVEL
		NEW.LEVEL := 0;
		--SORTID
	ELSE
		GET DIAGNOSTICS _RowCnt = ROW_COUNT;

		EXECUTE 'SELECT ID FROM ' || TG_ARGV[0] || '.' || TG_RELNAME
				|| ' WHERE PID = ' || NEW.PID || ' AND ID_DICT = ' || NEW.ID_DICT;

		IF _RowCnt > 1 THEN
		--есть цикл
			RAISE EXCEPTION 'Cycle in table % for rowid=%', TG_RELNAME, NEW.ID;
			RETURN NULL;
		END IF;

		_strtree := '''*.' || NEW.ID || '.*''';

		EXECUTE 'SELECT PATH FROM ' || TG_ARGV[0] || '.' || TG_RELNAME
				|| ' WHERE ID = ' || NEW.PID || ' AND PATH ~ ' || _strtree INTO _Path;

		IF _Path IS NOT NULL THEN
		--есть цикл
			RAISE EXCEPTION 'Cycle path=% in table %', _Path || NEW.ID, TG_RELNAME;
			RETURN NULL;
		END IF;

		EXECUTE 'SELECT PATH, LEVEL FROM ' || TG_ARGV[0] || '.' || TG_RELNAME
				|| ' WHERE ID = ' || NEW.PID INTO _Path, _Level;
		--PATH
		IF _Path IS NOT NULL THEN
			NEW.PATH := _Path || NEW.ID::TEXT;
		ELSE
			NEW.PATH := CAST('' AS Public.LTREE) || NEW.ID::TEXT;
		END IF;
		--LEVEL
		IF _Level IS NOT NULL THEN
			NEW.LEVEL := _Level + 1;
		ELSE
			NEW.LEVEL := 0;
		END IF;
		--SORTID
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

COMMENT ON FUNCTION work_schema.update_link() IS 'Обновить служебные поля объекта. Изменяет счетчик детей у родителя, проверяет на цикл.';
