SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW vw_autoadmin_health_status
AS
    SELECT CONVERT(VARCHAR, GETDATE()) 'Datetime', 
        @@servername 'Instance name', 
        CONVERT(VARCHAR, number_of_storage_connectivity_errors) AS 'Storage errors',
        CONVERT(VARCHAR, number_of_sql_errors) AS 'Sql errors',
        CONVERT(VARCHAR, number_of_invalid_credential_errors) AS 'Credential errors',
        CONVERT(VARCHAR, number_of_other_errors) AS 'Other errors',
        CONVERT(VARCHAR, number_of_corrupted_or_deleted_backups) AS 'Deleted or invalid backup files',
        CONVERT(VARCHAR, number_of_backup_loops) AS 'Number of backup loops',
        CONVERT(VARCHAR, number_of_retention_loops) AS 'Number of retention loops'
    FROM smart_admin.fn_get_health_status(default, default)

GO
