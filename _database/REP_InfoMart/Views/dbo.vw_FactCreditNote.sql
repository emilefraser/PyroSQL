SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE VIEW [dbo].[vw_FactCreditNote]
AS
	SELECT
		--KEYS
		[si_hub].[HK_CreditNOte]		AS [DocumentKey]
		,'Credit Note'					AS [DocumentType]

		--MEASURES 
	  , [si_sat].[AMTTAX1HC]		AS [TaxBase]
	  , [si_sat].[AMTTAX1HC]		AS [TaxAmount]	--what is the difference? 
	  , [si_sat].[AMTTAX1HC]		AS [TaxableAmount]
	  , [si_sat].[AMTTAX1HC]		AS [TaxTotal]
	  , [si_sat].[AMTINVCHC]		AS [CreditNoteTotalBeforeTax]
	  , [si_sat].[AMTDUEHC]			AS [CreditNoteTotalAfterTax]

		--ATTRIBUTES 
	  , [si_hub].[CreditNoteNumber]		AS [CreditNoteNumber]
	  , [c_hub].[CustomerID]			AS [CustomerNumber]

	  , CASE
			WHEN [si_sat].[OBL_AUDTDATE] > 0
				THEN CONVERT(DATETIME, CONVERT(CHAR(8), [si_sat].[OBL_AUDTDATE]), 112)
				ELSE NULL
		END AS [AUDTDATE]

	  , [si_sat].[OBL_AUDTUSER] AS [AuditUser]
	  , [si_sat].[IDORDERNBR] AS [OrderNumber]

	  , CASE
			WHEN [si_sat].[DATEINVC] > 0
				THEN CONVERT(DATETIME, CONVERT(CHAR(8), [si_sat].[DATEINVC]), 112)
			ELSE NULL
		END AS [CreditNoteDate]

	  , DATEDIFF(DAY, TRY_CONVERT(DATETIME, CONVERT(CHAR(8), [si_sat].[DATEINVC])), GETDATE()) AS [DaysSinceLastCreditNote]

	  , [si_sat].[FISCYR] AS [FiscalYear]
	  , [si_sat].[FISCPER] AS [FiscalPeriod]
	  , [si_sat].[CODECURN] AS [Currency]
	  , [si_sat].[EXCHRATEHC] AS [ExchangeRate]

	  , CASE
			WHEN [si_sat].[DATEDUE] > 0
				THEN CONVERT(DATETIME, CONVERT(CHAR(8), [si_sat].[DATEDUE]), 112)
				ELSE NULL
		END AS [DateDue]

	  , CASE
			WHEN si_sat.RATEDATE > 0
				THEN CONVERT(DATETIME, CONVERT(CHAR(8), [si_sat].RATEDATE), 112)
				ELSE NULL
		END AS [RateDate]

	FROM
		--HUB
		[DEV_DataVault].[raw].[HUB_CreditNote] AS si_hub

		--SAT
	LEFT JOIN
		[DEV_DataVault].[raw].[SAT_CreditNote_ATS_LVD] AS si_sat
	ON
		si_sat.HK_CreditNote = si_hub.HK_CREDITNOTE
		AND si_sat.LoadEndDT IS NULL

		--LINK TO CUSTOMER
	LEFT JOIN
		[DEV_DataVault].[raw].[LINK_Customer_CreditNote] AS c_si_link
		ON si_hub.HK_CREDITNOTE = c_si_link.HK_CreditNote
	
	LEFT JOIN
		[DEV_DataVault].[raw].[HUB_Customer] AS c_hub
		ON c_si_link.HK_Customer = c_hub.HK_CUSTOMER



GO
