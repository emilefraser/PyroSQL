/**********************************************************************/
    -- Gets all the jobs and the details around those jobs
/**********************************************************************/
SELECT 
    j.job_id
,   j.name
,   j.description
,   j.enabled
,   j.owner_sid
,   j.version_number
,   j.category_id
,   j.date_created
FROM 
    msdb.dbo.sysjobs j
ORDER BY 
    j.name
