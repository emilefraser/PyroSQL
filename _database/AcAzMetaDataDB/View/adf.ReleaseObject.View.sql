SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[ReleaseObject]'))
EXEC dbo.sp_executesql @statement = N'/*
	CREATE BY: Emile Fraser
	DATE: 2020-11-26
	DESCRIPTION: Gets the objects to backup to blob storage for realease management
*/

CREATE   VIEW [adf].[ReleaseObject]
AS
select 

	EntityType   = obj.type 
,	EntitySchema = sch.name
,	EntityName   = pro.name

from sys.procedures AS pro
inner join sys.schemas AS sch
on pro.schema_id = sch.schema_id
inner join sys.objects AS obj
on obj.object_id = pro.object_id
where sch.name IN (''adf'', ''balance'', ''dm'', ''dc'', ''ext'', ''dv'', ''stage'', ''raw'', ''biz'', ''infomart'')

UNION ALL 

select 

	EntityType   = obj.type 
,	EntitySchema = sch.name
,	EntityName   = tab.name

from sys.tables AS tab
inner join sys.schemas AS sch
on tab.schema_id = sch.schema_id
inner join sys.objects AS obj
on obj.object_id = tab.object_id
where sch.name IN (''adf'', ''balance'', ''dm'', ''dc'', ''ext'', ''dv'', ''stage'', ''raw'', ''biz'', ''infomart'', ''vs_lnd'')


UNION ALL 

select 

	EntityType   = obj.type 
,	EntitySchema = sch.name
,	EntityName   = vie.name

from sys.views AS vie
inner join sys.schemas AS sch
on vie.schema_id = sch.schema_id
inner join sys.objects AS obj
on obj.object_id = vie.object_id
where sch.name IN (''adf'', ''balance'', ''dm'', ''dc'', ''dv'', ''biz'', ''infomart'', ''lnd_poster'')


UNION ALL 

select 

	EntityType   = obj.type 
,	EntitySchema = sch.name
,	EntityName   = obj.name
from sys.sql_modules AS fun
inner join sys.objects AS obj
on obj.object_id = fun.object_id
inner join sys.schemas AS sch
on obj.schema_id = sch.schema_id
where obj.type IN (''FN'', ''TR'',''IF'')

' 
GO
