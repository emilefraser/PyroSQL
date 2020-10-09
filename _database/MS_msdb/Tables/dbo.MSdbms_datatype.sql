SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MSdbms_datatype](
	[datatype_id] [int] IDENTITY(1,1) NOT NULL,
	[dbms_id] [int] NOT NULL,
	[type] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[createparams] [int] NOT NULL
) ON [PRIMARY]

GO
