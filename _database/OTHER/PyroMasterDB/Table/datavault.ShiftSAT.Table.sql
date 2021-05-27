SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ShiftSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ShiftSAT](
	[ShiftVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartTime] [time](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ShiftVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShiftSAT__ShiftV__5BF880E2]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShiftSAT]'))
ALTER TABLE [datavault].[ShiftSAT]  WITH CHECK ADD FOREIGN KEY([ShiftVID])
REFERENCES [datavault].[ShiftHUB] ([ShiftVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShiftSAT__ShiftV__6522C3C0]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShiftSAT]'))
ALTER TABLE [datavault].[ShiftSAT]  WITH CHECK ADD FOREIGN KEY([ShiftVID])
REFERENCES [datavault].[ShiftHUB] ([ShiftVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ShiftSAT__ShiftV__678A2F1F]') AND parent_object_id = OBJECT_ID(N'[datavault].[ShiftSAT]'))
ALTER TABLE [datavault].[ShiftSAT]  WITH CHECK ADD FOREIGN KEY([ShiftVID])
REFERENCES [datavault].[ShiftHUB] ([ShiftVID])
GO
