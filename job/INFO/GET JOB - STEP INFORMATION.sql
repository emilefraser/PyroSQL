USE msdb

SELECT J.job_id
    , J.name
    , S.step_name
    , S.step_id 
    , P.name AS ProxyName
    , SP.name AS CredentialUserName
    , SP.type_desc AS CredentialUserType
FROM msdb.dbo.sysjobs J
    INNER JOIN msdb.dbo.sysjobsteps S ON S.job_id = J.job_id 
    LEFT OUTER JOIN msdb.dbo.sysproxies P ON P.proxy_id = S.proxy_id
    LEFT OUTER JOIN sys.server_principals SP ON SP.sid = P.user_sid


    SELECT
     job.job_id,
     notify_level_email,
     name,
     enabled,
     description,
     step_name,
     command,
     server,
     database_name
FROM
    msdb.dbo.sysjobs job
INNER JOIN 
    msdb.dbo.sysjobsteps steps        
ON
    job.job_id = steps.job_id
WHERE
    job.enabled = 1 -- remove this if you wish to return all jobs