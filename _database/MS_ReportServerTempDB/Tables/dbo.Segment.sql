SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Segment](
	[SegmentId] [uniqueidentifier] NOT NULL,
	[Content] [varbinary](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
