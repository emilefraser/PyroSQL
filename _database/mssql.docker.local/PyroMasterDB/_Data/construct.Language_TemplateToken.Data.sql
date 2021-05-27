SET IDENTITY_INSERT [construct].[Language_TemplateToken] ON 

INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (0, N'dummy', N'Dummy Token', N'dummy', N'{…}', N'', N'{', N'}', N'', N'', N'0', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (1, N'value', N'Replacement Token', N'replace', N'{{ ... }}', N'''%{{%}}''', N'{{', N'}}', N'pyro.ResolveTokenValue', N'FN', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (2, N'expression', N'Expression Token', N'execution', N'{{&…&}}', N'''%{{?%?}}''', N'{{?', N'?}}', N'pyro.ResolveTokenExpression', N'FN', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (3, N'recurse', N'Recursion Token', N'resurse', N'{{<…>}}', N'''%{{<%>}}''', N'{{<', N'>}}', N'pyro.ResolveTokenResurse', N'P', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (4, N'flow', N'Sql Logical Flow Token', N'flow', N'{{$...$}}', N'''%{{$%$}}''', N'{{$', N'$}}', N'pyro.ResolveTokenFlow', N'P', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (5, N'comment', N'Sql Comment Token', N'replace', N'{{# ... #}}', N'''%{{#%#}}''', N'{{#', N'#}}', N'pyro.ResolveTokenComment', N'FN', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (6, N'external', N'External Execution Token', N'execution', N'{{@ ... @}}', N'''%{{@%@}}''', N'{{@', N'@}}', N'pyro.ResolveTokenExternalCmd', N'FN', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (7, N'sqlcmd', N'Sql CMD Token', N'execution', N'{{! …!}}', N'''%{{+%+}}''', N'{{+', N'+}}', N'pyro.ResolveTokenSqlCmd', N'P', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (8, N'constant', N'Constant Token', N'replace', N'{{~ …~}}', N'''%{{~%~}}''', N'{{~', N'~}}', N'pyro.ResolveTokenConstant', N'P', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
INSERT [construct].[Language_TemplateToken] ([TokenTypeId], [TokenTypeCode], [TokenTypeDescription], [TokenClassName], [TokenTypeDefinition], [TokenTypeRegex], [TokenBraceLeft], [TokenBraceRight], [TokenResolutionObjectName], [TokenResolutionObjectType], [TokenResolutionObjectParameter], [TokenReplacementRank], [IsActive], [StartDT], [EndDT]) VALUES (9, N'array', N'Array Set Token', N'resultset', N'{{[…]}}', N'''%{{[%]}}''', N'{{[', N']}}', N'pyro.ResolveTokenArray', N'P', N'1', NULL, 1, CAST(N'2021-02-21T00:24:51.6189570' AS DateTime2), CAST(N'9999-12-31T23:59:59.9999999' AS DateTime2))
SET IDENTITY_INSERT [construct].[Language_TemplateToken] OFF
