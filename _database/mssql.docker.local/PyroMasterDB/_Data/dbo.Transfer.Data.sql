SET IDENTITY_INSERT [dbo].[Transfer] ON 

INSERT [dbo].[Transfer] ([transfer_id], [batch_id], [transfer_name], [src_obj_id], [target_name], [transfer_start_dt], [transfer_end_dt], [status_id], [rec_cnt_src], [rec_cnt_new], [rec_cnt_changed], [rec_cnt_deleted], [last_error_id], [prev_transfer_id], [transfer_seq]) VALUES (-1, NULL, N'Unknown', NULL, NULL, NULL, CAST(N'2021-02-05T11:06:59.550' AS DateTime), 200, NULL, NULL, NULL, NULL, 3, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Transfer] OFF
