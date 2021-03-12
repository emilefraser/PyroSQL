SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[IsConfigValid]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [adf].[IsConfigValid] (
	@LoadConfigID INT
)
RETURNS BIT
AS
BEGIN
	RETURN 1
END

' 
END
GO
