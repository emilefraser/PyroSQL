CREATE TABLE [Sample].[Target_Product] (
    [ProductID]              INT            NOT NULL,
    [ProductModelID]         INT            NOT NULL,
    [Name]                   NVARCHAR (100) NOT NULL,
    [Description]            XML            NOT NULL,
    [Color]                  NVARCHAR (15)  NULL,
    [Created]                DATETIME       NOT NULL,
    [DSQLT_SyncRowCreated]   DATETIME       CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowCreated] DEFAULT (getdate()) NULL,
    [DSQLT_SyncRowModified]  DATETIME       CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowModified] DEFAULT (getdate()) NULL,
    [DSQLT_SyncRowIsDeleted] BIT            CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowIsDeleted] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Target_Product] PRIMARY KEY CLUSTERED ([ProductID] ASC, [ProductModelID] ASC)
);

