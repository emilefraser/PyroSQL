ALTER TABLE [Sample].[Target_Product]
    ADD CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowModified] DEFAULT (getdate()) FOR [DSQLT_SyncRowModified];

