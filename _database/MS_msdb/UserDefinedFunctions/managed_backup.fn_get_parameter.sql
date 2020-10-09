SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION managed_backup.fn_get_parameter(@parameter_name NVARCHAR(128))
       RETURNS @t table
       (
              parameter_name       NVARCHAR(128),
              parameter_value      NVARCHAR(MAX)
       )
AS
BEGIN
       SET @parameter_name = ISNULL(@parameter_name, '')

       INSERT INTO @t
       SELECT name, value 
       FROM autoadmin_system_flags
       WHERE 
       (
              QUOTENAME(@parameter_name) = QUOTENAME(N'') OR
              QUOTENAME(@parameter_name) = QUOTENAME(name)
       )

       RETURN
END

GO
