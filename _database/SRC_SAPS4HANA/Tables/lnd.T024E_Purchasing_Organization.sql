SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[T024E_Purchasing_Organization](
	[MANDT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EKORG] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EKOTX] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BUKRS] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TXADR] [nvarchar](70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TXKOP] [nvarchar](70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TXFUS] [nvarchar](70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TXGRU] [nvarchar](70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KALSE] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MKALS] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BPEFF] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BUKRS_NTR] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
