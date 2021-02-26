/*
Some of the frustration of learning XML is in not being able to
see clearly an entire process. So many of the existing manuals 
concentrate on just one step in a chain and leave the reader saying
'very technological. So what?' 

In other cases, XML is used in illustrations with tiny fragments of 
real data, losing sight of the great value of XML as a means of 
exchanging large amounts of information

We'll try to take a different approach here in order to give it all
some purpose. We're not going to even try to provide anything 
comprehensive here, more of a quick spin around the block

OK. Let's assume that we want an application which seeks to list out
the nearest hundred pubs to any postcode in Britain. (apologies to our 
many friends outside Britain).

We have two XML files that gives the raw data, collected from several
Publicly available sources. they are supplied with the article. One gives
the location of every 'outcode', and the other every pub, with their 
postcode. Tantalising?

in this Workbench we will
	Read an XML file into a SQL Server XML Variable
	Shred an XML variable into a SQL Server table
	Query an XML variable for a set of values as an XML result
	assign the result of a SQL query to an XML variable
	Store the contents of an XML variable to a table
	Save an XML value to a file.

Let's read the XML location information from a file into a table!

Reading an XML file into a SQL Server XML Variable
--------------------------------------------------

Assume we have  the XML file unzipped in C:\workbench\locations.xml

First pull the file into a conventional relational table... 

*/
DECLARE @xmlLocations XML
SELECT  @xmlLocations = BulkColumn
FROM    OPENROWSET(BULK 'C:\workbench\locations.xml', SINGLE_BLOB) AS x 

/* we can store this XML data in  a table with an XML column */

CREATE TABLE xTable
    (
      xTable_ID INT IDENTITY
                    PRIMARY KEY,
      xCol XML
    ) ;

/* we then insert a row into the table from the XML variable */
INSERT  INTO xTable ( xCol )
        SELECT  @xmlLocations

/*
Shredding an XML variable into a SQL Server table
-------------------------------------------------

 now we'll put it into a conventional table for working on. First 
we define it */
CREATE TABLE [dbo].[location]
    (
      [location_ID] [int] IDENTITY(1, 1)
                          NOT NULL,
      [whereabouts] [varchar](100) NULL,
      [Town] [varchar](80) NULL,
      [city] [varchar](80) NULL,
      [county] [varchar](40) NULL,
      [region] [varchar](40) NULL,
      [outcode] [varchar](4) NULL,
      [x] [int] NULL,
      [y] [int] NULL,
      [latitude] [numeric](18, 3) NULL,
      [longitude] [numeric](18, 3) NULL
    )
ON  [PRIMARY]

/* and now we can simply shred the XML data type that we've read in
into the table, using the XML Data type nodes() method.  */

INSERT  INTO location
        (
          whereabouts,
          town,
          city,
          county,
          region,
          outcode,
          x,
          y,
          latitude,
          Longitude
        )
        SELECT  x.location.value(
                    'whereabouts[1]', 'varchar(100)') AS whereabouts,
                x.location.value(
                    'town[1]', 'varchar(80)') AS town,
                x.location.value(
                    'city[1]', 'varchar(80)') AS city,
                x.location.value(
                    'county[1]', 'varchar(40)') AS county,
                x.location.value(
                    'region[1]', 'varchar(40)') AS region,
                x.location.value(
                    'outcode[1]', 'varchar(4)') AS outcode,
                x.location.value(
                    'x[1]', 'int') AS x,
                x.location.value(
                    'y[1]', 'int') AS y,
                x.location.value(
                    'latitude[1]', 'numeric(18, 3) ') AS latitude,
                x.location.value(
                    'longitude[1]', 'numeric(18, 3)') AS longitude
        FROM    @xmlLocations.nodes('//locations/location') 
                                    AS x ( location )

/* now we can try it out by finding the nearest places to a particular 
postcode*/
go

CREATE PROCEDURE spWhereIsThis @Postcode VARCHAR(10)
/*
spWhereIsThis 'cm2'
*/
AS 
    DECLARE @x INT,
        @y INT


    SELECT TOP 1--find out our coordinates
            @x = x,
            @y = y
    FROM    location
    WHERE   outcode LIKE RTRIM(LEFT(SUBSTRING(@Postcode, 1,
                              CHARINDEX(' ', @Postcode + ' ',
                                                 1) - 1), 4))
    IF @@Rowcount = 0 --typo!
        BEGIN
            RAISERROR ( 'I don''t recognise the postcode ''%s''', 16, 1,
                @postcode )
            RETURN 1
        END

    SELECT TOP 100--list the 100 nearest locations
            whereabouts,
            region,
            [miles] = ROUND(SQRT(SQUARE(X - @X) + SQUARE(Y - @Y)) 
                       * 0.0006214,0)
    FROM    location
    WHERE   x IS NOT NULL
    ORDER BY miles
go

/*
	Querying an XML variable for a set of values as an XML result
    -------------------------------------------------------------

we can extract data directly from the XML column if we wish
*/
SELECT  xCol.query('
   for $LOC in /locations/location
   where $LOC/outcode[.="CM2"]
   return
     <coordinate>
      { $LOC/x }
      { $LOC/y }
      { $LOC/town }
     </coordinate>
') AS Result
FROM    [XTable]

/* but as the XQUERY string must be a string literal and not a 
string variable, we need to put parameters in via a sql:variable
parameter like this....*/

DECLARE @Postcode VARCHAR(10)
SELECT  @Postcode = 'CO8'

SELECT  xCol.query('
   for $LOC in /locations/location
where $LOC/outcode = sql:variable("@Postcode") 
   return
     <locations>
      { $LOC/whereabouts }
      { $LOC/county }
     </locations>
') AS Result
FROM    [XTable]


/* Now, this is an open-ended workbench. You have a nice large
source of data, and BOL is now screaming at you to be read. Try
out some FLWOR!

When you tire, it is time to  pull in a list of british pubs.  */

DECLARE @xmlPubs XML
SELECT  @xmlPubs = BulkColumn
FROM    OPENROWSET(BULK 'C:\workbench\pubs.xml', SINGLE_BLOB) AS x 

CREATE TABLE dbo.Pub
    (
      Pub_ID INT IDENTITY(1, 1)
                 NOT NULL,
      [Name] VARCHAR(30) NOT NULL,
      Address VARCHAR(100) NOT NULL,
      outcode VARCHAR(4) NOT NULL,
      x INT NULL,
      y INT NULL
    )
ON  [PRIMARY]

INSERT  INTO Pub
        (
          [name],
          address,
          outcode
        )
        SELECT  x.pub.value('name[1]', 'varchar(30)'),
                x.pub.value('address[1]', 'varchar(100)'),
                RTRIM(LEFT(
                     SUBSTRING(x.pub.value('postcode[1]', 'varchar(10)'),
                                     1,
                                     CHARINDEX(' ',
                                               x.pub.value('postcode[1]',
                                                           'varchar(10)')
                                               + ' ', 1) - 1), 4
					 ))
        FROM    @xmlPubs.nodes('//pubs/pub') AS x ( pub )

UPDATE  pub
SET     x = f.x, y = f.y
FROM    pub
        INNER JOIN location f ON pub.outcode = f.outcode


ALTER PROCEDURE spNearestPubs @Postcode VARCHAR(10)
/*
spNearestPubs 'co10'
*/
AS 
    DECLARE @x INT,
        @y INT


    SELECT TOP 1--find out our coordinates
            @x = x,
            @y = y
    FROM    location
    WHERE   outcode LIKE RTRIM(LEFT(SUBSTRING(@Postcode, 1,
                                         CHARINDEX(' ', @Postcode + ' ',
                                                            1) - 1), 4))
    IF @@Rowcount = 0 --typo!
        BEGIN
            RAISERROR ( 'I don''t recognise the postcode ''%s''', 16, 1,
                @postcode )
            RETURN 1
        END

    SELECT TOP 100--list the 100 nearest locations
            name + ' ' + address,
            [miles] = ROUND(
                           SQRT(SQUARE(X - @X) + SQUARE(Y - @Y))
							* 0.0006214,0)
    FROM    pub
    WHERE   x IS NOT NULL
    ORDER BY miles
go

/*
	assigning the result of a SQL query to an XML variable
    ------------------------------------------------------

 well, nice as far as it goes, but why not pass the result back as
an XML variable, and we'll then we can save it direct to disk, or
send it happily to an application, store it in a table as a variable?

XML could be quite handy!
*/
ALTER PROCEDURE spNearestPubsXML
    @Postcode VARCHAR(10),
    @XMLPubList XML OUTPUT
/*
e.g.
Declare @PubList xml
execute spNearestPubsXML 'co10',	@XMLPubList=@PubList output
Select @PubList
*/
AS 
    DECLARE @x INT,
        @y INT


    SELECT TOP 1--find out our coordinates
            @x = x,
            @y = y
    FROM    location
    WHERE   outcode LIKE RTRIM(LEFT(SUBSTRING(@Postcode, 1,
                                        CHARINDEX(' ', @Postcode + ' ',
                                                           1) - 1), 4))
    IF @@Rowcount = 0 --typo!
        BEGIN
            RAISERROR ( 'I don''t recognise the postcode ''%s''', 16, 1,
                @postcode )
            SET @XMLPubList = '<pubs />'
            RETURN 1
        END

    SET @XMLPubList = ( SELECT TOP 100--list the 100 nearest locations
                                [name] = name + ', ' + address,
                                [miles] = CONVERT(INT, 
                                            ROUND(SQRT(
                                               SQUARE(X - @X) 
                                               + SQUARE(Y - @Y))
                                            * 0.0006214, 0))
                        FROM    pub
                        WHERE   x IS NOT NULL
                        ORDER BY miles
                      FOR
                        XML PATH('pub'),
                            ROOT('pubs'),
                            TYPE
                      )
go
--we can then save the results to disk very easily
DECLARE @PubList XML
EXECUTE spNearestPubsXML 'BR2', @XMLPubList = @PubList OUTPUT

--	We Store the contents of an XML variable to a table
CREATE TABLE xNearestPubs
    (
      xPubs_ID INT IDENTITY
                   PRIMARY KEY,
      xCol XML
    ) ;

INSERT  INTO xNearestPubs ( xCol )
        SELECT  @PubList

/*
	We Save an XML value to a file.
*/
DECLARE @Command VARCHAR(255)
DECLARE @Filename VARCHAR(100)

SELECT  @Filename = 'C:\workbench\Nearestpubs.xml'
/* we then insert a row into the table from the XML variable */
/* so we can then write it out via BCP! */
SELECT  @Command = 'bcp "select xCol from ' + DB_NAME()
        + '..xNearestPubs" queryout ' 
		+ @Filename + ' -w -T -S' + @@servername
EXECUTE master..xp_cmdshell @command
--so now the xml is written out to a file

/*
So there we have it. Hopefully, if you enjoyed this approach to XML by
example, we'll try out more complex examples in further Workbenches.

In the meantime, there are other resources on the site 

and we would also
recommend you to read
on SQL Server Central

