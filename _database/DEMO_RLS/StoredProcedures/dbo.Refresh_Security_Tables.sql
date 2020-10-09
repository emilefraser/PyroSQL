SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




/* 
 * Use if just want users in DB and no logins with passwords for simple testing (comment out the 2 blocks above) ****

USE oilgasrlsdemo2016
go

DECLARE user_cursor CURSOR
   FOR
   SELECT userid from [SEC_ORG_USER_BASE];
OPEN user_cursor;
DECLARE @username varchar(12);
FETCH NEXT FROM user_cursor INTO @username;
WHILE (@@FETCH_STATUS <> -1)
BEGIN;
   EXECUTE ('create user [' + @username + '] WITHOUT LOGIN;');
   EXECUTE ('ALTER ROLE [db_datareader] ADD MEMBER [' + @username + '];');
   FETCH NEXT FROM user_cursor INTO @username;
END;
PRINT 'The users have been created.';
CLOSE user_cursor;
DEALLOCATE user_cursor;
GO

*/


-- 
-- Create Procedure to Refresh Security Table
-- 

create procedure Refresh_Security_Tables
as

BEGIN

     delete dbo.SEC_ORG_USER_BASE_MAP;
     
     with emp as
     (
       select 
      e.EMPLID,
      e.USERID,
      e.NAME,
      e.ORG_UNIT_ID,
      null ParentOrgId,
      e.MGRID SupervisorId,
      e.ORG_UNIT_NAME Position
        from SEC_ORG_USER_BASE e
        -- where e.EMPLID > '0'
     ), sec_grp_app_map as
     (
       SELECT 
            OU
       FROM SEC_ASSET_MAP
     ), rq as
     (
      select emp.emplid, emp.userid, emp.name, emp.is_employee, emp.org_unit_id, 
	         emp.org_unit_name, 1 level, 
			 case when exists (select * from sec_grp_app_map where OU = emp.ORG_UNIT_ID) 
			 then emp.ORG_UNIT_ID else null end SECURITY_CLEARANCE,
     		cast(emp.ORG_UNIT_ID as varchar(max)) as ORG_UNIT_ID_PATH,
     		cast(emp.ORG_UNIT_NAME as varchar(max)) as ORG_UNIT_NAME_PATH
      from dbo.SEC_ORG_USER_BASE emp
      where (mgrid is null or mgrid = 0)
      union all
      select emp.emplid, emp.userid, emp.name, emp.is_employee, emp.org_unit_id, 
	         emp.org_unit_name, rq.level + 1 level, 
			case when exists (select * from sec_grp_app_map where OU = emp.ORG_UNIT_ID) 
			     then emp.ORG_UNIT_ID else rq.SECURITY_CLEARANCE end SECURITY_CLEARANCE, 
     		case when emp.org_unit_id <> rq.org_unit_id 
			   then cast(rq.ORG_UNIT_ID_PATH + '|' + cast(emp.ORG_UNIT_ID as varchar(6)) as varchar(max)) else cast(rq.ORG_UNIT_ID_PATH as varchar(max)) end, 
     		case when emp.ORG_UNIT_NAME <> rq.ORG_UNIT_NAME 
			   then cast(rq.ORG_UNIT_NAME_PATH + '|' + emp.ORG_UNIT_NAME as varchar(max)) else cast(rq.ORG_UNIT_NAME_PATH as varchar(max)) end
      from rq 
      join dbo.SEC_ORG_USER_BASE emp 
      on rq.emplid = emp.mgrid
     )
     insert into dbo.SEC_ORG_USER_BASE_MAP
     select * 
     from rq;
     
     -- 
     
     DELETE [SEC_USER_MAP];

     
     INSERT INTO [SEC_USER_MAP]
     SELECT SOUMB.USERID, SGAM.[HIERARCHY_NODE], SGAM.[HIERARCHY_VALUE]
       FROM [SEC_ORG_USER_BASE_MAP] SOUMB
         JOIN [SEC_ASSET_MAP] SGAM
     	  ON SOUMB.SECURITY_CLEARANCE = SGAM.OU
       WHERE 
       (SOUMB.USERID IN 
          (SELECT name
             FROM sys.database_principals
             WHERE type in ('U','S')
     	AND
     	SOUMB.USERID NOT IN
     	(SELECT USERID FROM [SEC_USER_EXCEPTIONS] WHERE HIERARCHY_NODE = 'ALL')))
     UNION ALL
     SELECT * from [SEC_USER_EXCEPTIONS] WHERE HIERARCHY_NODE = 'ALL';
     
end;

GO
