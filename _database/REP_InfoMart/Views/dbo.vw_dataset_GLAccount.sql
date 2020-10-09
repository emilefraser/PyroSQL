SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE   VIEW [dbo].[vw_dataset_GlAccount]
AS

SELECT
	   gl.[GLAccountKey]
      ,gl.[AccountID]
      ,gl.[AccountName]
      ,gl.[AUDTUSER]
      ,gl.[ACCTTYPE]
      ,gl.[ACCTBAL]
      ,gl.[MCSW]
      ,gl.[ACCTGRPCOD]
      ,gl.[ALLOCTOT]
      ,gl.[ABRKID]
      ,gl.[ACCTFMTTD]
      ,gl.[ACSEGVAL01]
      ,gl.[ACSEGVAL02]
      ,gl.[ACSEGVAL03]
      ,gl.[ACSEGVAL04]
      ,gl.[ACSEGVAL05]
      ,gl.[ACCTSEGVAL]
      ,gl.[ACCTGRPSCD]
      ,gl.[DEFCURNCOD]
      ,gl.[OVALUES]
      ,gl.[TOVALUES]
      ,gl.[ROLLUPSW]
	  ,rh.*
  FROM [DEV_InfoMart].[dbo].[vw_DimGLAccount] AS gl
  LEFT JOIN
	DataManager_2020723.ACCESS.vw_ReportingHierarchyAccess rh
		ON rh.BusinessKey = gl.[AccountID]
		AND	  rh.ReportingHierarchyTypeName IN ( 'FRHIS' , 'FRHBS')
	

GO
