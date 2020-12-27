USE [CarSales]
GO
/****** Object:  Table [dbo].[Client]    Script Date: 20/01/2013 13:33:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Client](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ClientName] [nvarchar](150) NULL,
	[Address1] [varchar](50) NULL,
	[Address2] [varchar](50) NULL,
	[Town] [varchar](50) NULL,
	[County] [varchar](50) NULL,
	[PostCode] [varchar](10) NULL,
	[Country] [tinyint] NULL,
	[ClientType] [varchar](20) NULL,
	[ClientSize] [varchar](10) NULL,
	[ClientSince] [smalldatetime] NULL,
	[IsCreditWorthy] [bit] NULL,
	[DealerGroup] [hierarchyid] NULL,
	[MapPosition] [geography] NULL,
 CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[Client] ON 

INSERT [dbo].[Client] ([ID], [ClientName], [Address1], [Address2], [Town], [County], [PostCode], [Country], [ClientType], [ClientSize], [ClientSince], [IsCreditWorthy], [DealerGroup], [MapPosition]) VALUES (3, N'John Smith', N'4, Grove Drive', NULL, N'Uttoxeter', N'Staffs', N'ST14 1AA', 1, N'Private', N'M', CAST(0x571C0000 AS SmallDateTime), 1, NULL, NULL)
INSERT [dbo].[Client] ([ID], [ClientName], [Address1], [Address2], [Town], [County], [PostCode], [Country], [ClientType], [ClientSize], [ClientSince], [IsCreditWorthy], [DealerGroup], [MapPosition]) VALUES (4, N'Bauhaus Motors', N'Suite 20', N'12-14 Turl Street', N'Oxford', N'Oxon', N'OX14 ZZ', 2, N'Business', N'L', CAST(0x9EB80000 AS SmallDateTime), 1, NULL, NULL)
INSERT [dbo].[Client] ([ID], [ClientName], [Address1], [Address2], [Town], [County], [PostCode], [Country], [ClientType], [ClientSize], [ClientSince], [IsCreditWorthy], [DealerGroup], [MapPosition]) VALUES (5, N'Honest Fred', NULL, NULL, N'Stoke', N'Staffs', N'ST1 1A', 3, N'Business', N'L', CAST(0x87CC0000 AS SmallDateTime), 0, NULL, NULL)
INSERT [dbo].[Client] ([ID], [ClientName], [Address1], [Address2], [Town], [County], [PostCode], [Country], [ClientType], [ClientSize], [ClientSince], [IsCreditWorthy], [DealerGroup], [MapPosition]) VALUES (6, N'Fast Eddie', N'Cut Street', NULL, N'Aberdeen', NULL, NULL, 2, N'Business', N'S', CAST(0x9E5D0000 AS SmallDateTime), 0, NULL, NULL)
INSERT [dbo].[Client] ([ID], [ClientName], [Address1], [Address2], [Town], [County], [PostCode], [Country], [ClientType], [ClientSize], [ClientSince], [IsCreditWorthy], [DealerGroup], [MapPosition]) VALUES (7, N'Slow Sid', N'2, Rue des Bleues', NULL, N'Avignon', N'Vaucluse', N'84000', 3, N'Private', N'M', CAST(0x5EC60000 AS SmallDateTime), 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Client] OFF
ALTER TABLE [dbo].[Client]  WITH CHECK ADD  CONSTRAINT [FK_Client_Countries] FOREIGN KEY([Country])
REFERENCES [dbo].[Countries] ([CountryID])
GO
ALTER TABLE [dbo].[Client] CHECK CONSTRAINT [FK_Client_Countries]
GO
EXEC sys.sp_addextendedproperty @name=N'LAST_SYNC_VERSION', @value=16 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Client'
GO
