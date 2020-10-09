SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[AUFK_order_master](
	[MANDT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUFNR] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUART] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUTYP] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REFNR] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ERNAM] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ERDAT] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AENAM] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AEDAT] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KTEXT] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LTEXT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BUKRS] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WERKS] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GSBER] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KOKRS] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CCKEY] [nvarchar](23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KOSTV] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[STORT] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SOWRK] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ASTKZ] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WAERS] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ASTNR] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[STDAT] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ESTNR] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PHAS0] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PHAS1] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PHAS2] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PHAS3] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PDAT1] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PDAT2] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PDAT3] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IDAT1] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IDAT2] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IDAT3] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OBJID] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VOGRP] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOEKZ] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PLGKZ] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KVEWE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KAPPL] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KALSM] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ZSCHL] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ABKRS] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KSTAR] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KOSTL] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SAKNR] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SETNM] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CYCLE] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SDATE] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SEQNR] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER0] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER1] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER2] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER3] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER4] [numeric](14, 2) NULL,
	[USER5] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER6] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER7] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER8] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[USER9] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OBJNR] [nvarchar](22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRCTR] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PSPEL] [nvarchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AWSLS] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ABGSL] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TXJCD] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FUNC_AREA] [nvarchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SCOPE] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PLINT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KDAUF] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KDPOS] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUFEX] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IVPRO] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOGSYSTEM] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FLG_MLTPS] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ABUKR] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AKSTL] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SIZECL] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IZWEK] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UMWKZ] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KSTEMPF] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ZSCHM] [nvarchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PKOSA] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ANFAUFNR] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PROCNR] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PROTY] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RSORD] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BEMOT] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ADRNRA] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ERFZEIT] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AEZEIT] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CSTG_VRNT] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[COSTESTNR] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VERAA_USER] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EEW_AUFK_PS_DUMMY] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VNAME] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RECID] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ETYPE] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OTYPE] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JV_JIBCL] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JV_JIBSA] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JV_OCO] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CPD_UPDAT] [numeric](19, 0) NULL,
	[/CUM/INDCU] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/CUM/CMNUM] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/CUM/AUEST] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/CUM/DESNUM] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/PL_STRU_ID] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/PL_MAN_TYP] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/ORDER_PROB] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/ACT_TYPE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/INIT_DONE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/DATACHANGE] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/SALES_ORG] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[/MRSS/NW_BOOKED] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AD01PROFNR] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VAPLZ] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WAWRK] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FERC_IND] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OIHANTYP] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CLAIM_CONTROL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UPDATE_NEEDED] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UPDATE_CONTROL] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO