SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[Trim]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [string].[Trim] (
	@String    NVARCHAR(MAX)) 
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		RETURN LTRIM(RTRIM(@String));
	END;

' 
END
GO
