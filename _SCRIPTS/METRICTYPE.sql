USE [MetricsVault]
GO

drop table [dbo].[Ensamble_MetricType]

/****** Object:  Table [dbo].[Ensamble_MetricType]    Script Date: 2020/05/24 5:53:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Ensamble_MetricType](
	[MetricTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[MetricTypeCode] [varchar](30) NOT NULL,
	[MetricTypeName] [sysname] NULL,
	[CreatedDT] DATETIME2(7) NOT NULL DEFAULT GETDATE(),
	[UpdatedDT] DATETIME2(7) NULL,
	[IsActive] BIT NOT NULL DEFAULT 1
) ON [PRIMARY]
GO


INSERT INTO  [dbo].[Ensamble_MetricType] ([MetricTypeCode], [MetricTypeName])
VALUES ('RC', 'Row Count'),
('ARC', 'Acive Row Count'),
('LASTLOAD', 'Last Load Date'),
('LASTDP', 'Last Data Point Date'),


