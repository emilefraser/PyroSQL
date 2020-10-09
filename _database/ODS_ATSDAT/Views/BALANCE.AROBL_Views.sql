SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE   VIEW [BALANCE].[AROBL_Views]
AS 

SELECT 
	Entity
,	AR_Difference_RC = AROBL  - ([vw_DMOD_OBLInvoice] + [vw_DMOD_OBLCreditNote] + [vw_DMOD_OBLDebitNote] +
											[vw_DMOD_OBLReceipt] + [vw_DMOD_OBLRefund] + [vw_DMOD_OBLInterest])
,	AROBL AS AROBL_RC
,	AR_Views_RC = 	[vw_DMOD_OBLInvoice] + [vw_DMOD_OBLCreditNote] + [vw_DMOD_OBLDebitNote] +
								[vw_DMOD_OBLReceipt] + [vw_DMOD_OBLRefund] + [vw_DMOD_OBLInterest]

,	[vw_DMOD_OBLInvoice] AS vw_DMOD_OBLInvoice_RC
,	[vw_DMOD_OBLCreditNote] AS vw_DMOD_OBLCreditNote_RC
,	[vw_DMOD_OBLDebitNote] AS vw_DMOD_OBLDebitNot_RC
,	[vw_DMOD_OBLReceipt] AS vw_DMOD_OBLReceipt_RC
,	[vw_DMOD_OBLRefund]  AS vw_DMOD_OBLRefund_RC
,	[vw_DMOD_OBLInterest] AS vw_DMOD_OBLInterest_RC
FROM (
	 -- Base Object (AROBL)
	SELECT 
		'Accounts Receivable' AS Entity
	,	'AROBL' AS ObjectName
	,	COUNT(1) AS Row_Count 
	FROM 
		ODS_ATSDAT.dbo.AROBL

	UNION ALL
		
	-- Invoices View
	SELECT 
		'Accounts Receivable' AS Entity
	,	'vw_DMOD_OBLInvoice' AS ObjectName
	,	COUNT(1) AS Row_Count 
	FROM 
		ODS_ATSDAT.DV.vw_dmod_OBLInvoice

	UNION ALL
		
	-- Receipts View
	SELECT 
		'Accounts Receivable' AS Entity
	,	'vw_DMOD_OBLReceipt' AS ObjectName
	,	COUNT(1) AS Row_Count 
	FROM 
		ODS_ATSDAT.DV.vw_dmod_OBLReceipt

	UNION ALL
		
	-- Credit Note View
	SELECT 
		'Accounts Receivable' AS Entity
	,	'vw_DMOD_OBLCreditNote' AS ObjectName
	,	COUNT(1) AS Row_Count 
	FROM 
		ODS_ATSDAT.DV.vw_dmod_OBLCreditNote

	UNION ALL
	
	-- Debit Note View
	SELECT 
		'Accounts Receivable' AS Entity
	,	'vw_DMOD_OBLDebitNote' AS ObjectName
	,	COUNT(1) AS Row_Count 
	FROM 
		ODS_ATSDAT.DV.vw_dmod_OBLDebitNote

	UNION ALL
		
	-- Interest View
	SELECT 
		'Accounts Receivable' AS Entity
	,	'vw_DMOD_OBLInterest' AS ObjectName
	,	COUNT(1) AS Row_Count 
	FROM 
		ODS_ATSDAT.DV.vw_dmod_OBLInterest

	UNION ALL
		
	-- Refund View
	SELECT 
		'Accounts Receivable' AS Entity
	,	'vw_DMOD_OBLRefund' AS ObjectName
	,	COUNT(1) AS Row_Count 
	FROM 
		ODS_ATSDAT.DV.vw_dmod_OBLRefund
) AS ods
PIVOT(MAX([Row_Count]) FOR [ObjectName] IN (
											[AROBL], 
											[vw_DMOD_OBLInvoice],
											[vw_DMOD_OBLCreditNote], 
											[vw_DMOD_OBLDebitNote], 
											[vw_DMOD_OBLReceipt], 
											[vw_DMOD_OBLRefund],
											[vw_DMOD_OBLInterest]
																
										)
					) AS PivotTable


GO
