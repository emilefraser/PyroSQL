SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetFullObjectNameForLoadConfig]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Description: Gets the full ObjectN ame

	Test1: SELECT [adf].[GetFullObjectNameForLoadConifg](''Server'',''DBInstance'', ''Database'',''Schema'', ''Table'')
	Test2: SELECT [adf].[GetFullObjectNameForLoadConifg](NULL,''DBInstance'', ''Database'',''Schema'', ''Table'')
	Test3: SELECT [adf].[GetFullObjectNameForLoadConif](NULL,''DBInstance'', ''Database'',''Schema'', ''Table'')
*/
CREATE         FUNCTION [adf].[GetFullObjectNameForLoadConfig] (
    @ServerName				SYSNAME  = NULL
,	@DatabaseInstanceName	SYSNAME  = NULL
,   @DatabaseName			SYSNAME  = NULL
,   @SchemaName				SYSNAME  = NULL
,   @EntityName				SYSNAME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN ((
		SELECT
			IIF(COALESCE(@ServerName, '''') = '''', 
				'''',
				IIF(COALESCE(@DatabaseInstanceName, '''') = ''''
					, @ServerName + ''|'' 
					, @ServerName + ''|'' + @DatabaseInstanceName + ''|''
				)
			) + 
			IIF(COALESCE(@DatabaseName, '''') = ''''
				, ''''
				, @DatabaseName + ''|''
			) +
			IIF(COALESCE(@SchemaName, '''') = ''''
				, ''''
				, @SchemaName + ''|''
			) +
			IIF(COALESCE(@EntityName, '''') = ''''
				, ''''
				, @EntityName
			)
	))	
END

' 
END
GO
