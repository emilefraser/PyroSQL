SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[ADFLinkedService](
	[ADFLinkedServiceID] [int] IDENTITY(1,1) NOT NULL,
	[ADFLinkedServiceCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ADFLinkedServiceName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IntegrationRuntimeID] [int] NOT NULL,
	[DatabaseTechnologyTypeID] [int] NOT NULL
) ON [PRIMARY]

GO
