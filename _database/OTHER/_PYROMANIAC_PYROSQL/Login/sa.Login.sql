/* For security reasons the login is created disabled and with a random password. */
CREATE LOGIN [sa] WITH PASSWORD=N'R/pH0QZbKKFc63ZSTzYpQYPLUKKeMWdeNTmhe8QdHUc=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
ALTER LOGIN [sa] DISABLE
ALTER SERVER ROLE [sysadmin] ADD MEMBER [sa]
GO

