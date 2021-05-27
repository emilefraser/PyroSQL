SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetLoadDefinition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Description: This a switch to see whcih load definition function will be called

	Test1: SELECT [adf].[GetLoadDefinition](''Server'',''DBInstance'', ''Database'',''Schema'', ''Table'', '''', 5)
	Test2: SELECT [adf].[GetLoadDefinition](NULL,''DBInstance'', ''Database'',''Schema'', ''Table'', '''', 5)
	Test3: SELECT [adf].[GetLoadDefinition(NULL,''DBInstance'', ''Database'',''Schema'', ''Table'', ''Column1, Column2'', 5)
*/
CREATE     FUNCTION [adf].[GetLoadDefinition] (

	@LoadConfigID			INT
,	@SourceOrTarget			SYSNAME
,	@LoadTypeCode			SYSNAME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @LoadDefinition NVARCHAR(MAX)
	
	SET @LoadDefinition = (
		CASE @LoadTypeCode
			WHEN ''FULL''		
				THEN [adf].[GetLoadDefinition_FULL](@LoadConfigID, @SourceOrTarget)
			WHEN ''INCR'' 
				THEN [adf].[GetLoadDefinition_INCR](@LoadConfigID, @SourceOrTarget)
			WHEN ''APIFULL'' 
				THEN ''GET @ROOT\SUB\CALL''
			WHEN ''APIINCR'' 
				THEN ''GET @ROOT\SUB\CALL?fromdatet=202010&todate=20200901''
			WHEN ''APISCOPE'' 
				THEN ''GET @ROOT\SUB\CALL?id=20''
				ELSE ''''
		END
	)

	RETURN @LoadDefinition
END

' 
END
GO
