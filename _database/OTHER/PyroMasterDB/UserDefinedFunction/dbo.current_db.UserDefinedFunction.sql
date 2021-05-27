SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[current_db]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2015-08-31 BvdB returns current database in kind of dirty way... 
-- when betl is called from a different database. e.g. My_Staging we want to return My_Staging as current db instead of the db where this function lives. 

use master
select betl.dbo.current_db()
-- should return master. however this requires view server state permissions. 

*/
CREATE   FUNCTION [dbo].[current_db]() RETURNS varchar(1000) 
AS
BEGIN
	declare @db_name  as varchar(1000) 

	-- first check to see if current user has view server state permission
	if exists ( 
		SELECT l.name as grantee_name, p.state_desc, p.permission_name 
		FROM sys.server_permissions AS p 
		JOIN sys.server_principals AS l ON p.grantee_principal_id = l.principal_id
		WHERE
		permission_name = ''VIEW Server State'' 
	) 
		SELECT @db_name = d.name
		FROM sys.dm_tran_locks -- requires elevated permissions
		inner join sys.databases d with(nolock) on resource_database_id  = d.database_id
		WHERE request_session_id = @@SPID and resource_type = ''DATABASE'' and request_owner_type = ''SHARED_TRANSACTION_WORKSPACE''
	else 
		SELECT @db_name = db_name() 
--	and d.name<>db_name() 

	RETURN @db_name  
END












' 
END
GO
