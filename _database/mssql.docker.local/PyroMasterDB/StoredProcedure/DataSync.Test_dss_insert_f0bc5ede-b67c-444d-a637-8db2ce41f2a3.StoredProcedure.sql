SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[Test_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataSync].[Test_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] AS' 
END
GO
ALTER PROCEDURE [DataSync].[Test_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]
	@P_1 Int,
	@P_2 VarChar(50),
	@P_3 VarChar(150),
	@P_4 VarChar(250),
	@P_5 Int,
	@P_6 Int,
	@P_7 VarChar(3),
	@P_8 NVarChar(max),
	@P_9 DateTime2,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF (NOT EXISTS (SELECT * FROM [test].[Test] WHERE [TestId] = @P_1)
 AND NOT EXISTS (SELECT * FROM [DataSync].[Test_dss_tracking] WHERE [TestId] = @P_1)
)
BEGIN 
SET IDENTITY_INSERT [test].[Test] ON; INSERT INTO [test].[Test]([TestId], [TestCode], [TestName], [TestDescription], [TestClassId], [TestTypeId], [ObjectType], [TestDefinition], [CreatedDT]) VALUES (@P_1, @P_2, @P_3, @P_4, @P_5, @P_6, @P_7, @P_8, @P_9);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [test].[Test] OFF; END 
END
GO
