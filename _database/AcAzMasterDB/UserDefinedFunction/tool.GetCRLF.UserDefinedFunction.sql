SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[GetCRLF]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE   FUNCTION [tool].[GetCRLF] (
	@TabCount INT = 0
)
RETURNS NVARCHAR(20)
AS
BEGIN
	RETURN CHAR(13) + CHAR(10) + REPLICATE(CHAR(9), @TabCount)
END

' 
END
GO
