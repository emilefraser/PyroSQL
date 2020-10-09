SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_sql_text_lookup]
    @sql_handle varbinary(64)
AS
BEGIN
    SET NOCOUNT ON
    SELECT    
        @sql_handle as sql_handle,
        dm.[dbid] AS database_id,
        dm.[objectid] AS object_id,
        OBJECT_NAME(objectid, dbid) AS object_name,
        CASE dm.[encrypted]
            WHEN 1 THEN N'Query SQL Text Encrypted'
            ELSE dm.[text]
        END AS sql_text
        FROM    
            [sys].[dm_exec_sql_text](@sql_handle) dm
END

GO
