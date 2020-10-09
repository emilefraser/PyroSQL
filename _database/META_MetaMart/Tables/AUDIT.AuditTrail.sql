SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [AUDIT].[AuditTrail](
	[AuditTrailID] [int] IDENTITY(1,1) NOT NULL,
	[AuditData] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MasterEntity] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TableName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PrimaryKeyID] [int] NULL,
	[TransactionAction] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionDT] [datetime2](7) NULL,
	[TransactionPerson] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
