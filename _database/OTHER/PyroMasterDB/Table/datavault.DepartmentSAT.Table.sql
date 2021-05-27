SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[DepartmentSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[DepartmentSAT](
	[DepartmentVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[GroupName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DepartmentVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Departmen__Depar__689361F1]') AND parent_object_id = OBJECT_ID(N'[datavault].[DepartmentSAT]'))
ALTER TABLE [datavault].[DepartmentSAT]  WITH CHECK ADD FOREIGN KEY([DepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Departmen__Depar__71BDA4CF]') AND parent_object_id = OBJECT_ID(N'[datavault].[DepartmentSAT]'))
ALTER TABLE [datavault].[DepartmentSAT]  WITH CHECK ADD FOREIGN KEY([DepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__Departmen__Depar__7425102E]') AND parent_object_id = OBJECT_ID(N'[datavault].[DepartmentSAT]'))
ALTER TABLE [datavault].[DepartmentSAT]  WITH CHECK ADD FOREIGN KEY([DepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
