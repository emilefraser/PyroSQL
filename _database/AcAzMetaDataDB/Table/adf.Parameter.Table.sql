SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[Parameter]') AND type in (N'U'))
BEGIN
CREATE TABLE [adf].[Parameter](
	[ParameterId] [int] IDENTITY(0,1) NOT NULL,
	[PipelineId] [int] NOT NULL,
	[ParameterName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterType] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterValue] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Parameter] PRIMARY KEY CLUSTERED 
(
	[ParameterId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
