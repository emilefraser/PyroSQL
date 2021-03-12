SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LoadPhase]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LoadPhase](
	[PhaseId] [int] IDENTITY(0,1) NOT NULL,
	[PhaseName] [varchar](225) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PhaseDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PhaseOrder] [smallint] NULL,
	[SourceSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TargetSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_LoadPhase] PRIMARY KEY CLUSTERED 
(
	[PhaseId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
