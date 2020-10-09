SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE     VIEW [DV].[vw_DMOD_CreditNoteAppliedToInvoice]
AS 
  SELECT 
	  obp.IDINVC
	, obp.CNTBTCH
	, obp.CNTITEM
	, obp.IDMEMOXREF
	, DEV_InfoMart.dbo.udf_convertDate_Sage300_UTC(obp.AUDTDATE) AS CreditNoteDate
	, obp.IDCUST AS Customer
  FROM 
	[ODS_ATSDAT].[dbo].[AROBP] AS obp
  left join 
	[ODS_ATSDAT].CUST.TransactionType as trx
	on trx.TRXTYPEID = obp.TRXTYPE
  left join 
	[ODS_ATSDAT].CUST.DocumentType AS tt
  ON 
	tt.TRXTYPETEXTID = obp.TRANSTYPE
  WHERE 
	tt.TRXTYPETEXTID  = 8
  AND 
	SUBSTRING(obp.IDINVC,1,2) IN ('IN')
AND		obp.IDCUST = 'KEV100'

GO
