SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [CQ].[AccumulatorsAPI](
	[Id] [int] NULL,
	[DateTimeCreated] [datetime] NULL,
	[DateTimeChanged] [datetime] NULL,
	[IsDeleted] [int] NULL,
	[Asset] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EngineHours] [real] NULL,
	[RecordedTimeUTCps2] [datetime] NULL,
	[DrillHours] [real] NULL,
	[DrillMeters] [real] NULL,
	[DrillHoleCount] [real] NULL,
	[TrammingHours] [real] NULL,
	[FuelLitresUsed] [real] NULL
) ON [PRIMARY]

GO
