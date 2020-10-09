SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE VIEW [INTEGRATION].[vw_egress_DatabaseInstancesToLoad_New] AS
SELECT	serv.ServerName,
		CASE WHEN dbinst.IsDefaultInstance = 1 THEN 'Default' ELSE dbinst.DatabaseInstanceName END AS DatabaseInstanceName,
		auth.DBAuthTypeName,
		dbinst.AuthUsername,
		dbinst.AuthPassword,
		dbinst.NetworkPort, 
		dbinst.DatabaseInstanceID,
		CASE WHEN auth.DatabaseAuthenticationTypeID = 1 and dbinst.IsDefaultInstance = 1
			THEN  'Data Source='+serv.ServerName+';Initial Catalog=master;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;' 
		  WHEN auth.DatabaseAuthenticationTypeID = 2 and dbinst.IsDefaultInstance = 1
			THEN 'Server='+serv.ServerName+';Database=master;User Id='+dbinst.AuthUsername+';Password='+dbinst.AuthPassword+';'
		  WHEN auth.DatabaseAuthenticationTypeID = 1 and dbinst.IsDefaultInstance = 0
			THEN  'Data Source='+serv.ServerName+'\'+dbinst.DatabaseInstanceName+';Initial Catalog=master;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;' 
		  WHEN auth.DatabaseAuthenticationTypeID = 2 and dbinst.IsDefaultInstance = 0
			THEN 'Server='+serv.ServerName+'\'+dbinst.DatabaseInstanceName+';Database=master;User Id='+dbinst.AuthUsername+';Password='+dbinst.AuthPassword+';'
		END AS ConnectionString
  FROM DC.[DatabaseInstance] dbinst
	   LEFT JOIN DC.[Server] serv ON
			serv.ServerID = dbinst.ServerID
	   LEFT JOIN DC.[DatabaseAuthenticationType] auth ON
			auth.DatabaseAuthenticationTypeID = dbinst.DatabaseAuthenticationTypeID
			where ServerName in ('TSABISQLDEV01','TSAMARTA01')

--ORDER BY
--	   serv.ServerName,
--	   db.DatabaseName,
--	   s.SchemaName,
--	   de.TableName,
--	   f.DBColumnID

GO
