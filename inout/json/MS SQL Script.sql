/* Read JSON data in MS SQL */
/* Damir Matešić - https://blog.matesic.info */
/* ######################################### */

/* OPENJSON with default schema */
-- Wrong compatibility version (SQL 2014)
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 120
GO
USE [WideWorldImporters];
GO
-- Not well formated JSON
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name: "Damir Matešić",
"BlogURL": "http:\\blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data);
GO

-- Correct compatibility version (SQL 2016+)
USE [master]
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140
GO
USE [WideWorldImporters];
GO
-- Not well formated JSON
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name: "Damir Matešić",
"BlogURL": "http:\\blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data);
GO

-- Good example
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data);

-- Help Function
CREATE OR ALTER FUNCTION dbo.GetJSONDataType
(
    @JSONDataType TINYINT
)
RETURNS VARCHAR(32)
AS
BEGIN
    RETURN CASE
        WHEN @JSONDataType = 0 THEN 'null'
        WHEN @JSONDataType = 1 THEN 'string'
        WHEN @JSONDataType = 2 THEN 'int'
        WHEN @JSONDataType = 3 THEN 'true/false'
        WHEN @JSONDataType = 4 THEN 'array'
        WHEN @JSONDataType = 5 THEN 'object'
    END
END

-- Again
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data);

-- Selecting "Parents" node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.Parents');

-- Selecting non existing "Friends" node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.Friends');

-- Selecting non existing "Friends" node, with strict option
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, 'strict $.Friends');

-- Selecting Favorite drinks node
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.FavoriteDrinks');

-- Spaces in the key part
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"Blog URL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"Born after woodstock": true,
"Favorite drinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data);

-- Wrong path
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"Blog URL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"Born after woodstock": true,
"Favorite drinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$.Favorite drinks');

-- Correct path
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"Blog URL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"Born after woodstock": true,
"Favorite drinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT *, dbo.GetJSONDataType(type) AS data_type FROM OPENJSON(@JSON_data, '$."Favorite drinks"');

/* OPENJSON with explicit schema */
-- Example
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] NVARCHAR(MAX) '$.FavoriteDrinks' AS JSON,
    Parents NVARCHAR(MAX) '$.Parents' AS JSON
) Data;

-- Not specified AS JSON
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] NVARCHAR(MAX) '$.FavoriteDrinks',
    Parents NVARCHAR(MAX) '$.Parents' 
) Data;

-- Wrong data type in AS JSON columns
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] VARCHAR(MAX) '$.FavoriteDrinks' AS JSON,
    Parents VARCHAR(MAX) '$.Parents' AS JSON
) Data;

-- Get favorite drink details
DECLARE @JSON_data NVARCHAR(MAX) = N'{
"Name": "Damir Matešić",
"BlogURL": "http:\/\/blog.matesic.info",
"Born": 1979,
"Spouse":null,
"BornAfterWoodstock": true,
"FavoriteDrinks": [
{"Name": "Gin and tonic","Drink": "Occasionally"},
{"Name": "Craft beer","Drink": "Occasionally"},
{"Name": "Coffe with milk","Drink": "Daily"},
{"Name": "Cold water","Drink": "Daily"}],
"Parents": {"Mom": "Iva","Dad": "Boris"}
}';
SELECT * FROM OPENJSON(@JSON_data) WITH (
    Name NVARCHAR(256) '$.Name',
    [Blog URL] NVARCHAR(256) '$.BlogURL',
    Born INT '$.Born',
    Spouse NVARCHAR(256) '$.Spouse',
    [Favorite drinks] NVARCHAR(MAX) '$.FavoriteDrinks' AS JSON,
    Parents NVARCHAR(MAX) '$.Parents' AS JSON
) Data
CROSS APPLY OPENJSON([Favorite drinks])
WITH
(
    Name NVARCHAR(256) '$.Name',
    Drink NVARCHAR(256) '$.Drink'
)DrinkData;
