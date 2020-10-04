USE MsAdmin
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dba')
BEGIN
	EXEC('CREATE SCHEMA dba')
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[DatabaseQueue]') AND type in (N'U'))
BEGIN
CREATE TABLE [dba].[DatabaseQueue](
  [QueueID] [bigint] NOT NULL,
  [DatabaseName] [sysname] NOT NULL,
  [DatabaseOrder] [int] NULL,
  [DatabaseStartTime] datetime2(7) NULL,
  [DatabaseEndTime] datetime2(7) NULL,
  [SessionID] [smallint] NULL,
  [RequestID] [int] NULL,
  [RequestStartTime] datetime2(7) NULL,
 CONSTRAINT [PK_DatabaseQueue] PRIMARY KEY CLUSTERED
(
  [QueueID] ASC,
  [DatabaseName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dba].[FK_DatabaseQueue_CommandQueue]') AND parent_object_id = OBJECT_ID(N'[dba].[DatabaseQueue]'))
ALTER TABLE [dba].[DatabaseQueue]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseQueue_Queue] FOREIGN KEY([QueueID])
REFERENCES [dba].[CommandQueue] ([QueueID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dba].[FK_DatabaseQueue_CommandQueue]') AND parent_object_id = OBJECT_ID(N'[dba].[DatabaseQueue]'))
ALTER TABLE [dba].[DatabaseQueue] CHECK CONSTRAINT [FK_DatabaseQueue_Queue]
GO

