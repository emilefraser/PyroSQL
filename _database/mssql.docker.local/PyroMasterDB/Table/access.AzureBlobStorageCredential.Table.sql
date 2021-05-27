SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[access].[AzureBlobStorageCredential]') AND type in (N'U'))
BEGIN
CREATE TABLE [access].[AzureBlobStorageCredential](
	[AzBlobCredentialID] [int] IDENTITY(0,1) NOT NULL,
	[AzBlobCredentialName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AzBlobSharedAccessCredential] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AzBlobCredentialScope] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[AzBlobCredentialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[access].[DF_access_AzureBlobStorageCredential_CreatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [access].[AzureBlobStorageCredential] ADD  CONSTRAINT [DF_access_AzureBlobStorageCredential_CreatedDT]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
