SET IDENTITY_INSERT [dbo].[Transfer_log] ON 

INSERT [dbo].[Transfer_log] ([log_id], [log_dt], [msg], [transfer_id], [log_level_id], [log_type_id], [exec_sql]) VALUES (5, CAST(N'2021-02-05T11:06:59.550' AS DateTime), N'-- Error: -- ERROR: msg The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Property_value_Obj". The conflict occurred in database "BETL", table "dbo.Obj", column ''obj_id''. ', -1, NULL, 50, NULL)
INSERT [dbo].[Transfer_log] ([log_id], [log_dt], [msg], [transfer_id], [log_level_id], [log_type_id], [exec_sql]) VALUES (4, CAST(N'2021-02-05T11:06:59.547' AS DateTime), N'  -- FOOTER_DETAIL: DONE get_obj_id LOCALHOST(-2)', -1, 30, NULL, 1)
INSERT [dbo].[Transfer_log] ([log_id], [log_dt], [msg], [transfer_id], [log_level_id], [log_type_id], [exec_sql]) VALUES (3, CAST(N'2021-02-05T11:06:59.547' AS DateTime), N'-- Error:   -- ERROR: Object LOCALHOST NOT FOUND', -1, NULL, 50, NULL)
INSERT [dbo].[Transfer_log] ([log_id], [log_dt], [msg], [transfer_id], [log_level_id], [log_type_id], [exec_sql]) VALUES (2, CAST(N'2021-02-05T11:06:59.510' AS DateTime), N'-- Error:   -- ERROR: Object name LOCALHOST is ambiguous. -2 duplicates.', -1, NULL, 50, NULL)
INSERT [dbo].[Transfer_log] ([log_id], [log_dt], [msg], [transfer_id], [log_level_id], [log_type_id], [exec_sql]) VALUES (1, CAST(N'2021-02-05T11:06:59.503' AS DateTime), N'  -- HEADER_DETAIL: get_obj_id LOCALHOST , scope ?, depth 0', -1, 30, NULL, 1)
SET IDENTITY_INSERT [dbo].[Transfer_log] OFF
