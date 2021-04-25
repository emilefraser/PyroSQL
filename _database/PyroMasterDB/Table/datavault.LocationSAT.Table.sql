SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[LocationSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[LocationSAT](
	[LocationVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Availability] [decimal](18, 0) NOT NULL,
	[CostRate] [smallmoney] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LocationVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__LocationS__Locat__015F0FBB]') AND parent_object_id = OBJECT_ID(N'[datavault].[LocationSAT]'))
ALTER TABLE [datavault].[LocationSAT]  WITH CHECK ADD FOREIGN KEY([LocationVID])
REFERENCES [datavault].[LocationHUB] ([LocationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__LocationS__Locat__0A895299]') AND parent_object_id = OBJECT_ID(N'[datavault].[LocationSAT]'))
ALTER TABLE [datavault].[LocationSAT]  WITH CHECK ADD FOREIGN KEY([LocationVID])
REFERENCES [datavault].[LocationHUB] ([LocationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__LocationS__Locat__0CF0BDF8]') AND parent_object_id = OBJECT_ID(N'[datavault].[LocationSAT]'))
ALTER TABLE [datavault].[LocationSAT]  WITH CHECK ADD FOREIGN KEY([LocationVID])
REFERENCES [datavault].[LocationHUB] ([LocationVID])
GO
