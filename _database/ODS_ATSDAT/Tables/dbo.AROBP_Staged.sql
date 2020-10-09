SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AROBP_Staged](
	[IDCUST] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDINVC] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CNTPAYMNBR] [decimal](5, 0) NOT NULL,
	[IDRMIT] [char](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DATEBUS] [decimal](9, 0) NOT NULL,
	[TRANSTYPE] [smallint] NOT NULL,
	[CNTSEQNCE] [decimal](5, 0) NOT NULL,
	[AUDTDATE] [decimal](9, 0) NOT NULL,
	[AUDTTIME] [decimal](9, 0) NOT NULL,
	[AUDTUSER] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AUDTORG] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DEPSTNBR] [decimal](9, 0) NOT NULL,
	[CNTBTCH] [decimal](9, 0) NOT NULL,
	[DATEBTCH] [decimal](9, 0) NOT NULL,
	[AMTPAYMHC] [decimal](19, 3) NOT NULL,
	[AMTPAYMTC] [decimal](19, 3) NOT NULL,
	[CODECURN] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDRATETYPE] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RATEEXCHHC] [decimal](15, 7) NOT NULL,
	[SWOVRDRATE] [smallint] NOT NULL,
	[IDBANK] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TRXTYPE] [smallint] NOT NULL,
	[IDMEMOXREF] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SWINVCDEL] [smallint] NOT NULL,
	[DATELSTSTM] [decimal](9, 0) NOT NULL,
	[IDPREPAID] [char](22) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IDCUSTRMIT] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DATERMIT] [decimal](9, 0) NOT NULL,
	[CNTITEM] [decimal](7, 0) NOT NULL,
	[FISCYR] [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FISCPER] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RATEDATE] [decimal](9, 0) NOT NULL,
	[RATEOP] [smallint] NOT NULL,
	[STMTSEQ] [int] NOT NULL,
	[PYMCUID] [int] NOT NULL,
	[DEPSEQ] [int] NOT NULL,
	[DEPLINE] [int] NOT NULL
) ON [PRIMARY]

GO