SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[WriteFirstPortionPersistedStream]
@SessionID varchar(32),
@Index int,
@Name nvarchar(260) = NULL,
@MimeType nvarchar(260) = NULL,
@Extension nvarchar(260) = NULL,
@Encoding nvarchar(260) = NULL,
@Content image
AS

UPDATE [ReportServerTempDB].dbo.PersistedStream set Content = @Content, [Name] = @Name, MimeType = @MimeType, Extension = @Extension WHERE SessionID = @SessionID AND [Index] = @Index

SELECT TEXTPTR(Content) FROM [ReportServerTempDB].dbo.PersistedStream WHERE SessionID = @SessionID AND [Index] = @Index
GO
