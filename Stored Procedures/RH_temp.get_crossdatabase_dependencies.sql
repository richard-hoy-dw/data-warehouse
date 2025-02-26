SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [RH_temp].[get_crossdatabase_dependencies] AS

SET NOCOUNT ON;

CREATE TABLE #databases(
    database_id int, 
    database_name sysname
);

INSERT INTO #databases(database_id, database_name)
SELECT database_id, [name]
FROM sys.databases
WHERE 1 = 1
    AND [state] <> 6 /* ignore offline DBs */
    AND database_id > 4; /* ignore system DBs */

DECLARE 
    @database_id int, 
    @database_name sysname, 
    @sql varchar(max);

CREATE TABLE [RH_TestDB].rh_temp.dependencies(
    referencing_database varchar(max),
    referencing_schema varchar(max),
    referencing_object_name varchar(max),
    referenced_server varchar(max),
    referenced_database varchar(max),
    referenced_schema varchar(max),
    referenced_object_name varchar(max)
);

WHILE (SELECT COUNT(*) FROM #databases) > 0 BEGIN
    SELECT TOP 1 @database_id = database_id, 
                 @database_name = database_name 
    FROM #databases;

    SET @sql = 'INSERT INTO [RH_TestDB].rh_temp.dependencies select 
        DB_NAME(' + convert(varchar,@database_id) + '), 
        OBJECT_SCHEMA_NAME(referencing_id,' 
            + convert(varchar,@database_id) +'), 
        OBJECT_NAME(referencing_id,' + convert(varchar,@database_id) + '), 
        referenced_server_name,
        ISNULL(referenced_database_name, db_name(' 
             + convert(varchar,@database_id) + ')),
        referenced_schema_name,
        referenced_entity_name
    FROM ' + quotename(@database_name) + '.sys.sql_expression_dependencies';

    EXEC(@sql);

    DELETE FROM #databases WHERE database_id = @database_id;
END;

SET NOCOUNT OFF;
GO
