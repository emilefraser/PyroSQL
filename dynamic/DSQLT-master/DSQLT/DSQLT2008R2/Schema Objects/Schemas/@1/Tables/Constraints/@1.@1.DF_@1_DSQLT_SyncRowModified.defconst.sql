ALTER TABLE [@1].[@1]
    ADD CONSTRAINT [DF_@1_DSQLT_SyncRowModified] DEFAULT (getdate()) FOR [DSQLT_SyncRowModified];

