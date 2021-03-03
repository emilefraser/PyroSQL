-- Creates new SQL Server Agent Job Categories
/*
sp_add_category   
     [ [ @class = ] 'class', ]   {JOB, ALERT, OPERATOR}
     [ [ @type = ] 'type', ]	 {LOCAL, MULTI-SERVER, NONE}
     { [ @name = ] 'name' }  
*/
USE msdb
GO  

DECLARE @class	SYSNAME = N'JOB'
DECLARE @type	SYSNAME = N'LOCAL'
DECLARE @name	SYSNAME = N'Power BI Load'

EXEC dbo.sp_add_category  
    @class = @class
,   @type  = @type 
,   @name  = @name
GO  