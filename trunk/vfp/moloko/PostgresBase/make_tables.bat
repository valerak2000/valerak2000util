chcp 1251

set _host=%1

if "%_host%" ==  "" set _host="localhost"

"d:\program files\PostgreSQL\8.3\bin\psql.exe" -h %_host% -p 5432 -U admin_user -d work_base -f make_tables.sql
