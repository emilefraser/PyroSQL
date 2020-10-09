SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[LinkDatabaseTechnologyTypeToDatabaseTypeFieldOptions](
	[LinkTechnologyTypeToDatabaseTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseTechnologyTypeID] [int] NOT NULL,
	[DatabaseTypeFieldOptionsID] [int] NOT NULL
) ON [PRIMARY]

GO
