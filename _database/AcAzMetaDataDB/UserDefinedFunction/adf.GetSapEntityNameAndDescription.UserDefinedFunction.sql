SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetSapEntityNameAndDescription]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Description: Gets the full SAP table name (code + text)

	Test1: SELECT [adf].[GetSapEntityNameAndDescription]( ''T000'', ''E'')

*/
CREATE          FUNCTION [adf].[GetSapEntityNameAndDescription] (
    @SapEntityName			SYSNAME
,	@LanguageCode				NVARCHAR(3) = ''E''
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
		SELECT
			UPPER(@SapEntityName) + ''_'' + 
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
				REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(DDTEXT, '':'',''''), '','',''''),''\'',''_''),''/'',''_''),''-'',''''),''('',''''),'')'','''')
								,''['',''''),'']'','''')
								,''{'',''''),''}'','''')
								, ''   '' , '' '')
								, ''  ''  , '' '')
								, '' ''   , ''_'')
		FROM 
			dm.SapTables
		WHERE
			TABNAME = @SapEntityName
		AND
			DDLANGUAGE = @LanguageCode
	))	
END

' 
END
GO
