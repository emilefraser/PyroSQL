CREATE LOGIN [l_certSignSmDetach] FROM CERTIFICATE [_##PDW_SmDetachSigningCertificate##]
ALTER SERVER ROLE [sysadmin] ADD MEMBER [l_certSignSmDetach]
GO

