
CREATE PROCEDURE [DSQLT].[@addSyncRowStatus]
@p1 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] 'DSQLT.@addSyncRowStatus' ,@p1,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
alter TABLE [@1].[@1]
add
	[DSQLT_SyncRowStatus] [tinyint] NULL

ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowStatus]  DEFAULT ((0)) FOR [DSQLT_SyncRowStatus]
END