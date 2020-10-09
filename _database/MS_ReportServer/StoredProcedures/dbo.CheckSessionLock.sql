SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[CheckSessionLock]
@SessionID as varchar(32),
@LockVersion  int OUTPUT
AS
DECLARE @Selected nvarchar(32)
SELECT @Selected=SessionID, @LockVersion = LockVersion FROM [ReportServerTempDB].dbo.SessionLock WITH (ROWLOCK) WHERE SessionID = @SessionID
GO
