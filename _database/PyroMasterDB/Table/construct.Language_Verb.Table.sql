SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[Language_Verb]') AND type in (N'U'))
BEGIN
CREATE TABLE [construct].[Language_Verb](
	[VerbId] [int] IDENTITY(0,1) NOT NULL,
	[VerbName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VerbAliasPrefix] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VerbRegex] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VerbType] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VerbGroup] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VerbDescription] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VerbId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [construct].[Language_Verb_History] )
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DF__Language___IsAct__2AC04CAA]') AND type = 'D')
BEGIN
ALTER TABLE [construct].[Language_Verb] ADD  DEFAULT ((1)) FOR [IsActive]
END
GO
