SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_syscollector_get_package_path] 
(
    @package_id uniqueidentifier
)
RETURNS NVARCHAR(4000)
AS
BEGIN
    IF @package_id IS NULL
        RETURN NULL

    DECLARE @package_path nvarchar(4000)
    DECLARE @prevfolderid uniqueidentifier
    DECLARE @folderid uniqueidentifier
    DECLARE @package_name sysname
    SET @package_path = ''

    SELECT @package_name = name, 
            @folderid = folderid 
    FROM dbo.sysssispackages
    WHERE id = @package_id

    WHILE (@folderid != '00000000-0000-0000-0000-000000000000')
    BEGIN
        SET @prevfolderid = @folderid

        DECLARE @foldername sysname
        SELECT @foldername = foldername, 
                @folderid = parentfolderid 
        FROM dbo.sysssispackagefolders
        WHERE folderid = @prevfolderid
        SET @package_path = @foldername + N'\\' + @package_path
    END

    SET @package_path = N'\\' + @package_path + @package_name
    RETURN @package_path
END

GO
