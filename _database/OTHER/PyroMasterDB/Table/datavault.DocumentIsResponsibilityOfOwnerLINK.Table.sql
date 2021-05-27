SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[DocumentIsResponsibilityOfOwnerLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[DocumentIsResponsibilityOfOwnerLINK](
	[DocumentIsResponsibilityOfOwnerVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[DocumentVID] [bigint] NOT NULL,
	[OwnerEmployeeVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentIsResponsibilityOfOwnerVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DocumentVID] ASC,
	[OwnerEmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DocumentVID] ASC,
	[OwnerEmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[DocumentVID] ASC,
	[OwnerEmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentI__Docum__6B6FCE9C]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentIsResponsibilityOfOwnerLINK]'))
ALTER TABLE [datavault].[DocumentIsResponsibilityOfOwnerLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentI__Docum__749A117A]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentIsResponsibilityOfOwnerLINK]'))
ALTER TABLE [datavault].[DocumentIsResponsibilityOfOwnerLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentI__Docum__77017CD9]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentIsResponsibilityOfOwnerLINK]'))
ALTER TABLE [datavault].[DocumentIsResponsibilityOfOwnerLINK]  WITH CHECK ADD FOREIGN KEY([DocumentVID])
REFERENCES [datavault].[DocumentHUB] ([DocumentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentI__Owner__6C63F2D5]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentIsResponsibilityOfOwnerLINK]'))
ALTER TABLE [datavault].[DocumentIsResponsibilityOfOwnerLINK]  WITH CHECK ADD FOREIGN KEY([OwnerEmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentI__Owner__758E35B3]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentIsResponsibilityOfOwnerLINK]'))
ALTER TABLE [datavault].[DocumentIsResponsibilityOfOwnerLINK]  WITH CHECK ADD FOREIGN KEY([OwnerEmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__DocumentI__Owner__77F5A112]') AND parent_object_id = OBJECT_ID(N'[datavault].[DocumentIsResponsibilityOfOwnerLINK]'))
ALTER TABLE [datavault].[DocumentIsResponsibilityOfOwnerLINK]  WITH CHECK ADD FOREIGN KEY([OwnerEmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
