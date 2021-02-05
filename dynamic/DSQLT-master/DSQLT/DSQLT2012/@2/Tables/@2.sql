CREATE TABLE [@2].[@2] (
    [@1]                     NVARCHAR (MAX) NOT NULL,
    [@2]                     NVARCHAR (MAX) NOT NULL,
    [@3]                     NVARCHAR (MAX) NOT NULL,
    [@4]                     NVARCHAR (MAX) NOT NULL,
    [@5]                     NVARCHAR (MAX) NOT NULL,
    [@6]                     NVARCHAR (MAX) NULL,
    [@7]                     NVARCHAR (MAX) NULL,
    [@8]                     NVARCHAR (MAX) NULL,
    [@9]                     NVARCHAR (MAX) NULL,
    [DSQLT_SyncRowCreated]   DATETIME       CONSTRAINT [DF_@2_DSQLT_SyncRowCreated] DEFAULT (getdate()) NOT NULL,
    [DSQLT_SyncRowModified]  DATETIME       CONSTRAINT [DF_@2_DSQLT_SyncRowModified] DEFAULT (getdate()) NOT NULL,
    [DSQLT_SyncRowIsDeleted] BIT            CONSTRAINT [DF_@2_DSQLT_SyncRowIsDeleted] DEFAULT ((0)) NOT NULL,
    [DSQLT_SyncRowStatus]    TINYINT        NOT NULL
);

