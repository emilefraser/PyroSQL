SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dba')
BEGIN
	EXEC('CREATE SCHEMA dba')
END


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[CommandQueue]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[CommandQueue](
  [QueueID] [bigint] IDENTITY(1,1) NOT NULL,
  [SchemaName] [sysname] NOT NULL,
  [ObjectName] [sysname] NOT NULL,
  [Parameters] [nvarchar](max) NOT NULL,
  [QueueStartTime] datetime2(7) 
  NULL,
  [SessionID] [smallint] NULL,
  [RequestID] [int] NULL,
  [RequestStartTime] datetime2(7) NULL,
 CONSTRAINT [PK_CommandQueue] PRIMARY KEY CLUSTERED
(
  [QueueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
END
GO

