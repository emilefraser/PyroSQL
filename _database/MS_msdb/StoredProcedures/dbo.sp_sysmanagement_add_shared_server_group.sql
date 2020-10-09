SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysmanagement_add_shared_server_group]
    @name sysname,
    @description NVARCHAR (2048) = N'',
    @parent_id INT,
    @server_type INT,
    @server_group_id INT OUTPUT
AS
BEGIN
    DECLARE @retval INT

    EXECUTE @retval = sp_sysmanagement_verify_shared_server_type @server_type

    IF (@retval <> 0)
        RETURN(1) -- Failure
    
    -- user created server groups should have a valid parent 
    IF( (@parent_id IS NULL) OR 
        (@parent_id NOT IN (SELECT sg.server_group_id FROM msdb.dbo.sysmanagement_shared_server_groups_internal sg)))
    BEGIN
        RAISERROR (35001, -1, -1)
        RETURN (1)
    END

    IF EXISTS (SELECT * FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal]  sg 
                WHERE @parent_id = sg.server_group_id AND @server_type <> sg.server_type)
    BEGIN
        RAISERROR (35002, -1, -1)
        RETURN (1)
    END    
    
    INSERT INTO [msdb].[dbo].[sysmanagement_shared_server_groups_internal]
        (name, description, parent_id, server_type)
    VALUES
        (
        @name, 
        @description, 
        @parent_id, 
        @server_type
        )

    SELECT @server_group_id = SCOPE_IDENTITY()
    RETURN (0)
END

GO
