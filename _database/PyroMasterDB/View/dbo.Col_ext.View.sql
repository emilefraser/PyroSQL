SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[Col_ext]'))
EXEC dbo.sp_executesql @statement = N'
	  

CREATE   VIEW [dbo].[Col_ext]
AS
SELECT    
c.column_id
, c.column_name
, c.Column_type_id
, ct.Column_type_name
,o.[schema_name]
, o.[db_name],
o.full_obj_name,   c.prefix, c.[entity_name], c.foreign_column_id , foreign_c.column_name foreign_column_name, lookup_foreign_cols.foreign_sur_pkey  , lookup_foreign_cols.foreign_sur_pkey_name
, c.is_nullable, c.ordinal_position, c.data_type, c.max_len, c.numeric_precision, c.numeric_scale, c.src_column_id,  o.[obj_id] , o.[obj_name]
, c.chksum
, c.part_of_unique_index
, o.server_type_id 
FROM dbo.Col AS c 
INNER JOIN dbo.Obj_ext AS o ON c.obj_id = o.obj_id
LEFT JOIN static.Column_type ct ON c.Column_type_id = ct.Column_type_id
LEFT JOIN dbo.Col AS foreign_c ON foreign_c.column_id = c.foreign_column_id  AND foreign_c.delete_dt IS NULL 
LEFT JOIN ( 
	SELECT c1.column_id, c1.foreign_column_id, c3.column_id foreign_sur_pkey, c3.column_name foreign_sur_pkey_name
	, ROW_NUMBER() OVER (PARTITION BY c1.column_id ORDER BY c3.ordinal_position ASC) seq_nr 
	FROM dbo.Col c1
	INNER JOIN dbo.Col c2 ON c1.[foreign_column_id] = c2.column_id 
	INNER JOIN dbo.Col c3 ON c3.[obj_id] = c2.[obj_id] AND c3.Column_type_id=200 -- sur_pkey
	WHERE c1.[foreign_column_id] IS NOT NULL 
) lookup_foreign_cols ON lookup_foreign_cols.column_id = c.column_id AND lookup_foreign_cols.seq_nr = 1 
WHERE        (c.delete_dt IS NULL) 
/*
SELECT * 
FROM vw_column
WHERE column_id IN ( 1140) 
*/











' 
GO
