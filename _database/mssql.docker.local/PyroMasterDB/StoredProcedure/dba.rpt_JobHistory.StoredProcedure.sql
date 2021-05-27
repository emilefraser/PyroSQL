SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[rpt_JobHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[rpt_JobHistory] AS' 
END
GO

ALTER PROC [dba].[rpt_JobHistory] (@JobName NVARCHAR(50), @DateRangeInDays INT)
AS

/**************************************************************************************************************
**  Purpose: 
**
**  Revision History  
**  
**  Date			Author					Version				Revision  
**  ----------		--------------------	-------------		-------------
**  02/21/2012		Michael Rounds			1.2					Comments creation
***************************************************************************************************************/

BEGIN

SELECT Job_Name AS [JobName], Run_datetime AS [RunDate], run_duration AS [RunTime], CASE WHEN run_status = 1 THEN 'Sucess' WHEN run_status = 3 THEN 'Cancelled' WHEN run_status = 0 THEN 'Error' ELSE 'N/A' END AS [RunOutcome]
FROM
(SELECT job_name, run_datetime,
        SUBSTRING(run_duration, 1, 2) + ':' + SUBSTRING(run_duration, 3, 2) + ':' +
        SUBSTRING(run_duration, 5, 2) AS run_duration, run_status
    FROM
    (SELECT j.name AS job_name,
            run_datetime = CONVERT(DATETIME, RTRIM(run_date)) +  
                (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4,
            run_duration = RIGHT('000000' + CONVERT(NVARCHAR(6), run_duration), 6),
            run_status
        FROM msdb..sysjobhistory h
        JOIN msdb..sysjobs j
        ON h.job_id = j.job_id AND h.step_id = 0) t
) t
WHERE (DATEDIFF(dd,run_datetime,GETDATE())) <= @DateRangeInDays
AND job_name = @JobName
ORDER BY run_datetime DESC

END
GO
