SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Transfer_ext]'))
EXEC dbo.sp_executesql @statement = N'	  
CREATE   VIEW [dbo].[Transfer_ext] as 
select 
t.[transfer_id]
,t.[transfer_name]
,t.[src_obj_id]
,t.[target_name]
,t.[transfer_start_dt]
,t.[transfer_end_dt]
,s.status_name status
,t.[rec_cnt_src]
,t.[rec_cnt_new]
,t.[rec_cnt_changed]
,t.[rec_cnt_deleted]
,t.[last_error_id]
,b.batch_id
, b.[batch_start_dt] 
,b.[batch_end_dt] 
, b.batch_name
, s.status_name batch_status 
from dbo.Transfer t
left join dbo.Batch b on t.batch_id = b.batch_id 
left join static.Status s on s.status_id = t.status_id












' 
GO
