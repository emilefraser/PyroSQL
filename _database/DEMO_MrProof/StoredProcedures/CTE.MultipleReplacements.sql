SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE CTE.MultipleReplacements
AS

DROP TABLE IF EXISTS CTE.Original 

CREATE TABLE CTE.Original (
	val NVARCHAR(50)
)

INSERT INTO  CTE.Original (val) VALUES ('banana')
INSERT INTO  CTE.Original (val) VALUES ('apples')

DROP TABLE IF EXISTS CTE.ReplaceData 

CREATE TABLE  CTE.ReplaceData (
    old	NVARCHAR(50),
    new NVARCHAR(50)
)

INSERT INTO  CTE.ReplaceData VALUES('p', 'Q')
INSERT INTO  CTE.ReplaceData VALUES('s', 'Z')
INSERT INTO  CTE.ReplaceData VALUES('a', 'A')

GO