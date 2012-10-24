SET client_encoding = 'win1251';
--SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET default_tablespace = 'work_tablespace';
SET search_path = work_schema, public;

--пользователи
INSERT INTO work_schema.Dict_Users (NAME, System_Name, CanLogin, MustAudit) 
	VALUES ('Администратор', 'admin_user', TRUE, FALSE);
INSERT INTO work_schema.Link_Users (ID_DICT, SORTID) 
	VALUES (CURRVAL('work_schema.Dict_Users_ID_seq'), 0);

INSERT INTO work_schema.Dict_Users (NAME, System_Name, CanLogin, MustAudit) 
	VALUES ('Первый пользователь', 'work_user1', TRUE, FALSE);
INSERT INTO work_schema.Link_Users (ID_DICT, SORTID) 
	VALUES (CURRVAL('work_schema.Dict_Users_ID_seq'), 1);

--объекты
--справочник пользователей
INSERT INTO work_schema.Dict_Objects (NAME, System_Name, System_LinkName, ID_Row)
	VALUES ('Справочник пользователей', 'work_schema.Dict_Users', 'work_schema.Link_Users', NULL);
INSERT INTO work_schema.Link_Objects (ID_DICT, SORTID) 
	VALUES (CURRVAL('work_schema.Dict_Objects_ID_seq'), 1);

--справочник объектов
INSERT INTO work_schema.Dict_Objects (NAME, System_Name, System_LinkName, ID_Row)
	VALUES ('Справочник объектов', 'work_schema.Dict_Objects', 'work_schema.Link_Objects', NULL);
INSERT INTO work_schema.Link_Objects (ID_DICT, SORTID) 
	VALUES (CURRVAL('work_schema.Dict_Objects_ID_seq'), 2);

--справочник прав на объекты - только администратор
--просмотр справочника Users
INSERT INTO work_schema.User_Rights (ID_Object, ID_User, Rights) 
	VALUES ((SELECT ID FROM work_schema.Dict_Objects WHERE NAME='Справочник объектов'),
			(SELECT ID FROM work_schema.Dict_Users WHERE NAME='Первый пользователь'), 'V');

--таблица блокировок объектов - только администратор