SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [lnd].[T006_UOM](
	[MANDT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MSEHI] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KZEX3] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KZEX6] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ANDEC] [smallint] NULL,
	[KZKEH] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KZWOB] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KZ1EH] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KZ2EH] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DIMID] [nvarchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ZAEHL] [int] NULL,
	[NENNR] [int] NULL,
	[EXP10] [smallint] NULL,
	[ADDKO] [numeric](11, 6) NULL,
	[EXPON] [smallint] NULL,
	[DECAN] [smallint] NULL,
	[ISOCODE] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRIMARY] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TEMP_VALUE] [float] NULL,
	[TEMP_UNIT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FAMUNIT] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRESS_VAL] [float] NULL,
	[PRESS_UNIT] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
