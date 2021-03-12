SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetDatabaseFillRatio]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetDatabaseFillRatio] AS' 
END
GO
ALTER PROCEDURE [dss].[GetDatabaseFillRatio]
AS
BEGIN
    DECLARE @DbName varchar(255)
    SET @DbName = db_name()

    DECLARE @DbMaxSize bigint
    SET @DbMaxSize = CAST(DATABASEPROPERTYEX(@DbName,'MaxSizeInBytes') AS BIGINT)/1024

    IF (@DbMaxSize IS NULL)
    BEGIN
        -- The extended property 'MaxSizeInBytes' is only available in SQL Azure
        SELECT -1.0 'FillRatio';
    END

    declare @DbSize bigint
    SELECT @DbSize = SUM(reserved_page_count) * 8.0 FROM sys.dm_db_partition_stats

    SELECT  CAST(@DbSize as numeric(10,0))*100.0/CAST(@DbMaxSize as numeric(10,0)) 'FillRatio'
END
GO
