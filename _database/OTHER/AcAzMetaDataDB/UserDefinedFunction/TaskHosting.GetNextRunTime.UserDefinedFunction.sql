SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetNextRunTime]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- create function to calculate the next run time of the schedule.

CREATE FUNCTION [TaskHosting].[GetNextRunTime]
    (@ScheduleId int)
    RETURNS DateTime
AS
BEGIN

DECLARE @type int
DECLARE @interval int

SELECT @Type = s.FreqType, @interval = s.FreqInterval
FROM TaskHosting.Schedule AS s
WHERE s.ScheduleId = @ScheduleId

IF (@@ROWCOUNT <= 0)
BEGIN
    return cast(''No Such an ID.'' as int);
END

DECLARE @NextRunTime DATETIME
IF (@Type = 2)
BEGIN
    SET @NextRunTime=DATEADD(SECOND, @interval, GETUTCDate())
END
ELSE IF (@Type = 4)
BEGIN
    SET @NextRunTime=DATEADD(MINUTE, @interval, GETUTCDate())
END
ELSE IF (@Type=8)
BEGIN
    SET @NextRunTime=DATEADD(HOUR, @interval, GETUTCDate())
END
ELSE
BEGIN
    return cast(''No Such an type.'' as int);
END


RETURN @NextRunTime


END



' 
END
GO
