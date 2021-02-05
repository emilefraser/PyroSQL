CREATE PROCEDURE [DSQLT].[@addSyncFields]
@p1 NVARCHAR (MAX)=null, @Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] 'DSQLT.@addSyncFields' ,@p1,@Database=@Database,@Print=@Print
RETURN 0
BEGIN
alter TABLE [@1].[@1]
add
	[DSQLT_SyncRowCreated] [datetime] NULL,
	[DSQLT_SyncRowModified] [datetime] NULL,
	[DSQLT_SyncRowIsDeleted] [bit] NULL

ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowCreated]  DEFAULT (getdate()) FOR [DSQLT_SyncRowCreated]
ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowModified]  DEFAULT (getdate()) FOR [DSQLT_SyncRowModified]
ALTER TABLE [@1].[@1] ADD  CONSTRAINT [DF_@1_DSQLT_SyncRowIsDeleted]  DEFAULT ((0)) FOR [DSQLT_SyncRowIsDeleted]
END
