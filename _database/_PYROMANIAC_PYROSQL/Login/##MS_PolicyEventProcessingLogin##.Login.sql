/* For security reasons the login is created disabled and with a random password. */
CREATE LOGIN [##MS_PolicyEventProcessingLogin##] WITH PASSWORD=N'S65XlkwRD6T3xjouL9TnFsUHcYQpKocNL/ku6Hk2Jb4=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
ALTER LOGIN [##MS_PolicyEventProcessingLogin##] DISABLE
GO

