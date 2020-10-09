SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_filegroups_with_policy_violations 
   @new_set_number INT
WITH EXECUTE AS OWNER
AS
BEGIN
   INSERT INTO sysutility_ucp_filegroups_with_policy_violations_internal(
        server_instance_name, 
        database_name, 
        [filegroup_name],
        policy_id,
        set_number)
      SELECT fg1.server_instance_name,
             fg1.database_name,
             fg1.[filegroup_name],
             fg1.policy_id,
             @new_set_number
      FROM (SELECT pv.policy_id,
                   f.server_instance_name, f.database_name, f.[filegroup_name], 
                   COUNT(*) as policy_violations
            FROM dbo.sysutility_ucp_database_files AS f,
                 dbo.sysutility_ucp_policy_violations AS pv
            WHERE f.powershell_path = pv.target_query_expression 
            GROUP BY pv.policy_id, f.server_instance_name, f.database_name, f.[filegroup_name]) as fg1,
            (SELECT f.server_instance_name, f.database_name, f.[filegroup_name],
                    COUNT(*) as file_count
             FROM dbo.sysutility_ucp_database_files AS f
             GROUP BY f.server_instance_name, f.database_name, f.[filegroup_name]) AS fg2
      WHERE fg1.server_instance_name = fg2.server_instance_name AND
            fg1.database_name = fg2.database_name AND
            fg1.[filegroup_name] = fg2.[filegroup_name] AND
            fg1.policy_violations = fg2.file_count     
END

GO
