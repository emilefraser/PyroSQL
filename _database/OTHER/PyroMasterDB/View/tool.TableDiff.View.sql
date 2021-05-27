SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[tool].[TableDiff]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [tool].[TableDiff]
AS
WITH CTE_Dev
AS (
    SELECT ColumnId_LEFT = C.column_id
        ,ColumnName_LEFT = C.NAME
        ,MaxLength_LEFT = C.max_length
        ,UserTypeID_LEFT = C.user_type_id
        ,Precision_LEFT = C.precision
        ,Scale_LEFT = C.scale
        ,DataTypeName_LEFT = T.NAME
    FROM sys.columns C
    INNER JOIN sys.types T ON T.user_type_id = C.user_type_id
    WHERE OBJECT_ID = OBJECT_ID(''ext.BSEG_Accounting_Segment'')
    )
    ,CTE_Temp
AS (
    SELECT ColumnId_RIGHT = C.column_id
        ,ColumnName_RIGHT = C.NAME
        ,MaxLength_RIGHT = C.max_length
        ,UserTypeId_RIGHT = C.user_type_id
        ,Precision_RIGHT = C.precision
        ,Scale_RIGHT = C.scale
        ,DataTypeName_RIGHT = T.NAME
    FROM sys.columns C
    INNER JOIN sys.types T ON T.user_type_id = C.user_type_id
    WHERE OBJECT_ID = OBJECT_ID(''ini.BSEG_Accounting_Segment'')
    )
SELECT *
FROM CTE_Dev D
FULL OUTER JOIN CTE_Temp T ON D.ColumnName_LEFT= T.ColumnName_RIGHT
WHERE ISNULL(D.MaxLength_LEFT, 0) < ISNULL(T.MaxLength_RIGHT, 999)
' 
GO
