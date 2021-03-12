SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[IsDatabaseInDeletingState]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dss].[IsDatabaseInDeletingState]
(
    @DatabaseId UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0

    IF EXISTS (SELECT 1 FROM [dss].[userdatabase] WHERE [id] = @DatabaseId AND [state] = 1)
    BEGIN
        SET @Result = 1
    END

    RETURN @Result
END' 
END
GO
