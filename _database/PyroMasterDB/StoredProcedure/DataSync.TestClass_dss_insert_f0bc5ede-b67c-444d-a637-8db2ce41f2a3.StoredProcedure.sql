SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DataSync].[TestClass_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [DataSync].[TestClass_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3] AS' 
END
GO
ALTER PROCEDURE [DataSync].[TestClass_dss_insert_f0bc5ede-b67c-444d-a637-8db2ce41f2a3]
	@P_1 SmallInt,
	@P_2 VarChar(30),
	@P_3 VarChar(100),
	@P_4 DateTime2,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; IF (NOT EXISTS (SELECT * FROM [test].[TestClass] WHERE [TestClassId] = @P_1)
 AND NOT EXISTS (SELECT * FROM [DataSync].[TestClass_dss_tracking] WHERE [TestClassId] = @P_1)
)
BEGIN 
SET IDENTITY_INSERT [test].[TestClass] ON; INSERT INTO [test].[TestClass]([TestClassId], [TestClassCode], [TestClassName], [CreatedDT]) VALUES (@P_1, @P_2, @P_3, @P_4);  SET @sync_row_count = @@rowcount; SET IDENTITY_INSERT [test].[TestClass] OFF; END 
END
GO
