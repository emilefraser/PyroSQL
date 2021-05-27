SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Batch_ext]'))
EXEC dbo.sp_executesql @statement = N'	  
CREATE   VIEW [dbo].[Batch_ext] as 
select 
b.[batch_id] 
,b.[batch_name] 
,b.[batch_start_dt] 
,b.[batch_end_dt] 
, s.status_name batch_status 
, b.prev_batch_id
, prev_b.batch_start_dt prev_batch_start_dt
, prev_b.batch_end_dt prev_batch_end_dt
, prev_s.status_name prev_batch_status 
from dbo.Batch b
inner join static.Status s on s.status_id = b.status_id
left join dbo.Batch prev_b on b.prev_batch_id = prev_b.batch_id 
left join static.Status prev_s on prev_s.status_id = prev_b.status_id












' 
GO
