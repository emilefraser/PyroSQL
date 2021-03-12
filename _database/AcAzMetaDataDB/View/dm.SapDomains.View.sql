SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dm].[SapDomains]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [dm].[SapDomains]
AS
SELECT
	DOMNAME				= dom.[DOMNAME]
,	DATATYPE			= dom.[DATATYPE]
,	LENG				= TRY_CONVERT(SMALLINT, dom.[LENG])
,	OUTPUTLEN			= TRY_CONVERT(SMALLINT, dom.[OUTPUTLEN])
,	DECIMALS			= TRY_CONVERT(SMALLINT, dom.[DECIMALS])
,	IsSignFlag			= IIF(dom.SIGNFLAG = ''X'', 1, 0)
,	DDLANGUAGE			= dom.[DDLANGUAGE]
,	DDTEXT				= dom.[DDTEXT]
FROM  
	[dm].[DD01V_Generated_Table_for_View_PROD] AS dom
WHERE	
	dom.DDLANGUAGE = ''E''
' 
GO
