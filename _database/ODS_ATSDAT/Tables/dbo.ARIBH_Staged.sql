SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ARIBH_Staged](
	[CNTBTCH] [decimal](9, 0) NOT NULL,
	[CNTITEM] [decimal](7, 0) NOT NULL,
	[AUDTDATE] [decimal](9, 0) NOT NULL,
	[AUDTTIME] [decimal](9, 0) NOT NULL,
	[AUDTUSER] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AUDTORG] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDCUST] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDINVC] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDSHPT] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHIPVIA] [char](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SPECINST] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TEXTTRX] [smallint] NOT NULL,
	[IDTRX] [smallint] NOT NULL,
	[INVCSTTS] [smallint] NOT NULL,
	[ORDRNBR] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CUSTPO] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[JOBNBR] [char](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[INVCDESC] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWPRTINVC] [smallint] NOT NULL,
	[INVCAPPLTO] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDACCTSET] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DATEINVC] [decimal](9, 0) NOT NULL,
	[DATEASOF] [decimal](9, 0) NOT NULL,
	[FISCYR] [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FISCPER] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODECURN] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RATETYPE] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWMANRTE] [smallint] NOT NULL,
	[EXCHRATEHC] [decimal](15, 7) NOT NULL,
	[ORIGRATEHC] [decimal](15, 7) NOT NULL,
	[TERMCODE] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWTERMOVRD] [smallint] NOT NULL,
	[DATEDUE] [decimal](9, 0) NOT NULL,
	[DATEDISC] [decimal](9, 0) NOT NULL,
	[PCTDISC] [decimal](9, 5) NOT NULL,
	[AMTDISCAVL] [decimal](19, 3) NOT NULL,
	[LASTLINE] [decimal](5, 0) NOT NULL,
	[CODESLSP1] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODESLSP2] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODESLSP3] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODESLSP4] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODESLSP5] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PCTSASPLT1] [decimal](9, 5) NOT NULL,
	[PCTSASPLT2] [decimal](9, 5) NOT NULL,
	[PCTSASPLT3] [decimal](9, 5) NOT NULL,
	[PCTSASPLT4] [decimal](9, 5) NOT NULL,
	[PCTSASPLT5] [decimal](9, 5) NOT NULL,
	[SWTAXBL] [smallint] NOT NULL,
	[SWMANTX] [smallint] NOT NULL,
	[CODETAXGRP] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODETAX1] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODETAX2] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODETAX3] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODETAX4] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CODETAX5] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TAXSTTS1] [smallint] NOT NULL,
	[TAXSTTS2] [smallint] NOT NULL,
	[TAXSTTS3] [smallint] NOT NULL,
	[TAXSTTS4] [smallint] NOT NULL,
	[TAXSTTS5] [smallint] NOT NULL,
	[BASETAX1] [decimal](19, 3) NOT NULL,
	[BASETAX2] [decimal](19, 3) NOT NULL,
	[BASETAX3] [decimal](19, 3) NOT NULL,
	[BASETAX4] [decimal](19, 3) NOT NULL,
	[BASETAX5] [decimal](19, 3) NOT NULL,
	[AMTTAX1] [decimal](19, 3) NOT NULL,
	[AMTTAX2] [decimal](19, 3) NOT NULL,
	[AMTTAX3] [decimal](19, 3) NOT NULL,
	[AMTTAX4] [decimal](19, 3) NOT NULL,
	[AMTTAX5] [decimal](19, 3) NOT NULL,
	[AMTTXBL] [decimal](19, 3) NOT NULL,
	[AMTNOTTXBL] [decimal](19, 3) NOT NULL,
	[AMTTAXTOT] [decimal](19, 3) NOT NULL,
	[AMTINVCTOT] [decimal](19, 3) NOT NULL,
	[AMTPPD] [decimal](19, 3) NOT NULL,
	[AMTPAYMTOT] [decimal](5, 0) NOT NULL,
	[AMTPYMSCHD] [decimal](19, 3) NOT NULL,
	[AMTNETTOT] [decimal](19, 3) NOT NULL,
	[IDSTDINVC] [char](16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DATEPRCS] [decimal](9, 0) NOT NULL,
	[IDPPD] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDBILL] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOLOC] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOSTE1] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOSTE2] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOSTE3] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOSTE4] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOCITY] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOSTTE] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOPOST] [char](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOCTRY] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOCTAC] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOPHON] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPTOFAX] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DATERATE] [decimal](9, 0) NOT NULL,
	[SWPROCPPD] [smallint] NOT NULL,
	[CUROPER] [smallint] NOT NULL,
	[DRILLAPP] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DRILLTYPE] [smallint] NOT NULL,
	[DRILLDWNLK] [decimal](19, 0) NOT NULL,
	[SHPVIACODE] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SHPVIADESC] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWJOB] [smallint] NOT NULL,
	[ERRBATCH] [int] NOT NULL,
	[ERRENTRY] [int] NOT NULL,
	[EMAIL] [char](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CTACPHONE] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CTACFAX] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CTACEMAIL] [char](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AMTDSBWTAX] [decimal](19, 3) NOT NULL,
	[AMTDSBNTAX] [decimal](19, 3) NOT NULL,
	[AMTDSCBASE] [decimal](19, 3) NOT NULL,
	[INVCTYPE] [smallint] NOT NULL,
	[SWRTGINVC] [smallint] NOT NULL,
	[RTGAPPLYTO] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWRTG] [smallint] NOT NULL,
	[RTGAMT] [decimal](19, 3) NOT NULL,
	[RTGPERCENT] [decimal](9, 5) NOT NULL,
	[RTGDAYS] [smallint] NOT NULL,
	[RTGDATEDUE] [decimal](9, 0) NOT NULL,
	[RTGTERMS] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWRTGDDTOV] [smallint] NOT NULL,
	[SWRTGAMTOV] [smallint] NOT NULL,
	[SWRTGRATE] [smallint] NOT NULL,
	[VALUES] [int] NOT NULL,
	[SRCEAPPL] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ARVERSION] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TAXVERSION] [int] NOT NULL,
	[SWTXRTGRPT] [smallint] NOT NULL,
	[CODECURNRC] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWTXCTLRC] [smallint] NOT NULL,
	[RATERC] [decimal](15, 7) NOT NULL,
	[RATETYPERC] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RATEDATERC] [decimal](9, 0) NOT NULL,
	[RATEOPRC] [smallint] NOT NULL,
	[SWRATERC] [smallint] NOT NULL,
	[TXAMT1RC] [decimal](19, 3) NOT NULL,
	[TXAMT2RC] [decimal](19, 3) NOT NULL,
	[TXAMT3RC] [decimal](19, 3) NOT NULL,
	[TXAMT4RC] [decimal](19, 3) NOT NULL,
	[TXAMT5RC] [decimal](19, 3) NOT NULL,
	[TXTOTRC] [decimal](19, 3) NOT NULL,
	[TXBSERT1TC] [decimal](19, 3) NOT NULL,
	[TXBSERT2TC] [decimal](19, 3) NOT NULL,
	[TXBSERT3TC] [decimal](19, 3) NOT NULL,
	[TXBSERT4TC] [decimal](19, 3) NOT NULL,
	[TXBSERT5TC] [decimal](19, 3) NOT NULL,
	[TXAMTRT1TC] [decimal](19, 3) NOT NULL,
	[TXAMTRT2TC] [decimal](19, 3) NOT NULL,
	[TXAMTRT3TC] [decimal](19, 3) NOT NULL,
	[TXAMTRT4TC] [decimal](19, 3) NOT NULL,
	[TXAMTRT5TC] [decimal](19, 3) NOT NULL,
	[TXBSE1HC] [decimal](19, 3) NOT NULL,
	[TXBSE2HC] [decimal](19, 3) NOT NULL,
	[TXBSE3HC] [decimal](19, 3) NOT NULL,
	[TXBSE4HC] [decimal](19, 3) NOT NULL,
	[TXBSE5HC] [decimal](19, 3) NOT NULL,
	[TXAMT1HC] [decimal](19, 3) NOT NULL,
	[TXAMT2HC] [decimal](19, 3) NOT NULL,
	[TXAMT3HC] [decimal](19, 3) NOT NULL,
	[TXAMT4HC] [decimal](19, 3) NOT NULL,
	[TXAMT5HC] [decimal](19, 3) NOT NULL,
	[AMTGROSHC] [decimal](19, 3) NOT NULL,
	[RTGAMTHC] [decimal](19, 3) NOT NULL,
	[AMTDISCHC] [decimal](19, 3) NOT NULL,
	[DISTNETHC] [decimal](19, 3) NOT NULL,
	[AMTPPDHC] [decimal](19, 3) NOT NULL,
	[AMTDUEHC] [decimal](19, 3) NOT NULL,
	[SWPRTLBL] [smallint] NOT NULL,
	[IDSHIPNBR] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWOECOST] [smallint] NOT NULL,
	[ENTEREDBY] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DATEBUS] [decimal](9, 0) NOT NULL,
	[EDN] [char](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO