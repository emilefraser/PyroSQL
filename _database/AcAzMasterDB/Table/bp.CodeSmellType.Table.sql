SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bp].[CodeSmellType]') AND type in (N'U'))
BEGIN
CREATE TABLE [bp].[CodeSmellType](
	[SmellTypeID] [int] IDENTITY(0,1) NOT NULL,
	[SmellTypeCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SmellTypeDecription] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SmellSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime] NOT NULL,
	[UpdatedDT] [datetime] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[bp].[DF__CodeSmell__IsAct__151B244E]') AND type = 'D')
BEGIN
ALTER TABLE [bp].[CodeSmellType] ADD  DEFAULT ((1)) FOR [IsActive]
END
GO
