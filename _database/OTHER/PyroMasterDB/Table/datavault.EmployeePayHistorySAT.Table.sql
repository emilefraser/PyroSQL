SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeePayHistorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeePayHistorySAT](
	[EmployeePayHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[PayFrequency] [tinyint] NOT NULL,
	[Rate] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeePayHistoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__03DC550A]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistorySAT]'))
ALTER TABLE [datavault].[EmployeePayHistorySAT]  WITH CHECK ADD FOREIGN KEY([EmployeePayHistoryVID])
REFERENCES [datavault].[EmployeePayHistoryHUB] ([EmployeePayHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__0643C069]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistorySAT]'))
ALTER TABLE [datavault].[EmployeePayHistorySAT]  WITH CHECK ADD FOREIGN KEY([EmployeePayHistoryVID])
REFERENCES [datavault].[EmployeePayHistoryHUB] ([EmployeePayHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__7AB2122C]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistorySAT]'))
ALTER TABLE [datavault].[EmployeePayHistorySAT]  WITH CHECK ADD FOREIGN KEY([EmployeePayHistoryVID])
REFERENCES [datavault].[EmployeePayHistoryHUB] ([EmployeePayHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeP__PayFr__77A09B57]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistorySAT]'))
ALTER TABLE [datavault].[EmployeePayHistorySAT]  WITH CHECK ADD CHECK  (([PayFrequency]=(1) OR [PayFrequency]=(2)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeP__PayFr__7CFA4D51]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistorySAT]'))
ALTER TABLE [datavault].[EmployeePayHistorySAT]  WITH CHECK ADD CHECK  (([PayFrequency]=(1) OR [PayFrequency]=(2)))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeP__PayFr__7F61B8B0]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistorySAT]'))
ALTER TABLE [datavault].[EmployeePayHistorySAT]  WITH CHECK ADD CHECK  (([PayFrequency]=(1) OR [PayFrequency]=(2)))
GO
