SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

-- Function: work_schema.get_messages_from()
--DROP FUNCTION work_schema.get_messages_from(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION work_schema.get_messages_from(IN INTEGER, IN CHAR)
  RETURNS SETOF work_schema.Messages AS $$
	SELECT *
	FROM work_schema.Messages
	WHERE ID_Session_From = $1 AND Status=$2
$$ LANGUAGE 'sql' RETURNS NULL ON NULL INPUT STABLE SECURITY DEFINER;

ALTER FUNCTION work_schema.get_messages_from(INTEGER, CHAR) OWNER TO admin_user;
REVOKE ALL PRIVILEGES ON FUNCTION work_schema.get_messages_from(INTEGER, CHAR) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION work_schema.get_messages_from(INTEGER, CHAR) TO manager_data WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION work_schema.get_messages_from(INTEGER, CHAR) TO worker_data WITH GRANT OPTION;

COMMENT ON FUNCTION work_schema.get_messages_from(INTEGER, CHAR) IS 'Список сообщений от сесии';
