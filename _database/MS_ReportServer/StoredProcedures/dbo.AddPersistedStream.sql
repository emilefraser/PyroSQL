SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddPersistedStream]
@SessionID varchar(32),
@Index int
AS

DECLARE @RefCount int
DECLARE @id varchar(32)
DECLARE @ExpirationDate datetime

set @RefCount = 0
set @ExpirationDate = DATEADD(day, 2, GETDATE())

set @id = (select SessionID from [ReportServerTempDB].dbo.SessionData where SessionID = @SessionID)

if @id is not null
begin
set @RefCount = 1
end

INSERT INTO [ReportServerTempDB].dbo.PersistedStream (SessionID, [Index], [RefCount], [ExpirationDate]) VALUES (@SessionID, @Index, @RefCount, @ExpirationDate)
GO
