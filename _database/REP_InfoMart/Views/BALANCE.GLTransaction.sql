SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE   VIEW [BALANCE].[GLTransaction]
AS

SELECT 
	'GLTransaction' AS Perspective
,	gl.AccountID
,	dgl.FiscalYearMonthValue
,	vgl.SUM_GLTransaction
,	dgl.SUM_FactGLFiscalSet
FROM
	dbo.vw_dataset_GLAccount AS gl
LEFT JOIN (
	SELECT 
		'GLTransaction' AS Perspective
	,	AccountID AS AccountID
	,	FiscalYearMonth AS FiscalYearMonthValue
	,	SUM(TRANSAMT) AS SUM_GLTransaction
	FROM 
		dbo.vw_FactGLTransactions
	GROUP BY 
		AccountID, FiscalYearMonth
) AS vgl 
ON gl.AccountID = vgl.AccountID
LEFT JOIN (
	
	SELECT 
		'GLTransaction' AS Perspective
	,	AccountID AS AccountID
	,	FiscalYearMonthValue AS FiscalYearMonthValue
	,	SUM(TRANSAMOUNT) AS SUM_FactGLFiscalSet
	FROM 
		dbo.vw_FactGLFiscalSet
	WHERE
		FiscalSetDesignator = 'A'
	AND
		CurrencyType = 'F'
	GROUP BY 
		AccountID, FiscalYearMonthValue

) AS dgl
ON vgl.Perspective = dgl.Perspective
AND vgl.AccountID = dgl.AccountID
AND vgl.FiscalYearMonthValue = dgl.FiscalYearMonthValue
WHERE 
	vgl.SUM_GLTransaction != dgl.SUM_FactGLFiscalSet

GO
