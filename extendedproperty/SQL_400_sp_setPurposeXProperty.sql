USE master

GO
IF OBJECT_ID('[dbo].[sp_setPurposeXProperty]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_setPurposeXProperty] 
GO
--EXEC [sp_setPurposeXProperty] '[dbo].[sp_find]','find object names or column names that are LIKE the inputed value'
CREATE PROCEDURE [dbo].[sp_setPurposeXProperty] (@obj         VARCHAR(255),
                                                    @description VARCHAR(128))
AS
  BEGIN
  --DECLARE @obj         VARCHAR(255) = '[dbo].[sp_find]',@description VARCHAR(128) = 'find object names or column names that are LIKE the inputed value'
      DECLARE @objid     INT,
              @ObjSchema SYSNAME,
              @ObjType   SYSNAME,
              @ObjName   SYSNAME

      SELECT @objid = Object_id(@obj)

      SELECT @ObjSchema = Schema_name( objz.schema_id),
             @ObjName =  objz.name,
             @ObjType = CASE 
                          WHEN objz.type_desc = 'VIEW' THEN 'VIEW'
                          WHEN objz.type_desc = 'USER_TABLE' THEN 'TABLE'
                          WHEN objz.type_desc = 'SQL_STORED_PROCEDURE' THEN 'PROCEDURE'
                          WHEN objz.type_desc = 'SQL_INLINE_TABLE_VALUED_FUNCTION' THEN 'FUNCTION'
                          WHEN objz.type_desc = 'SQL_SCALAR_FUNCTION' THEN 'FUNCTION'
                          WHEN objz.type_desc = 'SQL_TABLE_VALUED_FUNCTION' THEN 'FUNCTION'
                        END
      FROM   sys.objects objz
      WHERE  objz.object_id = @objid
      --SELECT @obj
      --SELECT @description
      --SELECT @objid
      --SELECT  @ObjSchema
      --SELECT @ObjName
      --SELECT @ObjType
      IF @objid IS NOT NULL AND @ObjType IS NOT NULL
          BEGIN
    IF NOT EXISTS(SELECT * FROM   FN_LISTEXTENDEDPROPERTY (NULL, 'SCHEMA', @ObjSchema, @ObjType, @ObjName, NULL, NULL)X WHERE  X.name = 'Purpose')
                  BEGIN
                    EXEC sys.sp_addextendedproperty  
                       @name = N'Purpose',
                       @value = @description,  
                       @level0type = N'SCHEMA',  @level0name =@ObjSchema,
                       @level1type = @ObjType,   @level1name = @ObjName;
                  END
                  ELSE
                  BEGIN
                    EXEC sys.sp_updateextendedproperty  
                       @name = N'Purpose',
                       @value = @description,  
                       @level0type = N'SCHEMA',  @level0name =@ObjSchema,
                       @level1type = @ObjType,   @level1name = @ObjName;
                  END
          END
  END 

EXEC Sp_ms_marksystemobject
  [sp_setPurposeXProperty] 
