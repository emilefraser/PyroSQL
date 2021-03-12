SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SetDatabaseRegion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dss].[SetDatabaseRegion] AS' 
END
GO
ALTER PROCEDURE [dss].[SetDatabaseRegion]
    @DatabaseID	UNIQUEIDENTIFIER,
    @Region nvarchar(256)
AS
BEGIN
    UPDATE [dss].[userdatabase]
    SET
        [region] = @Region
    WHERE [id] = @DatabaseID
END
GO
