SET IDENTITY_INSERT [dbo].[Batch] ON 

INSERT [dbo].[Batch] ([batch_id], [batch_name], [batch_start_dt], [batch_end_dt], [status_id], [last_error_id], [prev_batch_id], [exec_server], [exec_host], [exec_user], [guid], [continue_batch], [batch_seq]) VALUES (-1, N'Unknown', CAST(N'2021-02-05T11:06:59.440' AS DateTime), NULL, NULL, NULL, NULL, N'PYROMANIAC\PYROSQL', N'PYROMANIAC', N'PYROMANIAC\efras', NULL, 0, NULL)
SET IDENTITY_INSERT [dbo].[Batch] OFF
