/* For security reasons the login is created disabled and with a random password. */
CREATE LOGIN [pyromaniac] WITH PASSWORD=N'TcjuqbLH/vPVlbRmbC+yMYpqDeiz8vZgfIEnULEn6OY=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
ALTER LOGIN [pyromaniac] DISABLE
ALTER SERVER ROLE [sysadmin] ADD MEMBER [pyromaniac]
GO

