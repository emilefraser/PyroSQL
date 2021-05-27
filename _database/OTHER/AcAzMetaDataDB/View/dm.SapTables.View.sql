SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dm].[SapTables]'))
EXEC dbo.sp_executesql @statement = N'
CREATE   VIEW [dm].[SapTables]
AS
SELECT
	dd02v.TABNAME
  , dd02v.DDTEXT
  , dd02v.SQLTAB
  , LANGDEP = IIF(dd02v.LANGDEP = ''X'', 1, 0)
  , dd02v.DDLANGUAGE
  , CLIDEP = IIF(dd02v.CLIDEP = ''X'', 1, 0)
  , PROXYTYPE = IIF(dd02v.PROXYTYPE = ''X'', 1, 0)
  , dd02v.TABCLASS
  , dd02v.VIEWCLASS
  , dd02v.APPLCLASS
  , dd02v.EXCLASS
  , ALLDATAINCL  = IIF(dd02v.ALLDATAINCL = ''X'', 1, 0)
  , ALWAYSTRP = IIF(dd02v.ALWAYSTRP = ''X'', 1, 0)
  , NONTRP_INCLUDED  = IIF(dd02v.NONTRP_INCLUDED = ''X'', 1, 0)
FROM
	[dm].[DD02V_Generated_Table_for_View_PROD] AS dd02v
WHERE
	 dd02v.DDLANGUAGE = ''E''

UNION ALL

SELECT
	dd02v.TABNAME
  , dd02v.DDTEXT
  , dd02v.SQLTAB
  , LANGDEP = IIF(dd02v.LANGDEP = ''X'', 1, 0)
  , dd02v.DDLANGUAGE
  , CLIDEP = IIF(dd02v.CLIDEP = ''X'', 1, 0)
  , PROXYTYPE = IIF(dd02v.PROXYTYPE = ''X'', 1, 0)
  , dd02v.TABCLASS
  , dd02v.VIEWCLASS
  , dd02v.APPLCLASS
  , dd02v.EXCLASS
  , ALLDATAINCL  = IIF(dd02v.ALLDATAINCL = ''X'', 1, 0)
  , ALWAYSTRP = IIF(dd02v.ALWAYSTRP = ''X'', 1, 0)
  , NONTRP_INCLUDED  = IIF(dd02v.NONTRP_INCLUDED = ''X'', 1, 0)
FROM
	[dm].[DD02V_Generated_Table_for_View_PROD] AS dd02v
WHERE 
	dd02v.DDLANGUAGE != ''E'' 
AND 
	NOT EXISTS (
		SELECT 
			1 
		FROM 
			[dm].[DD02V_Generated_Table_for_View_PROD] as dd02veng
		WHERE 
			dd02veng.DDLANGUAGE = ''E''
		AND 
			dd02veng.TABNAME = dd02v.TABNAME
)

	
' 
GO
