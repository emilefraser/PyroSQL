SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_Bin2Hex]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
	CREATE FUNCTION [tSQLt].[Private_Bin2Hex](@vb VARBINARY(MAX))
	RETURNS TABLE
	AS
	RETURN
	  SELECT X.S AS bare, ''0x''+X.S AS prefix
		FROM (SELECT LOWER(CAST('''' AS XML).value(''xs:hexBinary(sql:variable("@vb") )'',''VARCHAR(MAX)'')))X(S);
' 
END
GO
