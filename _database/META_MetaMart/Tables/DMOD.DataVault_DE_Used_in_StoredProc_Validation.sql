SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DMOD].[DataVault_DE_Used_in_StoredProc_Validation](
	[LoadConfig_TargetDE] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DE_object_id_In_StoredProc] [int] NULL,
	[DataEntity_In_StoredProc] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Rows_In_Table] [int] NULL
) ON [PRIMARY]

GO
