SET IDENTITY_INSERT [test].[TestClass] ON 

INSERT [test].[TestClass] ([TestClassId], [TestClassCode], [TestClassName], [CreatedDT]) VALUES (0, N'SQL', N'Sql Arbitrary', CAST(N'2021-02-01T03:18:59.4533333' AS DateTime2))
INSERT [test].[TestClass] ([TestClassId], [TestClassCode], [TestClassName], [CreatedDT]) VALUES (1, N'DV', N'DataVault', CAST(N'2021-02-01T03:19:04.1466667' AS DateTime2))
INSERT [test].[TestClass] ([TestClassId], [TestClassCode], [TestClassName], [CreatedDT]) VALUES (2, N'VS', N'Vaultspeed', CAST(N'2021-02-01T03:19:09.2766667' AS DateTime2))
SET IDENTITY_INSERT [test].[TestClass] OFF
