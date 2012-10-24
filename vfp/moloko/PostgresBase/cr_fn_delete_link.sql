SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.delete_link
--DROP FUNCTION work_schema.delete_link()

CREATE OR REPLACE FUNCTION work_schema.delete_link()
  RETURNS "trigger" AS $$
DECLARE
	_Exists BOOL;
BEGIN
	--уменьшить счетчик количества детей у отца
	IF OLD.PID IS NOT NULL THEN
		EXECUTE 'UPDATE ' || TG_ARGV[0] || '.' || TG_RELNAME
				|| ' SET CHLCNT=CHLCNT-1 WHERE ID=' || OLD.PID;
	END IF;
	--проверить есть ли еще ссылки, если нет то удалить запись из _DictName
	EXECUTE 'SELECT EXISTS (SELECT ID_Dict FROM ' || TG_ARGV[0] || '.' || TG_RELNAME
		    || ' WHERE ID_Dict=' || OLD.ID_Dict || ')' INTO _Exists;

	IF NOT _Exists THEN
		EXECUTE 'DELETE FROM ' || TG_ARGV[0] || '.' || TG_ARGV[1]
				|| ' WHERE ID=' || OLD.ID_Dict;
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE 'plpgsql' VOLATILE;

COMMENT ON FUNCTION work_schema.delete_link() IS 'Удалить объект если на него нет ссылок. Удаляет объект из справочника если на него нет ни одной ссылки.';
