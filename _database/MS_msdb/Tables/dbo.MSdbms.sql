SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MSdbms](
	[dbms_id] [int] IDENTITY(1,1) NOT NULL,
	[dbms] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[version] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
