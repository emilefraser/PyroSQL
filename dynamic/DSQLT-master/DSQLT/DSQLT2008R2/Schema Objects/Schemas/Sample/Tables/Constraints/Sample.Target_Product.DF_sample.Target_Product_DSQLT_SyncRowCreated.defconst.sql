ALTER TABLE [Sample].[Target_Product]
    ADD CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowCreated] DEFAULT (getdate()) FOR [DSQLT_SyncRowCreated];

