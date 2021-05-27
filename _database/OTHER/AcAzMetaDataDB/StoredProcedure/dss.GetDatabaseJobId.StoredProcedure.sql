SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[GetDatabaseJobId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[GetDatabaseJobId] AS' 
END
GO
ALTER PROCEDURE [dss].[GetDatabaseJobId]
    @DatabaseId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT [jobId] FROM [dss].[userdatabase]
    WHERE [id] = @DatabaseId
    RETURN 0
END
GO
