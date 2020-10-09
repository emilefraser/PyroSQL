SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ErrorLog](
	[ErrorLogID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorTime] [datetime] NOT NULL,
	[UserName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorNumber] [int] NOT NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProcedure] [nvarchar](126) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
