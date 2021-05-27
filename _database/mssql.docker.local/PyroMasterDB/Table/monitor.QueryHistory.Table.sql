SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[QueryHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [monitor].[QueryHistory](
	[QueryHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[DateStamp] [datetime] NOT NULL,
	[Login_Time] [datetime] NULL,
	[Start_Time] [datetime] NULL,
	[RunTime] [numeric](20, 4) NULL,
	[Session_ID] [smallint] NOT NULL,
	[CPU_Time] [bigint] NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[Logical_Reads] [bigint] NULL,
	[Host_Name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DBName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Login_Name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Formatted_SQL_Text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SQL_Text] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Program_Name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Blocking_Session_ID] [smallint] NULL,
	[Status] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Open_Transaction_Count] [int] NULL,
	[Percent_Complete] [numeric](12, 2) NULL,
	[Client_Net_Address] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Wait_Time] [int] NULL,
	[Last_Wait_Type] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [pk_QueryHistory] PRIMARY KEY CLUSTERED 
(
	[QueryHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
