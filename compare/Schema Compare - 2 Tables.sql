SELECT
  tleft.name				AS tleft_columnname
, tright.name				AS tright_columnname
, tleft.is_nullable			AS tleft_is_nullable
, tright.is_nullable		AS tright_is_nullable
, tleft.system_type_name	AS tleft_datatype
, tright.system_type_name   AS tright_datatype
, tleft.is_identity_column  AS tleft_is_identity
, tright.is_identity_column AS tright_is_identity
FROM
	sys.dm_exec_describe_first_result_set(N'SELECT * FROM DataManager.ETL.ExecutionLogSteps', NULL, 0) tleft
FULL OUTER JOIN
	sys.dm_exec_describe_first_result_set(N'SELECT * FROM DataManager_Local.ETL.ExecutionLogSteps', NULL, 0) tright
	ON tleft.name = tright.name
GO
