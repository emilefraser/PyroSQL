SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[TestPattern_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataSync].[TestPattern_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] AS' 
END
GO
ALTER PROCEDURE [DataSync].[TestPattern_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]
	@P_1 Int,
	@P_2 VarChar(50),
	@P_3 VarChar(500),
	@P_4 VarChar(50),
	@P_5 VarChar(20),
	@P_6 NVarChar(100),
	@P_7 DateTime2,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF (NOT EXISTS (SELECT * FROM [test].[TestPattern] WHERE [PatternID] = @P_1)
 AND NOT EXISTS (SELECT * FROM [DataSync].[TestPattern_dss_tracking] WHERE [PatternID] = @P_1)
)
BEGIN 
SET IDENTITY_INSERT [test].[TestPattern] ON; INSERT INTO [test].[TestPattern]([PatternID], [TestName], [TestDesription], [TestClassName], [TestObjectType], [TestScope], [CreatedDT]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [test].[TestPattern] OFF; END 
END
GO
