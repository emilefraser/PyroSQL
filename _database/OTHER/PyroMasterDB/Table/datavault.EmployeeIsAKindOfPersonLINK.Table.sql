SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeeIsAKindOfPersonLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeeIsAKindOfPersonLINK](
	[EmployeeIsAKindOfPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeIsAKindOfPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeI__Emplo__000BC426]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeIsAKindOfPersonLINK]'))
ALTER TABLE [datavault].[EmployeeIsAKindOfPersonLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeI__Emplo__02732F85]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeIsAKindOfPersonLINK]'))
ALTER TABLE [datavault].[EmployeeIsAKindOfPersonLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeI__Emplo__76E18148]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeIsAKindOfPersonLINK]'))
ALTER TABLE [datavault].[EmployeeIsAKindOfPersonLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeI__Perso__00FFE85F]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeIsAKindOfPersonLINK]'))
ALTER TABLE [datavault].[EmployeeIsAKindOfPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeI__Perso__036753BE]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeIsAKindOfPersonLINK]'))
ALTER TABLE [datavault].[EmployeeIsAKindOfPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeI__Perso__77D5A581]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeIsAKindOfPersonLINK]'))
ALTER TABLE [datavault].[EmployeeIsAKindOfPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
