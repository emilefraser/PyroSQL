SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[IsSyncGroupActiveOrNotReady]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dss].[IsSyncGroupActiveOrNotReady]
(
    @SyncGroupId UNIQUEIDENTIFIER
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0

    -- state 0: Active
    -- state 3: NotReady, sync scope info is not provided when creating sync group
    IF EXISTS (SELECT 1 FROM [dss].[syncgroup] WHERE [id] = @SyncGroupId AND [state] IN (0 ,3))
    BEGIN
        SET @Result = 1
    END

    RETURN @Result
END' 
END
GO
