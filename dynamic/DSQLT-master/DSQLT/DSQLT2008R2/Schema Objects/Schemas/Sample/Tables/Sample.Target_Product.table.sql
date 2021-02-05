CREATE TABLE [Sample].[Target_Product] (
    [ProductID]              INT            NOT NULL,
    [ProductModelID]         INT            NOT NULL,
    [Name]                   NVARCHAR (100) NOT NULL,
    [Description]            XML            NOT NULL,
    [Color]                  NVARCHAR (15)  NULL,
    [Created]                DATETIME       NOT NULL,
    [DSQLT_SyncRowCreated]   DATETIME       NULL,
    [DSQLT_SyncRowModified]  DATETIME       NULL,
    [DSQLT_SyncRowIsDeleted] BIT            NULL
);

