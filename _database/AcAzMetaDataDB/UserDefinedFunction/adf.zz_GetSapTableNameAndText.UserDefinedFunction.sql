SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[zz_GetSapTableNameAndText]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT [adf].[GetSapTableNameAndText] (''T156'')
*/
CREATE     FUNCTION [adf].[zz_GetSapTableNameAndText] (
	@TableName SYSNAME
)
RETURNS SYSNAME
AS
BEGIN
	RETURN (

		SELECT 
			@TableName + ''_'' +
			COALESCE((
					SELECT REPLACE(
								REPLACE(
									REPLACE(
										REPLACE([DDTEXT], '' '', ''_'')
									, ''/'' ,''_'')
								, ''\'' ,''_'')
							, '':'', '''')
					FROM 
						[dm].[SapTables]
					WHERE 
						tabname = @TableName
			), NULL
		)
	)

	
END

' 
END
GO
