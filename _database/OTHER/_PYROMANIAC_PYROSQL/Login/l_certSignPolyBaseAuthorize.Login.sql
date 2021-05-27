CREATE LOGIN [l_certSignPolyBaseAuthorize] FROM CERTIFICATE [_##PDW_PolyBaseAuthorizeSigningCertificate##]
ALTER SERVER ROLE [sysadmin] ADD MEMBER [l_certSignPolyBaseAuthorize]
GO

