SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[LinkSystemServerTypeServer](
	[LinkSystemServerTypeServerID] [int] IDENTITY(1,1) NOT NULL,
	[SystemID] [int] NOT NULL,
	[ServerID] [int] NOT NULL,
	[ServerTypeID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
