USE [MetricsVault]
GO

/****** Object:  Table [dbo].[Ensamble_Config]    Script Date: 2020/05/24 10:51:10 PM ******/
DROP TABLE [dbo].[Ensamble_Config]
GO

/****** Object:  Table [dbo].[Ensamble_Config]    Script Date: 2020/05/24 10:51:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Ensamble_Config](
	[ConfigID] [smallint] IDENTITY(1,1) NOT NULL,
	[ElementID] [smallint] NOT NULL,
	[MetricTypeID] [smallint] NOT NULL,
	[ScheduleID] [smallint] NOT NULL,
	[TimeGrainID] [smallint] NOT NULL,
	[GroupByFieldName] SYSNAME NULL,
	[CreatedDT] [datetime2](7) NOT NULL DEFAULT GETDATE(),
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL DEFAULT 1,
PRIMARY KEY CLUSTERED 
(
	[ConfigID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


