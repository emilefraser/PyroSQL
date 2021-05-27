/* For security reasons the login is created disabled and with a random password. */
CREATE LOGIN [##MS_PolicyTsqlExecutionLogin##] WITH PASSWORD=N'5nFIP4ld+nyHzNEcKZpTLz6rC6a+NAVQ1Vs/giKarlA=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
ALTER LOGIN [##MS_PolicyTsqlExecutionLogin##] DISABLE
GO

