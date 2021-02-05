CREATE TABLE [DSQLT].[Sync_Template] (
    [DSQLT_SyncRowCreated]   DATETIME NOT NULL,
    [DSQLT_SyncRowModified]  DATETIME NOT NULL,
    [DSQLT_SyncRowIsDeleted] BIT      NOT NULL,
    [DSQLT_SyncRowStatus]    INT      NOT NULL
);

