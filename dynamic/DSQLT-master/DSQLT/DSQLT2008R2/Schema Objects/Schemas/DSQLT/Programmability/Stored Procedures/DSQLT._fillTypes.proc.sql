

CREATE PROCEDURE [DSQLT].[_fillTypes]
AS
BEGIN
BEGIN TRANSACTION
truncate table [DSQLT].[Types]
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (34, 'image', '%t', 'null', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (35, 'text', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (36, 'uniqueidentifier', '%t', 'newid()', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (40, 'date', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (41, 'time', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (42, 'datetime2', '%t', '''''', '%v', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (43, 'datetimeoffset', '%t', '''''', '%v', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (48, 'tinyint', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (52, 'smallint', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (56, 'int', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (58, 'smalldatetime', '%t', '''''', 'CONVERT(varchar(8),%v,112)', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (59, 'real', '%t', '0', 'round(%v,5)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (60, 'money', '%t', '0', 'round(%v,2)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (61, 'datetime', '%t', '''''', 'CONVERT(varchar(8),%v,112)', 'CONVERT(varchar(max),%v,126)')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (62, 'float', '%t', '0', 'round(%v,5)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (98, 'sql_variant', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (99, 'ntext', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (104, 'bit', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (106, 'decimal', '%t(%p,%s)', '0', 'round(%v,%s)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (108, 'numeric', '%t(%p,%s)', '0', 'round(%v,%s)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (122, 'smallmoney', '%t', '0', 'round(%v,2)', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (127, 'bigint', '%t', '0', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (128, 'hierarchyid', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (129, 'geometry', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (130, 'geography', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (165, 'varbinary', '%t(%l)', 'null', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (167, 'varchar', '%t(%l)', '''''', 'cast(%v as %t(%l))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (173, 'binary', '%t(%l)', 'null', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (175, 'char', '%t(%l)', '''''', 'cast(%v as %t(%l))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (189, 'timestamp', '%t', '''''', '%v', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (231, 'nvarchar', '%t(%h)', '''''', 'cast(%v as %t(%h))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (239, 'nchar', '%t(%h)', '''''', 'cast(%v as %t(%h))', '%v')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (241, 'xml', '%t', 'null', 'cast(%v as varchar(max))', 'cast(%v as varchar(max))')
INSERT INTO [DSQLT].[Types] ([type_id], [type_name], [type_pattern], [type_default], [type_comparison], [type_concatvalue]) VALUES (256, 'sysname', '%t', '''''', '%v', '%v')
COMMIT TRANSACTION
END