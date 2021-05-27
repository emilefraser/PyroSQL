SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dm].[SapFields]'))
EXEC dbo.sp_executesql @statement = N'
-- SELECT * FROM [dm].[SapFields] WHERE REFTABLE != ''''
CREATE   VIEW [dm].[SapFields]
AS
	SELECT
		[dd03m].[TABNAME]
	  , [dd03m].[FIELDNAME]
	  , [dd03m].[DDLANGUAGE]		
	  , [dd03m].[DDTEXT]
	  , [KEYFLAG]					= IIF([dd03m].[KEYFLAG] = ''X'', 1, 0)	  
	  , [ISNULLABLE]				= IIF([dd03m].[MANDATORY] = ''X'', 0, 1)
	  , [dd03m].[INTTYPE]
	  , [dd03m].[DATATYPE]		
	  , [LENG]						= CONVERT(INT, [dd03m].[LENG])
	  , [INTLEN]					= CONVERT(INT, [dd03m].[INTLEN])
	  , [DECIMALS]					= CONVERT(INT, [dd03m].[DECIMALS])
	  , [dd03m].[REFTABLE]
	  , [POSITION]					= CONVERT(INT, [dd03m].[POSITION])
	  , [POSITION_SQL]				= ROW_NUMBER() OVER (PARTITION BY [dd03m].[TABNAME] ORDER BY [dd03m].[POSITION] ASC)
	  , [REPTEXT]					= [dd03m].[REPTEXT] 
	  , [SCRTEXT_S]					= [dd03m].[SCRTEXT_S]
	  , [SCRTEXT_M]					= [dd03m].[SCRTEXT_M]
	  , [SCRTEXT_L]					= [dd03m].[SCRTEXT_L]
	FROM
		[dm].[DD03M_Generated_Table_for_View_PROD] AS [dd03m]
	WHERE
		[dd03m].[DDLANGUAGE] = ''E''
		
' 
GO
