SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON







CREATE VIEW [INTEGRATION].[vw_egress_DatabaseInstancesToLoad_New_Type] AS
SELECT	serv.ServerName,
		CASE WHEN dbinst.IsDefaultInstance = 1 THEN 'Default' ELSE dbinst.DatabaseInstanceName END AS DatabaseInstanceName,
		dtl.DetailTypeDescription as [DBAuthTypeName],
		dbinst.AuthUsername,
		dbinst.AuthPassword,
		dbinst.NetworkPort, 
		dbinst.DatabaseInstanceID,
		CASE WHEN dtl.DetailID = 1 and dbinst.IsDefaultInstance = 1
			THEN  'Data Source='+serv.ServerName+';Initial Catalog=master;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;' 
		  WHEN dtl.DetailID = 2 and dbinst.IsDefaultInstance = 1
			THEN 'Server='+serv.ServerName+';Database=master;User Id='+dbinst.AuthUsername+';Password='+dbinst.AuthPassword+';'
		  WHEN dtl.DetailID = 1 and dbinst.IsDefaultInstance = 0
			THEN  'Data Source='+serv.ServerName+'\'+dbinst.DatabaseInstanceName+';Initial Catalog=master;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;' 
		  WHEN dtl.DetailID = 2 and dbinst.IsDefaultInstance = 0
			THEN 'Server='+serv.ServerName+'\'+dbinst.DatabaseInstanceName+';Database=master;User Id='+dbinst.AuthUsername+';Password='+dbinst.AuthPassword+';'
		END AS ConnectionString
  FROM	DC.[DatabaseInstance] dbinst
		LEFT JOIN DC.[Server] serv ON
		 	serv.ServerID = dbinst.ServerID
		INNER JOIN [TYPE].[Generic_Header] hdr ON
		 	hdr.HeaderID = dbinst.DatabaseAuthenticationTypeID
		INNER JOIN [TYPE].[Generic_Detail] dtl ON
			dtl.HeaderID = hdr.HeaderID
  where ServerName in ('TSABISQLDEV01','TSAMARTA01')


--ORDER BY
--	   serv.ServerName,
--	   db.DatabaseName,
--	   s.SchemaName,
--	   de.TableName,
--	   f.DBColumnID

GO
