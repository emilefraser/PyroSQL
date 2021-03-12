USE [MetricsVault]
GO

/****** Object:  Table [dbo].[Ensamble_Log]    Script Date: 2020/05/27 7:09:54 AM ******/
DROP TABLE [dbo].[Ensamble_Log]
GO

/****** Object:  Table [dbo].[Ensamble_Log]    Script Date: 2020/05/27 7:09:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Ensamble_Log](
	[LogID]						BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[MetricProcedureCalled]		SYSNAME NOT NULL,
	[ConfigID]					SMALLINT NOT NULL,
	[LogStatusTypeID]			TINYINT NOT NULL,
	[CreatedDT]					DATETIME2(7) NOT NULL
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[Ensamble_LogStatusType](
	[LogStatusTypeID]			TINYINT NOT NULL PRIMARY KEY,
	[LogStatusTypeCode]			VARCHAR(30) NOT NULL,
	[LogStatusTypeDescription]	VARCHAR(100) NULL,
	[CreatedDT]					DATETIME2(7) NOT NULL DEFAULT GETDATE(),
	[UpdatedDT]					DATETIME2(7) NULL,
	[IsActive]					BIT NOT NULL DEFAULT 1
) ON [PRIMARY]
GO

