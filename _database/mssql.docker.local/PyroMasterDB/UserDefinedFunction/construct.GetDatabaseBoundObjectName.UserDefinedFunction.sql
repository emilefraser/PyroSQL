SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[GetDatabaseBoundObjectName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Description: Gets the full ObjectN ame

	Test1: SELECT [construct].[GetDatabaseBoundObjectName](''TargetDB'', ''TargetSchema'', ''TargetObject'')
*/
CREATE   FUNCTION [construct].[GetDatabaseBoundObjectName] (
    @DatabaseName			SYSNAME
,	@ObjectSchema			SYSNAME
,   @ObjectName				SYSNAME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
		SELECT CONCAT(
					QUOTENAME(@DatabaseName)
				,	''.''
				,	QUOTENAME(@ObjectSchema)
				,	''.''
				,	QUOTENAME(@ObjectName)
				)
					 
	))	
END

' 
END
GO
