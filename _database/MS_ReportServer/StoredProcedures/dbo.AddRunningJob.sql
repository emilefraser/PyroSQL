SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[AddRunningJob]
@JobID as nvarchar(32),
@StartDate as datetime,
@ComputerName as nvarchar(32),
@RequestName as nvarchar(425),
@RequestPath as nvarchar(425),
@UserSid varbinary(85) = NULL,
@UserName nvarchar(260),
@AuthType int,
@Description as ntext  = NULL,
@Timeout as int,
@JobAction as smallint,
@JobType as smallint,
@JobStatus as smallint
AS
SET NOCOUNT OFF
DECLARE @UserID uniqueidentifier
EXEC GetUserID @UserSid, @UserName, @AuthType, @UserID OUTPUT

INSERT INTO RunningJobs (JobID, StartDate, ComputerName, RequestName, RequestPath, UserID, Description, Timeout, JobAction, JobType, JobStatus )
VALUES             (@JobID, @StartDate, @ComputerName,  @RequestName, @RequestPath, @UserID, @Description, @Timeout, @JobAction, @JobType, @JobStatus)
GO
