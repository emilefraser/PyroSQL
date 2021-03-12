SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[LoadCdcJoin]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[LoadCdcJoin](
	[ExCdcJoinListId] [int] IDENTITY(1,1) NOT NULL,
	[LoadConfigId] [int] NOT NULL,
	[InternalColumnName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InternalConstantValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EqualityOperator] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExternalColumnName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ExternalConstantValue] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_LoadCdcJoin] PRIMARY KEY CLUSTERED 
(
	[ExCdcJoinListId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
