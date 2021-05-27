SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[JsonUpsert]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[JsonUpsert] AS' 
END
GO
ALTER   PROCEDURE [inout].[JsonUpsert]
AS

/* Importing JSON collections of documents into SQL Server is fairly easy if there is an underlying table schema
 to them. If the documents have  different schemas then you have little chance. Fortunately, this is rare
 Let's start this gently, putting simple collections into strings which we will insert into a table. 
 We'll use the example of sheep-counting words, collected from many different parts of Great Britain and 
 Brittany. The simple aim is to put them into a table */


IF Object_Id('SheepCountingWords','U') IS NOT NULL DROP TABLE SheepCountingWords
CREATE TABLE SheepCountingWords
  (
  Number INT NOT NULL,
  Word NVARCHAR(40) NOT NULL,
  Region NVARCHAR(40) NOT NULL,
  CONSTRAINT NumberRegionKey PRIMARY KEY  (Number,Region)
  );
GO
