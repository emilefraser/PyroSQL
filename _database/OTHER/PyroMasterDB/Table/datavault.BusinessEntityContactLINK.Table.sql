SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[BusinessEntityContactLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[BusinessEntityContactLINK](
	[BusinessEntityContactVID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL,
	[ContactTypeID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BusinessEntityContactVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BusinessEntityVID] ASC,
	[PersonVID] ASC,
	[ContactTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BusinessEntityVID] ASC,
	[PersonVID] ASC,
	[ContactTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BusinessEntityVID] ASC,
	[PersonVID] ASC,
	[ContactTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Busin__5E15D37E]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityContactLINK]'))
ALTER TABLE [datavault].[BusinessEntityContactLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Busin__6740165C]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityContactLINK]'))
ALTER TABLE [datavault].[BusinessEntityContactLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Busin__69A781BB]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityContactLINK]'))
ALTER TABLE [datavault].[BusinessEntityContactLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Perso__5F09F7B7]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityContactLINK]'))
ALTER TABLE [datavault].[BusinessEntityContactLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Perso__68343A95]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityContactLINK]'))
ALTER TABLE [datavault].[BusinessEntityContactLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Perso__6A9BA5F4]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityContactLINK]'))
ALTER TABLE [datavault].[BusinessEntityContactLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
