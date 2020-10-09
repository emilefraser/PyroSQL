SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 
 
 
CREATE VIEW [DC].[vw_mat_Credentials] AS
SELECT
       [ServerName]
      ,[DatabaseInstanceName]
      ,[DBAuthTypeName] As AuthType
      ,[AuthUsername] AS Username
      ,[AuthPassword] As Password
  FROM [DC].[Server] A
 
  left join dc.DatabaseInstance B
         on A.ServerID = B.ServerID
 
  left join dc.DatabaseAuthenticationType C
         on B.DatabaseAuthenticationTypeID = C.DatabaseAuthenticationTypeID
 

GO
