SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[SyncObjectData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[SyncObjectData](
	[ObjectId] [uniqueidentifier] NOT NULL,
	[DataType] [int] NOT NULL,
	[CreatedTime] [datetime2](7) NOT NULL,
	[DroppedTime] [datetime2](7) NULL,
	[LastModified] [timestamp] NOT NULL,
	[ObjectData] [varbinary](max) NOT NULL,
 CONSTRAINT [PK_SyncObjectExtInfo] PRIMARY KEY CLUSTERED 
(
	[ObjectId] ASC,
	[DataType] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__SyncObjec__Creat__6324A15E]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[SyncObjectData] ADD  DEFAULT (getutcdate()) FOR [CreatedTime]
END
GO
