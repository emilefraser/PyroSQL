SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[SystemType]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[SystemType](
	[SystemTypeID] [int] IDENTITY(0,1) NOT NULL,
	[SystemCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SystemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProviderID] [int] NOT NULL,
	[TechnologyTypeID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
 CONSTRAINT [PK__SystemTy__875754760F847424] PRIMARY KEY CLUSTERED 
(
	[SystemTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
