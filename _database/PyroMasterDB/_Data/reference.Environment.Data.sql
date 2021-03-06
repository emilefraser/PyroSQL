SET IDENTITY_INSERT [reference].[Environment] ON 

INSERT [reference].[Environment] ([EnvironmentID], [EnvironmentCode], [EnvironmentName], [IsPrependLoadEnvironmentCode], [IsAppendLoadEnvironmentCode], [CreateDT]) VALUES (0, N'GEN', N'Generic', 0, 0, CAST(N'2021-02-27T01:12:08.053' AS DateTime))
INSERT [reference].[Environment] ([EnvironmentID], [EnvironmentCode], [EnvironmentName], [IsPrependLoadEnvironmentCode], [IsAppendLoadEnvironmentCode], [CreateDT]) VALUES (1, N'DEV', N'Development', 0, 1, CAST(N'2021-02-27T01:12:08.120' AS DateTime))
INSERT [reference].[Environment] ([EnvironmentID], [EnvironmentCode], [EnvironmentName], [IsPrependLoadEnvironmentCode], [IsAppendLoadEnvironmentCode], [CreateDT]) VALUES (2, N'QA', N'Quality Assurance', 0, 1, CAST(N'2021-02-27T01:12:08.347' AS DateTime))
INSERT [reference].[Environment] ([EnvironmentID], [EnvironmentCode], [EnvironmentName], [IsPrependLoadEnvironmentCode], [IsAppendLoadEnvironmentCode], [CreateDT]) VALUES (3, N'UAT', N'User Acceptance Testing', 0, 1, CAST(N'2021-02-27T01:12:08.380' AS DateTime))
INSERT [reference].[Environment] ([EnvironmentID], [EnvironmentCode], [EnvironmentName], [IsPrependLoadEnvironmentCode], [IsAppendLoadEnvironmentCode], [CreateDT]) VALUES (4, N'PROD', N'Production', 0, 1, CAST(N'2021-02-27T01:12:08.420' AS DateTime))
SET IDENTITY_INSERT [reference].[Environment] OFF
