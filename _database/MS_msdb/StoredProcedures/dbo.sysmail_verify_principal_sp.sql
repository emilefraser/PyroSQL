SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_verify_principal_sp
   @principal_id int,
   @principal_name sysname,
   @allow_both_nulls bit,
   @principal_sid varbinary(85) OUTPUT
AS
   IF @allow_both_nulls = 0
   BEGIN
      -- at least one parameter must be supplied
      IF (@principal_id IS NULL AND @principal_name IS NULL)
      BEGIN
         RAISERROR(14604, -1, -1, 'principal')  
         RETURN(1)
      END
   END

   DECLARE @principalid int

   IF (@principal_id IS NOT NULL AND @principal_name IS NOT NULL) -- both parameters supplied
   BEGIN
     SELECT @principalid=principal_id FROM msdb.sys.database_principals 
            WHERE type in ('U','S','G') AND principal_id = @principal_id AND name = @principal_name

      IF (@principalid IS NULL)
      BEGIN
         RAISERROR(14605, -1, -1, 'principal')  
         RETURN(2)
      END
   END
   ELSE IF (@principal_id IS NOT NULL) -- use id
   BEGIN
     SELECT @principalid=principal_id FROM msdb.sys.database_principals 
            WHERE type in ('U','S','G') AND principal_id = @principal_id

      IF (@principalid IS NULL)
      BEGIN
         RAISERROR(14606, -1, -1, 'principal')
         RETURN(3)
      END      
   END
   ELSE IF (@principal_name IS NOT NULL)  -- use name
   BEGIN
     SELECT @principalid=principal_id FROM msdb.sys.database_principals 
            WHERE type in ('U','S','G') AND name = @principal_name

      IF (@principalid IS NULL)
      BEGIN
         RAISERROR(14607, -1, -1, 'principal')
         RETURN(4)
      END      
   END

   -- populate return variable
   SELECT @principal_sid = dbo.get_principal_sid(@principalid)

   RETURN(0) -- SUCCESS

GO
