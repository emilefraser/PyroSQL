SET IDENTITY_INSERT [test].[TestType] ON 

INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (0, N'DU', N'Dummy', CAST(N'2021-02-01T03:13:43.7600000' AS DateTime2))
INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (1, N'EQ', N'Equality', CAST(N'2021-02-01T03:14:01.1533333' AS DateTime2))
INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (2, N'RD', N'Redundancy', CAST(N'2021-02-01T03:14:18.4100000' AS DateTime2))
INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (3, N'RI', N'Referential Integrity', CAST(N'2021-02-01T03:14:32.1433333' AS DateTime2))
INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (4, N'CO', N'Compare', CAST(N'2021-02-01T03:14:43.2966667' AS DateTime2))
INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (5, N'CT', N'Count', CAST(N'2021-02-01T03:14:58.6633333' AS DateTime2))
INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (6, N'RE', N'Resolution', CAST(N'2021-02-01T03:15:08.1966667' AS DateTime2))
INSERT [test].[TestType] ([TestTypeId], [TestTypeCode], [TestTypeName], [CreatedDT]) VALUES (7, N'EX', N'Existence', CAST(N'2021-02-01T03:21:24.2600000' AS DateTime2))
SET IDENTITY_INSERT [test].[TestType] OFF
