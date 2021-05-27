SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[create_jobs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[create_jobs] AS' 
END
GO
	  
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-01-25 BvdB creates job in msdb from betl job meta data (dbo.Job_ext) 
select * from dbo.job_ext
select * from dbo.job_step_ext
exec dbo.create_jobs 1 
exec dbo.create_job 10
update dbo.job set name = replace ( name, 'dev', 'acc') 
update dbo.job_step_ext
set command = replace(command, 'ssis01-ota.company.nl\ww_dev', 'ssis01-ota.company.nl\ww_acc') 
*/ 
ALTER   PROCEDURE [dbo].[create_jobs]  @drop as bit = 1 as 
begin 
	set nocount on 
	declare 
		@sql as varchar(max) = ''
		, @transfer_id as int = 0 
	select @sql += 'exec dbo.create_job ' + convert(varchar(255), job_id) + ',' + convert(varchar(255), @drop) +'
select '''+ job_name + ''' as job_name 
'	
	
	from dbo.Job_ext
	--print @sql 
	exec [dbo].[exec_sql] @transfer_id, @sql
end












GO
