CREATE TABLE [APEXSQL_LOG_OPERATION_DETAIL] (
	[LSN] [CHAR](22) NOT NULL,
	[LINE_NO] [INT] NOT NULL,
	[COLUMN_NAME] [NVARCHAR](128) NULL,
	[COLUMN_TYPE] [NVARCHAR](128) NULL,
	[OLD_VALUE] [NTEXT] NULL,
	[NEW_VALUE] [NTEXT] NULL,
	CONSTRAINT [PK_APEXSQL_LOG_OPERATION_DETAIL] PRIMARY KEY CLUSTERED (
		[LSN],
		[LINE_NO]
		) ON [PRIMARY]
	) ON [PRIMARY] 
END