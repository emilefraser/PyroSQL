ALTER TABLE [Sample].[Target_Product]
    ADD CONSTRAINT [DF_sample.Target_Product_DSQLT_SyncRowIsDeleted] DEFAULT ((0)) FOR [DSQLT_SyncRowIsDeleted];

