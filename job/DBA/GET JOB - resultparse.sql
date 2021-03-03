DECLARE @cnt TINYINT

CREATE TABLE ##JobMessage(
  JobMessage VARCHAR(MAX)
)

;WITH JobEm AS(
  SELECT h.message JobMessage
    , CONVERT(DATE,CONVERT(VARCHAR(10),h.run_date)) JobDate
  FROM msdb.dbo.sysjobhistory h
    	INNER JOIN msdb.dbo.sysjobs j ON j.job_id = h.job_id
  -- Edit the value below this
  WHERE j.name = 'JOBNAME'
    AND h.step_name <> '(Job outcome)'
)
INSERT INTO ##JobMessage
SELECT JobMessage
FROM JobEm
-- Edit
WHERE JobMessage LIKE '%%'
  AND JobDate BETWEEN DATEADD(DD,-1,GETDATE()) AND GETDATE()
ORDER BY JobDate

SELECT @cnt = COUNT(JobMessage) FROM ##JobMessage

IF @cnt > 0
BEGIN

  -- Auto Em

END
