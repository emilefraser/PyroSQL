SET IDENTITY_INSERT [test].[Test] ON 

INSERT [test].[Test] ([TestId], [TestCode], [TestName], [TestDescription], [TestClassId], [TestTypeId], [ObjectType], [TestDefinition], [CreatedDT]) VALUES (0, N'VS_EX_U', N'Table exists in lnd', NULL, 2, 7, N'U', NULL, CAST(N'2021-02-01T03:25:17.9200000' AS DateTime2))
SET IDENTITY_INSERT [test].[Test] OFF
