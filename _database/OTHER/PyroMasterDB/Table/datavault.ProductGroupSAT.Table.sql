SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductGroupSAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Class] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Color] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProductLineName] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Size] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SizeUnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Style] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Weight] [decimal](18, 0) NULL,
	[WeightUnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductGr__Produ__11957784]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductGr__Produ__1ABFBA62]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductGr__Produ__1D2725C1]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Class__01BF026E]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([Class]='H' OR [Class]='L' OR [Class]='M'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Class__04266DCD]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([Class]='H' OR [Class]='L' OR [Class]='M'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Class__7C655074]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([Class]='H' OR [Class]='L' OR [Class]='M'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Produ__02B326A7]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([ProductLineName]='M' OR [ProductLineName]='R' OR [ProductLineName]='S' OR [ProductLineName]='T'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Produ__051A9206]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([ProductLineName]='M' OR [ProductLineName]='R' OR [ProductLineName]='S' OR [ProductLineName]='T'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Produ__7D5974AD]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([ProductLineName]='M' OR [ProductLineName]='R' OR [ProductLineName]='S' OR [ProductLineName]='T'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Style__03A74AE0]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([Style]='M' OR [Style]='U' OR [Style]='W'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Style__060EB63F]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([Style]='M' OR [Style]='U' OR [Style]='W'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__ProductGr__Style__7E4D98E6]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductGroupSAT]'))
ALTER TABLE [datavault].[ProductGroupSAT]  WITH CHECK ADD CHECK  (([Style]='M' OR [Style]='U' OR [Style]='W'))
GO
