SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[CountMessages]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[CountMessages] AS' 
END
GO

ALTER PROCEDURE [TaskHosting].[CountMessages]
AS
BEGIN
SELECT COUNT([MessageId]) FROM TaskHosting.MessageQueue
END

GO
