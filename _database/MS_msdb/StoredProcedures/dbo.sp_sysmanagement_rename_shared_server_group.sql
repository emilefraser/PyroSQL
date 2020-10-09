SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysmanagement_rename_shared_server_group]
    @server_group_id INT,
    @new_name sysname
AS
BEGIN
    IF (@server_group_id IS NULL)
    BEGIN
        RAISERROR (35006, -1, -1)
        RETURN(1)
    END
    
    IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] WHERE server_group_id = @server_group_id)
    BEGIN
        RAISERROR (35007, -1, -1)
        RETURN(1)
    END
    
    IF (@new_name IS NULL or LEN(@new_name) = 0)
    BEGIN
      RAISERROR(21263, -1, -1, '@new_name')
      RETURN(1) -- Failure
    END

    UPDATE [msdb].[dbo].[sysmanagement_shared_server_groups_internal]
        SET name = @new_name
    WHERE
        server_group_id = @server_group_id

    RETURN (0)
END

GO
