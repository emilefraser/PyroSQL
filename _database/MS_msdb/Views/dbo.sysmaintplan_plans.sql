SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW sysmaintplan_plans
AS
   SELECT
   s.name AS [name],
   s.id AS [id],
   s.description AS [description],
   s.createdate AS [create_date],
   suser_sname(s.ownersid) AS [owner],
   s.vermajor AS [version_major],
   s.verminor AS [version_minor],
   s.verbuild AS [version_build],
   s.vercomments AS [version_comments],
   ISNULL((select TOP 1 msx_plan from sysmaintplan_subplans where plan_id = s.id), 0) AS [from_msx],
   CASE WHEN (NOT EXISTS (select TOP 1 msx_job_id 
                          from sysmaintplan_subplans subplans, sysjobservers jobservers
                          where plan_id = s.id 
                          and msx_job_id is not null
                          and subplans.msx_job_id = jobservers.job_id
                          and server_id != 0)) 
        then 0 
        else 1 END AS [has_targets]
   FROM
   msdb.dbo.sysssispackages AS s
   WHERE
   (s.folderid = '08aa12d5-8f98-4dab-a4fc-980b150a5dc8' and s.packagetype = 6)

GO
