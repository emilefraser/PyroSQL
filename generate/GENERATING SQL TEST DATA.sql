/*
My particular use case
I decided to roll my own solution, rather than to use SQL Data Generator, because the particular nature of my use case. I wanted to fill a table that has no names, addresses, bank accounts, or credit card numbers at all (which are the areas where the tool really shines), but that does have a lot of related columns and denormalized data (which SQL Data Generator doesn’t handle well).

Two of the presentations that I regularly deliver at community events are both about the SQL Server 2012 Columnstore Index feature. This feature is most useful in a Data Warehousing (DW) environment – as such, it really needs a very big table if you want to see where it shines, where its limitations start to hurt, and how to work around those limitations to make it shine again. And with “very big”, I am not talking about thousands of rows, and not even about a few million – I like to have at least a hundred million rows when I demonstrate the Columnstore Index.

I have previously delivered these presentations using a database that was given to me by Microsoft, with permission to use but not to redistribute, but that never felt right to me. When I do a presentation, I want the attendees to be able to download and play with my scripts afterwards. Well, the scripts are available for download – but without the database they run on, opportunities for playing with them are rather limited! When, therefore, I was asked to deliver one of my Columnstore Index presentations at the SQL Server Connections conference (Las Vegas, Sep 30-Oct 4, 2013), and I found myself in the rare possession of enough hours to spare, I could finally do what I wanted to do all the time – create my own demo database to use in my presentations on the Columnstore Index.

Decision time
My first decisions were easy to make. I decided to base my big demo database on AdventureWorksDW2012 which is the Data Warehouse version of AdventureWorks2012, and to make a very big version of just one of the fact tables. I wished to merely restore a copy of that database to my new database (AdventureWorksDW2012XL) and add that single table only, with the data in all dimension tables already there.

A normal “big” DW database would probably have small dimension tables, but lots of rows in all fact tables, so it wasn’t entirely realistic to increase only one fact table. But I plan to base all my demos on a single fact table only. I could in fact even decide to drop all the other fact tables and leave only the dimension tables and this single big fact table.

The table I use as my starting point is FactResellerSales. Again: a simple choice. This was the table used for the same purpose in the Microsoft-supplied demo database I used so far, so I was already familiar with it. Its columns are varied enough to allow me to set up some nice queries that can showcase the Columnstore Index features and limitations nicely.

So I created a new table, FactResellerSalesXL, with the exact same schema, indexes, and constraints as the original. With one exception – a table the size I intend it to be should be partitioned, and I decided to stick with the more or less standard pattern of partitioning by date. Unfortunately, this made it impossible to enforce the actual primary key (on order number and order line number), because a partitioned table requires that the partitioning column is included in the PRIMARY KEY and in all UNIQUE constraints.

Valid dates
The data in the AdventureWorks sample databases is already a few years old. The actual date range is not really relevant for most demos, but since I’ll generate the data anyway, I opted to add an extra touch of realism by moving the data nearer to the present. The data I generate spans the period from January 2009 up to and including August 2013. That’s a total of 56 months.

That does require me to make some changes to two other tables in my database. The immediate obvious one is DimDate, the date dimension table. I had to add dates for the calendar years 2011, 2012, and 2013. The query that is used to do that is big and ugly, because of the large number of columns used in this dimension table, but also very straightforward. I could have made it simpler by populating dummy data in the columns I will never use in my demos anyway – but again, I like to be as realistic as possible.

A more unexpected change is required in the DimProduct table. This table is set up as a type 2 slowly changing dimension table, which means that when properties of a product change, the old row is kept with an end-date equal to yesterday; and a new row with start-date equal to today is entered. The data in this table was already inconsistent, because some of the end-dates were earlier then the start-dates – and all start and end dates predate the period for which I will generate data. So to make this a bit more realistic, I modified the start and end dates such that all data is consistent, and the valid products and their properties actually change during the relevant period.

The orders
The FactResellerSales table is a fact table that combines data for order headers and for order lines. I could of course decide to generate completely random order numbers and order line numbers (especially since I had to drop the PRIMARY KEY constraint on the combination of those columns), but that would not be very realistic. Instead, I decided to generate actual orders, each with a random number of order lines. I’ll discuss the generation of order lines later, for now it’s sufficient to understand that the average number of order lines will be five per order – this is relevant, because I want to ensure that I end up with approximately a hundred million rows in the FactResellerSalesXL table, which means I’ll have to generate approximately twenty million orders.

After playing with the numbers a bit, I decided to mimic a business that is growing at a steady pace. I start with 5,000 orders on the first day (January 1st, 2009) and grow that number by 0.1% per day in 2009, 2010, and 2011. In 2012 and 2013, the growth increases to 0.15% per day. A quick calculation reveals that this will produce a total of almost 24.8 million orders over the whole period – close enough; but this algorithm produces a very unrealistic pattern of orders per day. Actual businesses see large variations in the business day over day. So I use the above algorithm to calculate a trend of the average orders per day, but then use a random factor to set the actual number of orders to somewhere between 90% and 110% of that average.

Depending on the type of business you want to mimic, this can be okay (with maybe a smaller or larger variation), or you may need to tweak the algorithm for season peaks or for higher or lower sales on some days in the week.

Order number
Orders need an order number, of course. The original FactResellerSales table has order numbers in the format “SO” + a five-digit number. (Yeah, I agree, anything that has letters in it should not be called a “number”. I blame Microsoft. It’s not even the worst column name they’ve come up with). This format allows for 100,000 different values – not enough. But a small variation fixes this – instead of prefixing the numbers with the letters “SO”, I’ll prefix them with any combination of two letters. Since there are 26 * 26 two-letter combinations, this gives me 67.6 million different values: This should be enough.

My first attempt used some simple logic to concatenate a five-digit counter with two letters; after each order I would increase the counter; when it hits 100,000, I reset it, increase the first letter until it goes beyond “Z”, at which point I increase the second letter and reset the first to “A”. Simple, effective – but it forced me to process each order individually. SQL Server is not optimized for that, and I try to avoid it. In this case, I already had a loop to process each individual date in the relevant period; creating a second loop to iterate over orders and nesting that in the other loop was not acceptable.

The solution I found was to calculate the order number from an actual count of the number of orders already generated. This means that now, after all those years, I finally found a good use for the time I spent in college trying to understand non-decimal numeral systems, such as binary (base 2), hexadecimal (base 16), octal (base 8), duodecimal (base 12), or even sexagesimal (base 60). In this case, I could interpret the order number as a number in a weird combination of decimal (our familiar base 10 numerals) and hexavigesimal (base 26 – and yes, that word actually exists, I did not make it up, though I wish I had).

Another way to put it is to say that I divide the order count by 100,000, use the remainder (always a number between 0 and 99,999) for the five numbers at the end, and use quotient for the two letters – by representing it in base-26. That is, I divide this quotient by 26, use the remainder of THAT division (0-25) to find one letter, and the quotient for the other. A nice extra feature of this approach is that it is now extremely easy to add extra letters – in the code, I have added a comment to show how to change the expression to add a third letter, boosting the available number of orders to over 17.5 billion.

Order lines
I have already mentioned that every order will have a random number of order lines. In my quest for realism, I decided not to simply pick a number between 1 and a maximum, because that would be a very unrealistic distribution. In a real company, you will have a relatively large number of orders with only a few lines, and a much smaller number of big orders. I was unable to find a way to get such a distribution of random numbers using set-based T-SQL code only, so I decided to make a quick detour to .Net for this – I wrote a simple CLR user-defined function to start with 1, and then keep adding 1 in a loop with a 80% to keep looping and a 20% chance to stop. This will result in 20% of the results being 1, 16% being 2, 12.8% being 3, 10.24% being 4, and so on. I added a hard cap at 1000, because you have to draw a line somewhere. (I could have chosen 32,000 and still be able to use a smallint for the results, but 1,000 seemed a nice number). The chance of actually really needing this cap is not very big – the chance of staying in the loop for a thousand times in a row is only 1.23 x 10-97. Or to put it in another way, if all seven billion people on the earth run the script to generate this database every second (which means they will all need a computer that is a LOT faster than mine!), then the number of years that will pass until it is likely that the limit has been reached at least once is still a 72-digit number that I will not try to pronounce.

Since I am not very experienced at C#, writing the code was a challenge. Okay, the loop itself was simple enough, even for me, but how to deal with the randomizer object? My first attempt had the declaration of the randomizer as part of the method itself. That appeared to work well when I did some test calls – but when I used the function in a set-based query, I often got the same result on every line. The reason for this turned out to be that the randomizer was reseeded on every call, and the new seed was based on the internal system clock – so if the calls were quick enough, they’d be the same every time. Now there may have been a way around this, but I wanted to avoid the overhead of reseeding the randomizer on every call anyway, so I decided to move the randomizer outside the function body and make it a global object instead. When Visual Studio started to complain that static objects have to be marked read only, I had my doubts whether this was going to work – somewhere in the black box that is called “randomizer”, there is a seed that is changed on each call, so I expected the “readonly” attribute to cause errors. However, much to my surprise, this turned out not to be the case. I now got nice random numbers with the expected distribution, and they were different on every call – both for individual calls and within a set-based query. I must admit that I still don’t really understand why this works – but it does, and that’s what counts! (Readers, please do feel free to use the comments section if you can explain to a C# noob like me how and why this works).

Order header columns
The AdventureWorksDW2012 database uses a typical data warehouse design – that is, the tables are heavily denormalized. For the FactResellerSales table, this means that, even though there are rows for every order line, most of the columns are actually order-header information, and should be the same for each order-line of the same order. That’s why I generate these values, or at least the base values from which they can be computed, at the order level.

Six of the order-related columns are date-related. We have order date, ship date, and due date; and then we have the same three columns again, now as integer instead of datetime, to implement the foreign key into the DimDate dimension table. Data warehouse designs usually suggest using meaningless integer numbers as surrogate keys for the dimension tables. The date dimension in the AdventureWorksDW2012 does indeed use integer numbers, but they are far from meaningless – they are the YYYYMMDD representation of the date, as an integer number. This can be quite confusing – when I see a column OrderDateKey and the contents look like 20130815 and 20091205, I tend to think of them as dates in the twenty-first century rather than integer values of a little over twenty million. This misunderstanding has at times resulted in painful errors in my demo code – making me glad I always test my code before presenting! Anyway, armed with this knowledge, it is easy to generate the correct “key” values from the actual dates. The order date is also already known, since I generate my orders by date. For the other dates, the original FactResellerSales table always has a ship date that is either 7 or 8 days after the order date, and a due date that is always 5 days after the ship date. I decided to increase the spread a little – I generate the ship date to be anywhere between 5 and 14 days from the order date, and I retained the five day period between ship date and due date.

For the sales territory, I decided to introduce some (admittedly very simple) change through time. All orders until 2010, are for one of the sales territories 1 – 5, which correspond to the five regions in the United States. In 2011, business expands outside the US, so all sales territories 1 – 10 can be selected by the randomizer for orders in 2011 and 2012; as of 2013 the office in the North-West of the United States closes, so now only sales territories 2 – 10 can be selected. It’s probably not totally realistic to spread all sales evenly across all territories, especially when the business has just expanded into new areas, but I had to draw the line between realism and readable code somewhere.

I did not use a randomizer for the currency. In the original FactResellerSales table, there is a logical relationship between sales territory – for instance, all orders with sales territory equal to 6 (Canada) have CurrencyKey 19 (CAD). The only exception is that in sales territory 7 (France), only 13 % of sales use Euros, the remainder uses U.S. Dollars. I have no idea if that was deliberate or a mistake when Microsoft created this database, but I decided that for my own data, all orders would use the “natural” currency for the sales territory they are in.

The rest of the columns are fairly simple. There are a total of 701 resellers, and I use a simple distribution where each of them has the same chance. Given the total number of orders, that will mean that in the end they will all have almost the same amount of orders. Again, a tradeoff between effort and realism. The same applies for the EmployeeKey column – the existing table uses numbers 272 and 281 through 296 – and if you inspect the DimEmployee table, you will see that these are exactly the employees with the SalesPersonFlag column equal to 1: So no coincidence. There are a total of 17 sales persons, and I simply generate a random number from 1 to 17 and use a CASE expression to translate that to the corresponding EmployeeKey number. If you need more realism for either of these columns, feel free to modify the script (using any of the techniques described in this article, or something you come up with yourself).

For the revision number, the original FactResellerSales table had a distribution where roughly 99.9% of all orders have revision number 1, and the remaining 0.1% have revision number 2. I decided that this is good enough for me.

The carrier tracking number in the original table looked like a ten-digit hexadecimal number with two dashes inserted. So I generate a random number in a range that includes all possible ten-digit hexadecimal numbers, convert that first to binary and then (using a little known feature of the CONVERT statement) to the string representation of the hexadecimal equivalent. I wrapped it up by using STUFF to insert the two dashes. Stuff is generally intended to replace a substring with another substring, but you can make it insert data by “replacing” a zero-length string.

Finally, the CustomerPONumber always starts with “PO”, followed by a ten-digit number in the range 1000000000 – 9999999999; this is very easy to generate. I did not attempt to enforce uniqueness for either this column or for the carrier tracking number, because I am not even planning to use any of these columns at all in my demos.

Order line columns
There are a lot of columns that correspond to the order line. But most of them are determined using formulas and the other columns. The only thing I had to randomly determine are the product, the quantity, and the promotion. With the product known, the unit price (dealer price) and standard cost can both be fetched from the DimProduct dimension table. The extended amount is the multiplication of the unit price and the quantity; the discount amount can be found by multiplying that by the discount percentage for the order (see previous paragraph), and tax and freight are 8% and 2.5% of the total amount minus discount; and so on.

I spend quite some time thinking about the selection of the product for each order line. This was an area where I really wanted to go for realism – I went through the effort to create a realistic population for the DimProduct table; I will not let that go to waste! So my first version would just at random pick one of the products that are valid on the order date. To do that, I created a temporary table of valid products, plus a second temporary holding only the dates of a change in the DimProduct table – the latter table ensures that I only have to rebuild the former after an actual change, instead of for every day in the main loop for order date. (In relation to the total running time of the script, this is probably a futile optimization, but I simply cannot not optimize when I see the chance).

This version turned out to make all products with the same period of validity to appear in approximately the same number of orders – totally unrealistic! My second version modified this by adding a bit of realism – I assigned weights to the articles that correspond to their price, such that cheaper products are included more other than expensive products. But now, the total amount (quantity * price) for each product was about the same. Again, not what I wanted, for this is what some of my demo queries report on, and it looks weird if all rows report approximately the same amount! So, for my third version, the square root of the standard cost is used as the modifier instead of just the standard cost for each product- and to ensure some variation among items of the same price (fourth version!), I added the absolute value of the cosine of the ProductKey (a more or less random value between 0 and 1, but always the same for each product) as an additional modifier.

I am aware that there will probably be some orders with the same item on different order lines. Normally, these would be combined on a single line. I could have added logic for that, or changed the logic to make sure no two order lines of the same order will ever be for the same item, but I decided that this would complicate the script and slow down the generation too much. If I ever need data where no order can have two order lines for the same amount, I will probably change the script to first run the generation as is, then repeat the same random data generation for only the unwanted duplications, in a loop that runs until there are no more duplicates. Obviously, this will normally go relatively fast if the number of available products is sufficiently higher than the number of order lines – but if you have 75 order lines and only 80 available products, this method spells disaster!

I mentioned using weights to make some products appear more often than others. For these “weighted random picks”, I used an interesting method that I first found in the C code of an open source game. The principle of these weighted random picks is that some items appear more often than others. If you have a bag with one red, one blue, and one green ball, each ball will be picked one third of the time. Add two reds and a blue, and now half the picks will be a red ball, blue will still be one third, and green is down to one in six. The red ball has weight three, the blue ball has weight two, and green has weight one. When all weights are integer numbers, this can be mimicked on a computer by adding multiple copies of the item to a table and then picking one random row. But an easier method is to add up all weights to create numerical ranges. One to three for red, four and five for blue, and six for green. Generate a random number between one and six, and pick the corresponding ball. The next step after this is to use a random number that is not an integer, but a floating point. Now, the ranges are 0-3 for red, 3-5 for blue, and 5-6 for green (all with lower bound inclusive and upper bound exclusive). The random number is a floating point number between 0 (inclusive) and 6 (exclusive), and again you get a distribution of 50% red, 33.3% blue, and 16.7% green. This algorithm has the advantage that it can also be used with weights that are not an integer – which is great, because the weights I use are absolutely not integers! The base value is 100 divided by the square root of the price, with an additional modifier ranging from 0 to 1 (the absolute value of the cosine of the ProductKey).

For the quantity of the item ordered. I have considered going fancy with a formula that would favor higher numbers for cheaper items, but I was afraid that this might undo the spread in total (price * quantity) over all the generated rows. So I simply used the same CLR function that I also used for the number of order lines per order, giving a fairly high number of low values and a lower number of high values. I did consider creating a second version of the CLR with the chance to stay in the loop increased from 80% to 85% or 90% to get overall higher numbers, or creating a version that would take the percentage as a parameter, but I decided that the version I already had was good enough.

The final choice was for the PromotionKey column. Looking at the DimPromotion table it references, I see that there are five rows for volume-based discount, and a bunch of rows for very specific discounts. I did not want to randomly set completely inapplicable discounts, so I decided to ignore those specific discounts and assign the PromotionKey for the volume-based discount that matches the quantity of the item ordered.
*/


USE tempdb;
SET NOCOUNT ON;
go

-- Remove old version of demo database. Use brute force if necessary.
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'AdventureWorksDW2012XL')
  BEGIN;
  ALTER DATABASE AdventureWorksDW2012XL SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE AdventureWorksDW2012XL;
  END;
go

-- Create database by restoring from AdventureWorks2012 backup.
-- WARNING - change path names for your computer before running!!!
RESTORE DATABASE AdventureWorksDW2012XL
FROM DISK = N'C:\SQL 2012\Backup\AdventureWorksDW2012.bak'
WITH MOVE N'AdventureWorksDW2012_Data' TO N'D:\SQL 2012\Data\AdventureWorksDW2012XL_Data.mdf',
     MOVE N'AdventureWorksDW2012_Log'  TO N'C:\SQL 2012\Log\AdventureWorksDW2012XL_log.ldf',
     REPLACE, STATS = 10;
go

-- Ensure simple recovery - no need to have log backup hassle for a demo database.
ALTER DATABASE AdventureWorksDW2012XL SET RECOVERY SIMPLE;
go

-- Change file sizes - we're going to need a huge amount of disk space!
-- (The size used here should be enough, but I'll specify autogrow just in case).
ALTER DATABASE AdventureWorksDW2012XL
MODIFY FILE (NAME = N'AdventureWorksDW2012_Data', SIZE =   22GB, MAXSIZE = UNLIMITED, FILEGROWTH =  1GB);

ALTER DATABASE AdventureWorksDW2012XL
MODIFY FILE (NAME = N'AdventureWorksDW2012_Log',  SIZE = 1024MB, MAXSIZE = UNLIMITED, FILEGROWTH = 64MB);
go

-- If AdventureWorksDW2012XL was not created, the USE statement fails,
-- but the next batch will still execute.
-- Switch to tempdb first, so that we don't get test tables in other databases.
-- This needs to be in a separate batch, so it will execute even if the parse of the next USE fails.
USE tempdb;
go
USE AdventureWorksDW2012XL;
go

-- We'll partition the table by date, using one-month partitions.
-- Test data runs from January 2009 until August 2013.
-- (The extra partition for September 2013 is because efficient partition
--  switching requires there always to be an empty "last" partition).
CREATE PARTITION FUNCTION pfOrderDateKey(int)
AS RANGE RIGHT
FOR VALUES (20090201, 20090301, 20090401, 20090501, 20090601,
  20090701, 20090801, 20090901, 20091001, 20091101, 20091201,
  20100101, 20100201, 20100301, 20100401, 20100501, 20100601,
  20100701, 20100801, 20100901, 20101001, 20101101, 20101201,
  20110101, 20110201, 20110301, 20110401, 20110501, 20110601,
  20110701, 20110801, 20110901, 20111001, 20111101, 20111201,
  20120101, 20120201, 20120301, 20120401, 20120501, 20120601,
  20120701, 20120801, 20120901, 20121001, 20121101, 20121201,
  20130101, 20130201, 20130301, 20130401, 20130501, 20130601,
  20130701, 20130801, 20130901);

CREATE PARTITION SCHEME psOrderDateKey
AS PARTITION pfOrderDateKey
ALL TO ([PRIMARY]);

-- The schema for the FactResellerSalesXL table is
-- identical to that of the FactResellerSales table.
CREATE TABLE dbo.FactResellerSalesXL
      (ProductKey            int          NOT NULL,
       OrderDateKey          int          NOT NULL,
       DueDateKey            int          NOT NULL,
       ShipDateKey           int          NOT NULL,
       ResellerKey           int          NOT NULL,
       EmployeeKey           int          NOT NULL,
       PromotionKey          int          NOT NULL,
       CurrencyKey           int          NOT NULL,
       SalesTerritoryKey     int          NOT NULL,
       SalesOrderNumber      nvarchar(20) NOT NULL,
       SalesOrderLineNumber  tinyint      NOT NULL,
       RevisionNumber        tinyint      NULL,
       OrderQuantity         smallint     NULL,
       UnitPrice             money        NULL,
       ExtendedAmount        money        NULL,
       UnitPriceDiscountPct  float        NULL,
       DiscountAmount        float        NULL,
       ProductStandardCost   money        NULL,
       TotalProductCost      money        NULL,
       SalesAmount           money        NULL,
       TaxAmt                money        NULL,
       Freight               money        NULL,
       CarrierTrackingNumber nvarchar(25) NULL,
       CustomerPONumber      nvarchar(25) NULL,
       OrderDate             datetime     NULL,
       DueDate               datetime     NULL,
       ShipDate              datetime     NULL
      )
ON psOrderDateKey(OrderDateKey);

-- Clustered index is different - OrderDateKey added (required for partitioning)
-- (This was originally a PRIMARY KEY on SalesOrderNumber, SalesOrderLineNumber;
--  that constraint can now unfortunately no longer be enforced).
CREATE UNIQUE CLUSTERED INDEX IX_FactResellerSalesXL_OrderDateKey_SalesOrderNumer_SalesOrderLineNumber
ON dbo.FactResellerSalesXL (OrderDateKey, SalesOrderNumber, SalesOrderLineNumber)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);


-- Nonclustered indexes are all the same as FactResellerSales
-- (except that they, too, will be partitioned).

/* Actual creation of these indexes AFTER populating the table
CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_CurrencyKey
ON dbo.FactResellerSalesXL (CurrencyKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_DueDateKey
ON dbo.FactResellerSalesXL (DueDateKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_EmployeeKey
ON dbo.FactResellerSalesXL (EmployeeKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_ProductKey
ON dbo.FactResellerSalesXL (ProductKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_PromotionKey
ON dbo.FactResellerSalesXL (PromotionKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_ResellerKey
ON dbo.FactResellerSalesXL (ResellerKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_ShipDateKey
ON dbo.FactResellerSalesXL (ShipDateKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);
*/

-- Constraints are also all identical.
ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimCurrency
FOREIGN KEY(CurrencyKey) REFERENCES dbo.DimCurrency (CurrencyKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimDate
FOREIGN KEY(OrderDateKey) REFERENCES dbo.DimDate (DateKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimDate1
FOREIGN KEY(DueDateKey) REFERENCES dbo.DimDate (DateKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimDate2
FOREIGN KEY(ShipDateKey) REFERENCES dbo.DimDate (DateKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimEmployee
FOREIGN KEY(EmployeeKey) REFERENCES dbo.DimEmployee (EmployeeKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimProduct
FOREIGN KEY(ProductKey) REFERENCES dbo.DimProduct (ProductKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimPromotion
FOREIGN KEY(PromotionKey) REFERENCES dbo.DimPromotion (PromotionKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimReseller
FOREIGN KEY(ResellerKey) REFERENCES dbo.DimReseller (ResellerKey);

ALTER TABLE dbo.FactResellerSalesXL
WITH CHECK ADD CONSTRAINT FK_FactResellerSalesXL_DimSalesTerritory
FOREIGN KEY(SalesTerritoryKey) REFERENCES dbo.DimSalesTerritory (SalesTerritoryKey);
go




-- CLR function to get random numbers with a suitable distribution for sample data
-- Source code:
/*
using System;
using System.Data.SqlTypes;

public partial class UserDefinedFunctions
{
    private static readonly Random rand = new Random();

    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlInt16 RandomOrderQuantity(int Dummy)
    {
        int Result = 1;

        while (Result < 200 && rand.NextDouble() < 0.8)
            Result++;

        return (SqlInt16)Result;
    }
};
*/

CREATE ASSEMBLY RandomOrderQuantity
    AUTHORIZATION dbo
    FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C01030042D110520000000000000000E00002210B0108000006000000060000000000007E250000002000000040000000004000002000000002000004000000000000000400000000000000008000000002000000000000030040850000100000100000000010000010000000000000100000000000000000000000302500004B00000000400000D002000000000000000000000000000000000000006000000C000000742400001C0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E7465787400000084050000002000000006000000020000000000000000000000000000200000602E72737263000000D0020000004000000004000000080000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000000C0000000000000000000000000000400000420000000000000000000000000000000060250000000000004800000002000500A0200000D40300000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000133002002D00000001000011170A2B040617580A0620C80000002F157E010000046F0500000A239A9999999999E93F32DF0668280600000A2A2E730700000A80010000042A1E02280800000A2A00000042534A4201000100000000000C00000076342E302E33303331390000000005006C0000005C010000237E0000C80100008801000023537472696E67730000000050030000080000002355530058030000100000002347554944000000680300006C00000023426C6F620000000000000002000001571502000900000000FA253300160000010000000800000002000000010000000300000001000000080000000400000001000000010000000200000000000A0001000000000006004700400006004E0040000A007B0066000600B700A4001300CB0000000600FA00DA0006001A01DA000A005301380100000000010000000000010001000100100022000000050001000100310055000A00502000000000960084000E000100952000000000861898001400020089200000000091187F0136000200000001009E00210098001800310098001E00390098001400410098001400110068012800190073012C001100980014000900980014002000230023002E000B003A002E00130043002E001B004C00320004800000000000000000000000000000000084000000040000000000000000000000010037000000000004000000000000000000000001005A000000000000000000003C4D6F64756C653E0052616E646F6D4F726465725175616E746974792E646C6C0055736572446566696E656446756E6374696F6E73006D73636F726C69620053797374656D004F626A6563740052616E646F6D0072616E640053797374656D2E446174610053797374656D2E446174612E53716C54797065730053716C496E7431360052616E646F6D4F726465725175616E74697479002E63746F720044756D6D790053797374656D2E446961676E6F73746963730044656275676761626C6541747472696275746500446562756767696E674D6F6465730053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C697479417474726962757465004D6963726F736F66742E53716C5365727665722E5365727665720053716C46756E6374696F6E417474726962757465004E657874446F75626C65006F705F496D706C69636974002E6363746F7200000000032000000000001EE9D1B1E0B13B41AE14D234452814920008B77A5C561934E08903061209050001110D0803200001052001011115042001010804010000000320000D050001110D0603070108030000010801000200000000000801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F777301000000000042D1105200000000020000009F000000902400009006000052534453BED72E0D4031C74DA9A004BAEEF68DCE0D000000643A5C4875676F5C446F63756D656E74656E5C5765726B5C53514C5C50726573656E7461746965735C436F6C756D6E73746F726520696E6465785C52616E646F6D4F726465725175616E746974795C52616E646F6D4F726465725175616E746974795C6F626A5C52656C656173655C52616E646F6D4F726465725175616E746974792E70646200005825000000000000000000006E250000002000000000000000000000000000000000000000000000602500000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF25002040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000001800008000000000000000000000000000000100010000003000008000000000000000000000000000000100000000004800000058400000740200000000000000000000740234000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000000000000000000000000000000003F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B004D4010000010053007400720069006E006700460069006C00650049006E0066006F000000B001000001003000300030003000300034006200300000002C0002000100460069006C0065004400650073006300720069007000740069006F006E000000000020000000300008000100460069006C006500560065007200730069006F006E000000000030002E0030002E0030002E003000000050001800010049006E007400650072006E0061006C004E0061006D0065000000520061006E0064006F006D004F0072006400650072005100750061006E0074006900740079002E0064006C006C0000002800020001004C006500670061006C0043006F0070007900720069006700680074000000200000005800180001004F0072006900670069006E0061006C00460069006C0065006E0061006D0065000000520061006E0064006F006D004F0072006400650072005100750061006E0074006900740079002E0064006C006C000000340008000100500072006F006400750063007400560065007200730069006F006E00000030002E0030002E0030002E003000000038000800010041007300730065006D0062006C0079002000560065007200730069006F006E00000030002E0030002E0030002E00300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000C000000803500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;


ALTER ASSEMBLY RandomOrderQuantity
    DROP FILE ALL
    ADD FILE FROM 0x4D6963726F736F667420432F432B2B204D534620372E30300D0A1A44530000000002000002000000170000009C0000000000000015000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000A0FCF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1801C6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0BCA3101380000000010000000100000000000000C00FFFF0400000003800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000F862513FC607D311905300C04FA302A1C4454B99E9E6D211903F00C04FA302A10B9D865A1166D311BD2A0000F80849BD60A66E40CF64824CB6F042D48172A799100000000000000051950C58B3E7E6DBE19E39702575728FFFFFFFFF2800000014000000030000000600000010000000090000000A000000050000000B0000000C0000000D0000000F0000000E0000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000F862513FC607D311905300C04FA302A1C4454B99E9E6D211903F00C04FA302A10B9D865A1166D311BD2A0000F80849BD60A66E40CF64824CB6F042D48172A7991000000000000000561FAB73B516165EE4C074632B1C7623FFFFFFFFFFFFFFFF28000000140000000300000006000000100000000900000008000000040000000B0000000C0000000D0000000F0000000E000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000BCA310138000000001000000010000000000000FFFFFFFF040000000380000000000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003800000000000000380000000000000000000000000000000000000000000000440200002C0000006C000000FFFFFFFF28000000140000000300000006000000100000000900000008000000040000000B0000000C0000000D0000000F0000000E00000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001BE2300180000000D7FC48279E97CE010C000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000020000000100000001000000000000007C000000280000001BE23001F3DC485058000000010000007B0000007C000000650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FEEFFEEF01000000F600000000643A5C4875676F5C446F63756D656E74656E5C5765726B5C53514C5C50726573656E7461746965735C436F6C756D6E73746F726520696E6465785C52616E646F6D4F726465725175616E746974795C52616E646F6D4F726465725175616E746974795C52616E646F6D4F726465725175616E746974792E63730000643A5C6875676F5C646F63756D656E74656E5C7765726B5C73716C5C70726573656E7461746965735C636F6C756D6E73746F726520696E6465785C72616E646F6D6F726465727175616E746974795C72616E646F6D6F726465727175616E746974795C72616E646F6D6F726465727175616E746974792E63730004000000010000007B0000007C000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001BE23001800000008E1CE0F7199CCE010D000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000020000000100000001000000000000007C000000280000001BE230016771F3D358000000010000007B0000007C000000650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000003E002A1100000000D4000000000000002D00000000000000000000000100000600000000010000000052616E646F6D4F726465725175616E74697479000000001600031104000000A00000002D00000000000000010000000A0024115553797374656D001A0024115553797374656D2E446174612E53716C54797065730000001A00201100000000010000110000000000000000526573756C740000020006002E000404C93FEAC6B359D649BC250902BBABB460000000004D0044003200000004010000040000000C00000001000200020006002E002A110000000038010000000000000B0000000000000000000000030000062D00000001000000002E6363746F72002E000404C93FEAC6B359D649BC250902BBABB460000000004D0044003200000004010000040157000C0000000100000602000600F20000005400000000000000010001002D000000000000000500000048000000000000000B00008002000000EEEFFE80040000000E000080080000000D000080250000001000008009001800000000000D0016000900380009002100F2000000300000002D000000010001000B00000000000000020000002400000000000000060000800A000000EEEFFE800500380000000000F40000000800000001000000000000001000000000000000240000003C00000054000000000000000000000000000000FFFFFFFF1A092FF120000000140200005500000001000000250000000100000001000000010000003D00000001000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000C0000001800000024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220025110000000004000000010052616E646F6D4F726465725175616E746974790000001600291100000000040000000100303630303030303100001600251100000000D800000001002E6363746F72000000001600291100000000D8000000010030363030303030330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000FFFFFFFF1A092FF10000000000000000040000000100303630303030303100001600251100000000D800000001002E6363746F72000000001600291100000000D80000000100303630303030303300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000FFFFFFFF770931010D0000000900008A0A006F760B000100600000003C0000002C00000088000000000000000000000016000000190000000000EEC00000000000000000FFFF000000000000FFFFFFFF00000000FFFF00000000000000000000000008003C01000000000000A400000001000000D88E2C00000000000000000055736572446566696E656446756E6374696F6E730037314141414545380000002DBA2EF101000000000000002D00000000000000000000000000000000000000010000002D0000000B00000000000000000000000000000000000000020002000D01000000000100FFFFFFFF00000000380000000802000000000000FFFFFFFF00000000FFFFFFFF010001000000010000000000643A5C4875676F5C446F63756D656E74656E5C5765726B5C53514C5C50726573656E7461746965735C436F6C756D6E73746F726520696E6465785C52616E646F6D4F726465725175616E746974795C52616E646F6D4F726465725175616E746974795C52616E646F6D4F726465725175616E746974792E6373000000FEEFFEEF010000000100000000010000000000000000000000FFFFFFFFFFFFFFFFFFFF1800FFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000098000000FF00000038000000FFFFFFFF000000001A0100008000000058000000050000000300000006000000090000000800000004000000626C6F636B002F7372632F66696C65732F643A5C6875676F5C646F63756D656E74656E5C7765726B5C73716C5C70726573656E7461746965735C636F6C756D6E73746F726520696E6465785C72616E646F6D6F726465727175616E746974795C72616E646F6D6F726465727175616E746974795C72616E646F6D6F726465727175616E746974792E6373000400000006000000010000003A0000000000000011000000060000000A00000005000000000000000400000022000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100000018000000FF00000038000000BF010000000000001A010000800000005800000028000000F4010000440200002C0000006C00000003000000110000000600000010000000090000000A00000007000000080000000B0000000C0000000D0000000F0000000E0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000942E31018ED2FE510D000000BED72E0D4031C74DA9A004BAEEF68DCEA70000002F4C696E6B496E666F002F6E616D6573002F7372632F686561646572626C6F636B002F7372632F66696C65732F643A5C6875676F5C646F63756D656E74656E5C7765726B5C73716C5C70726573656E7461746965735C636F6C756D6E73746F726520696E6465785C72616E646F6D6F726465727175616E746974795C72616E646F6D6F726465727175616E746974795C72616E646F6D6F726465727175616E746974792E6373000400000006000000010000003A0000000000000011000000060000000A0000000500000000000000040000002200000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000190000003C000000FF00000038000000BF010000000000001A0100008000000058000000F4010000440200002C0000006C000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2800000011000000130000000600000010000000090000000A000000050000000B0000000C0000000D0000000F0000000E00000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
             AS N'RandomOrderQuantity.pdb';
go

CREATE FUNCTION dbo.RandomOrderQuantity(@Dummy int)
RETURNS smallint
AS EXTERNAL NAME RandomOrderQuantity.UserDefinedFunctions.RandomOrderQuantity;
go

-- Generate a table of numbers for later use
CREATE TABLE dbo.Numbers
         (n int NOT NULL PRIMARY KEY);
-- Populate it with 100,000 numbers
INSERT INTO dbo.Numbers (n)
SELECT TOP(100000) ROW_NUMBER() OVER (ORDER BY ProductKey, DateKey)   -- Match smallest index in tablel
FROM   dbo.FactProductInventory;                                      -- Any table with >100,000 rows will do

-- We need to expand the DimDate table with 2011, 2012, and 2013.
WITH
Dates     AS (SELECT DATEADD(day, n, CAST('20101231' AS date)) AS NewDate
              FROM   dbo.Numbers),
DatesPlus AS (SELECT NewDate,
                     DATEPART(dd, NewDate) AS dd,
                     DATEPART(dy, NewDate) AS dy,
                     DATEPART(dw, NewDate) AS dw,
                     DATEPART(wk, NewDate) AS wk,
                     DATEPART(mm, NewDate) AS mm,
                     DATEPART(qq, NewDate) AS qq,
                     DATEPART(yy, NewDate) AS yy
              FROM   Dates
              WHERE  NewDate <= '20131231')
INSERT INTO dbo.DimDate
           (DateKey,
            FullDateAlternateKey,
            DayNumberOfWeek,
            EnglishDayNameOfWeek,
            SpanishDayNameOfWeek,
            FrenchDayNameOfWeek,
            DayNumberOfMonth,
            DayNumberOfYear,
            WeekNumberOfYear,
            EnglishMonthName,
            SpanishMonthName,
            FrenchMonthName,
            MonthNumberOfYear,
            CalendarQuarter,
            CalendarYear,
            CalendarSemester,
            FiscalQuarter,
            FiscalYear,
            FiscalSemester)
SELECT      10000 * yy + 100 * mm + dd,
            NewDate,
            dw,
            Weekdays.English,
            Weekdays.Spanish,
            Weekdays.French,
            dd,
            dy,
            wk,
            Months.English,
            Months.Spanish,
            Months.French,
            mm,
            qq,
            yy,
           (qq + 1) / 2,
            CASE WHEN qq <= 2 THEN qq + 2 ELSE qq - 2 END,
            CASE WHEN qq <= 2 THEN yy ELSE yy + 1 END,
           (6 - qq) / 2
FROM        DatesPlus
INNER JOIN (VALUES(1, 'Sunday', 'Domingo', 'Dimanche'),
                  (2, 'Monday', 'Lunes', 'Lundi'),
                  (3, 'Tuesday', 'Martes', 'Mardi'),
                  (4, 'Wednesday', 'Miércoles', 'Mercredi'),
                  (5, 'Thursday', 'Jueves', 'Jeudi'),
                  (6, 'Friday', 'Viernes', 'Vendredi'),
                  (7, 'Saturday', 'Sábado', 'Samedi')) AS Weekdays(DayNr, English, Spanish, French)
      ON    Weekdays.DayNr = DatesPlus.dw
INNER JOIN (VALUES(1 , 'January', 'Enero', 'Janvier'),
                  (2 , 'February', 'Febrero', 'Février'),
                  (3 , 'March', 'Marzo', 'Mars'),
                  (4 , 'April', 'Abril', 'Avril'),
                  (5 , 'May', 'Mayo', 'Mai'),
                  (6 , 'June', 'Junio', 'Juin'),
                  (7 , 'July', 'Julio', 'Juillet'),
                  (8 , 'August', 'Agosto', 'Août'),
                  (9 , 'September', 'Septiembre', 'Septembre'),
                  (10, 'October', 'Octubre', 'Octobre'),
                  (11, 'November', 'Noviembre', 'Novembre'),
                  (12, 'December', 'Diciembre', 'Décembre')) AS Months(MonthNr, English, Spanish, French)
      ON    Months.MonthNr = DatesPlus.mm;

-- The table DimProduct is set up as a type-2 slowly changing dimension,
-- but with errors in the dates - and they're all in the past.
-- Let's change this to something more current (and correct).
-- Luckily, Microsoft uses only four distinct valid date ranges:
-- June 1, 1998 - current       --> unchanged
-- July 1, 2005 - June 30, 2002 --> Jan 1, 2009 - Dec 31, 2010
-- July 1, 2006 - June 30, 2003 --> Jan 1, 2011 - Dec 31, 2012
-- July 1, 2007 - current       --> Jan 1, 2013 - current
UPDATE dbo.DimProduct
SET    StartDate = CASE WHEN StartDate = '20050701' THEN '20090101'
                        WHEN StartDate = '20060701' THEN '20110101'
                           ELSE '20130101' END,
       EndDate   = CASE WHEN StartDate = '20050701' THEN '20101231'
                        WHEN StartDate = '20060701' THEN '20121231'
                        ELSE NULL END
WHERE  StartDate <> '19980601';
go


-- Now it's time for the actual work - generate a huge amount of test data!

-- We generate data one OrderDate at a time, from Jan 1, 2009 until Aug 31, 2013.
-- Generating the data in order prevents page splits;
-- it also enables some extra realism in the test data.

-- "Average" number of orders per day starts at 5000,
-- and the trent is a growth of 0.1% per day in 2011-2012; 0.15% thereafter.
-- This grows to over 28,000 orders per day in 2013.
-- (I introduced a very sharp (95%) reduction on Sep 1st, 2013;
--  this is not very realistic, but it does save a lot of time on some demos!).

-- Actual orders is between 90%-110% of average.
-- Order numbers start at AA00000 and count up from there, until ZZ99999;
-- that gives me 67.6 million orders, with an average of 5 orderlines each,
-- so a maximum of 338 million order lines.
-- If you need more, you'll need to change the formula for the OrderNumber
DECLARE @CurrentOrderDate date = '20090101',
        @AvgOrdersPerDay int = 5000,
        @OrdersToGenerate int,
        @OrdersAlreadyGenerated int = 0;
--SET @AvgOrdersPerDay = 100;  -- For test, use smaller amount

-- I'll generate OrderLines only, but they're based on virtual orders.
CREATE TABLE #Orders
-- Base properties: order number (will be converted to other format and number of orderlines
     (OrderNumber           int          NOT NULL PRIMARY KEY,
      NumOrderLines         tinyint      NOT NULL,
-- Some base numbers for computing the Order specific columns
      OrderDate             datetime     NOT NULL,
      ShipDelay             tinyint      NOT NULL,
      ResellerKey           int          NOT NULL,
      SalesPersonNbr        tinyint      NOT NULL,
      SalesTerritoryKey     int          NOT NULL,
      RevisionNumber        tinyint      NOT NULL,
      CarrierTrackingNumber nvarchar(25) NOT NULL,
      CustomerPONumber      nvarchar(25) NOT NULL,
-- Some computed columns as a first step for computing final results
      ShipDate AS DATEADD(day, ShipDelay, OrderDate),
      DueDate  AS DATEADD(day, ShipDelay + 5, OrderDate)
     );

-- And here's a helper table for generating the actual OrderLines
CREATE TABLE #OrderLines
-- Base properties: order number + order line number = key
     (OrderNumber           int          NOT NULL,
      OrderLineNumber       tinyint      NOT NULL,
-- Some base numbers for computing the Order specific columns
      ProductSelection      float        NOT NULL,
      OrderQuantity         smallint     NOT NULL,
-- Some computed columns as a first step for computing final results
      PromotionKey AS CASE WHEN OrderQuantity > 60 THEN 6
                           WHEN OrderQuantity > 40 THEN 5
                           WHEN OrderQuantity > 24 THEN 4
                           WHEN OrderQuantity > 14 THEN 3
                           WHEN OrderQuantity > 10 THEN 2 ELSE 1 END,
      PRIMARY KEY (OrderNumber, OrderLineNumber)
     );

-- And some helper tables for products valid on a given order day
CREATE TABLE #ValidProducts
     (ProductKey            int          NOT NULL PRIMARY KEY,
      StandardCost          money        NOT NULL,
      DealerPrice           money        NOT NULL,
      EndDate               datetime     NULL,
	  StartSelRange         float        NOT NULL,
	  EndSelRange           float        NOT NULL
     );

CREATE TABLE #ProductRefreshDates
     (RefreshDate           datetime     NOT NULL PRIMARY KEY);
INSERT INTO #ProductRefreshDates
      (RefreshDate)
SELECT DISTINCT StartDate
FROM   dbo.DimProduct
UNION
SELECT DISTINCT DATEADD(day, 1, EndDate)
FROM   dbo.DimProduct
WHERE  EndDate IS NOT NULL;

DECLARE @HighestProductSelection float,
        @RefreshProductDate datetime = '19000101',
        @Progress varchar(80);



-- Main loop starts here - iterate once for each OrderDate
-- Note that data for days until August 31, 2013 goes into the main table,
-- data for September 2013 goes into the "staging" table (for partition switching demo),
-- and data for October 2013 goes into the "current" table (for simulated read-write demo).
WHILE @CurrentOrderDate <= '20130831'
BEGIN;
  -- Update valid products table when needed
  -- The "weight" calculation looks complex,
  -- but is used to prevent queries from returning the same totals for each product.
  IF @CurrentOrderDate > @RefreshProductDate
  BEGIN;
    TRUNCATE TABLE #ValidProducts;

    INSERT INTO #ValidProducts
              (ProductKey,
               StandardCost,
               DealerPrice,
               EndDate,
			   StartSelRange,
			   EndSelRange)
    SELECT     ProductKey,
               StandardCost,
               DealerPrice,
               EndDate,
			   0,                           -- Will be determined next
			   SUM(100.0 / SQRT(StandardCost) + ABS(COS(ProductKey))) OVER (ORDER BY ProductKey)
    FROM       dbo.DimProduct
    WHERE      StandardCost IS NOT NULL     -- No price = internal use only, not for sale
    AND        StartDate <= @CurrentOrderDate
    AND        COALESCE(EndDate, @CurrentOrderDate) >= @CurrentOrderDate;

	UPDATE #ValidProducts
	SET    StartSelRange = COALESCE((SELECT MAX(v1.EndSelRange)
	                                 FROM   #ValidProducts AS v1
							         WHERE  v1.ProductKey < #ValidProducts.ProductKey), 0);

    SET @HighestProductSelection = (SELECT MAX(EndSelRange) FROM #ValidProducts);
    SET @RefreshProductDate = COALESCE((SELECT MIN(RefreshDate)
                                        FROM   #ProductRefreshDates
                                        WHERE  RefreshDate > @CurrentOrderDate), '29991231');
  END;

  -- Apply variation (90-110% of average) to #orders per day
  SET @OrdersToGenerate = @AvgOrdersPerDay * (0.9 + RAND(CHECKSUM(NEWID())) * 0.2);

  -- Generate them
  INSERT INTO #Orders
              (OrderNumber,
               NumOrderLines,
               OrderDate,
               ShipDelay,
               ResellerKey,
               SalesPersonNbr,
               SalesTerritoryKey,
               RevisionNumber,
               CarrierTrackingNumber,
               CustomerPONumber)
  SELECT       @OrdersAlreadyGenerated + n,
               dbo.RandomOrderQuantity(n),
               @CurrentOrderDate,
               CEILING(RAND(CHECKSUM(NEWID())) * 10) + 4,
               CEILING(RAND(CHECKSUM(NEWID())) * 701),
               CEILING(RAND(CHECKSUM(NEWID())) * 17),
               CASE WHEN YEAR(@CurrentOrderDate) <= 2010 THEN CEILING(RAND(CHECKSUM(NEWID())) * 5)
                    WHEN YEAR(@CurrentOrderDate) <= 2012 THEN CEILING(RAND(CHECKSUM(NEWID())) * 10)
                    ELSE CEILING(RAND(CHECKSUM(NEWID())) * 9) + 1 END,
               CASE WHEN CEILING(RAND(CHECKSUM(NEWID())) * 1000) = 1
                    THEN 2 ELSE 1 END,
               STUFF(STUFF(RIGHT(CONVERT(char(12), CAST(CAST(FLOOR(RAND(CHECKSUM(NEWID())) * 1099511627776) AS bigint) AS binary(5)), 1), 10), 9, 0, '-'), 5, 0, '-'),
              'PO' + CAST(1000000000 + CAST(FLOOR(RAND(CHECKSUM(NEWID())) * 9000000000) AS bigint) AS char(10))
  FROM         dbo.Numbers
  WHERE        n <= @OrdersToGenerate;

  -- Generate the base info for the OrderLines
  INSERT INTO #OrderLines
              (OrderNumber,
               OrderLineNumber,
               ProductSelection,
               OrderQuantity)
  SELECT       o.OrderNumber,
               n.n,
               RAND(CHECKSUM(NEWID())) * @HighestProductSelection,
               dbo.RandomOrderQuantity(n)
  FROM         #Orders AS o
  INNER JOIN   dbo.Numbers AS n
        ON     n.n <= o.NumOrderLines;

  -- Now generate the OrderLines
  INSERT INTO dbo.FactResellerSalesXL
              (ProductKey,
               OrderDateKey,
               DueDateKey,
               ShipDateKey,
               ResellerKey,
               EmployeeKey,
               PromotionKey,
               CurrencyKey,
               SalesTerritoryKey,
               SalesOrderNumber,
               SalesOrderLineNumber,
               RevisionNumber,
               OrderQuantity,
               UnitPrice,
               ExtendedAmount,
               UnitPriceDiscountPct,
               DiscountAmount,
               ProductStandardCost,
               TotalProductCost,
               SalesAmount,
               TaxAmt,
               Freight,
               CarrierTrackingNumber,
               CustomerPONumber,
               OrderDate,
               DueDate,
               ShipDate)
  SELECT       p.ProductKey,
               YEAR(o.OrderDate) * 10000 + MONTH(o.OrderDate) * 100 + DAY(o.OrderDate),
               YEAR(o.DueDate)   * 10000 + MONTH(o.DueDate)   * 100 + DAY(o.DueDate),
               YEAR(o.ShipDate)  * 10000 + MONTH(o.ShipDate)  * 100 + DAY(o.ShipDate),
               o.ResellerKey,
               CASE WHEN o.SalesPersonNbr = 1 THEN 272 ELSE 279 + o.SalesPersonNbr END,
               l.PromotionKey,
               CASE WHEN o.SalesTerritoryKey <=  5 THEN 100            -- United States     --> USD
                    WHEN o.SalesTerritoryKey  =  6 THEN  19            -- Canada            --> CAD
                    WHEN o.SalesTerritoryKey <=  8 THEN  36            -- France & Germany  --> EUR
                    WHEN o.SalesTerritoryKey  =  9 THEN   6            -- Australia         --> AUD  
                    WHEN o.SalesTerritoryKey  = 10 THEN  98            -- Great Brittain    --> GBP  
                    ELSE CEILING(RAND(CHECKSUM(NEWID())) * 105) END,   -- Should not happen --> Random currency
               SalesTerritoryKey,
               CHAR(65 + (o.OrderNumber / 100000) / 26) + CHAR(65 + (o.OrderNumber / 100000) % 26) + RIGHT('0000' + CAST(o.OrderNumber % 100000 AS varchar(5)), 5),                                                            -- Two letters, five digits
--             CHAR(65 + ((o.OrderNumber / 100000) / 26) / 26) + CHAR(65 + ((o.OrderNumber / 100000) / 26) % 26) + CHAR(65 + (o.OrderNumber / 100000) % 26) + RIGHT('0000' + CAST(o.OrderNumber % 100000 AS varchar(5)), 5),   -- Alternative version: three letters, five digits
               l.OrderLineNumber,
               o.RevisionNumber,
               l.OrderQuantity,
               p.DealerPrice,
               p.DealerPrice * l.OrderQuantity,
               pr.DiscountPct,
               p.DealerPrice * l.OrderQuantity * pr.DiscountPct,
               p.StandardCost,
               p.StandardCost * l.OrderQuantity,
               p.DealerPrice * l.OrderQuantity * (1 - pr.DiscountPct),
               p.DealerPrice * l.OrderQuantity * (1 - pr.DiscountPct) * 0.08,
               p.DealerPrice * l.OrderQuantity * (1 - pr.DiscountPct) * 0.025,
               o.CarrierTrackingNumber,
               o.CustomerPONumber,
               o.OrderDate,
               o.DueDate,
               o.ShipDate
  FROM         #Orders          AS o
  INNER JOIN   #OrderLines      AS l
        ON     l.OrderNumber     = o.OrderNumber
  INNER JOIN   #ValidProducts   AS p
        ON     p.StartSelRange   < l.ProductSelection
        AND    p.EndSelRange    >= l.ProductSelection
  INNER JOIN   dbo.DimPromotion AS pr
        ON     pr.PromotionKey   = l.PromotionKey;

  SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ':' + STR(@OrdersToGenerate) + ' orders generated for ' + CONVERT(char(10), @CurrentOrderDate, 120);
  RAISERROR (@Progress, 0, 0) WITH NOWAIT;

  -- Move to next day
  SET @OrdersAlreadyGenerated += @OrdersToGenerate;
  TRUNCATE TABLE #OrderLines;
  TRUNCATE TABLE #Orders;
  SET @CurrentOrderDate = DATEADD(day, 1, @CurrentOrderDate);

  -- Apply trend growth of average orders per day
  SET @AvgOrdersPerDay *= CASE WHEN YEAR(@CurrentOrderDate) <= 2012 THEN 1.001 ELSE 1.0015 END;
END;

DROP TABLE #OrderLines;
DROP TABLE #Orders;
DROP TABLE #ValidProducts;
DROP TABLE #ProductRefreshDates;
go

-- Nonclustered indexes are all the same as FactResellerSales
-- (except that they, too, will be partitioned).

DECLARE @Progress varchar(80);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': Started index creation.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_CurrencyKey
ON dbo.FactResellerSalesXL (CurrencyKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': NC index 1 created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;
  
CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_DueDateKey
ON dbo.FactResellerSalesXL (DueDateKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': NC index 2 created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_EmployeeKey
ON dbo.FactResellerSalesXL (EmployeeKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': NC index 3 created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_ProductKey
ON dbo.FactResellerSalesXL (ProductKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': NC index 4 created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_PromotionKey
ON dbo.FactResellerSalesXL (PromotionKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': NC index 5 created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_ResellerKey
ON dbo.FactResellerSalesXL (ResellerKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': NC index 6 created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

CREATE NONCLUSTERED INDEX IX_FactResellerSalesXL_ShipDateKey
ON dbo.FactResellerSalesXL (ShipDateKey)
WITH (DATA_COMPRESSION = PAGE)
ON psOrderDateKey(OrderDateKey);

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': NC index 7 created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

-- Now create the columnstore index
CREATE NONCLUSTERED COLUMNSTORE INDEX CSI_FactResellerSalesXL
ON dbo.FactResellerSalesXL
   (ProductKey,
    OrderDateKey,
    DueDateKey,
    ShipDateKey,
    ResellerKey,
    EmployeeKey,
    PromotionKey,
    CurrencyKey,
    SalesTerritoryKey,
    SalesOrderNumber,
    SalesOrderLineNumber,
    RevisionNumber,
    OrderQuantity,
    UnitPrice,
    ExtendedAmount,
    UnitPriceDiscountPct,
    DiscountAmount,
    ProductStandardCost,
    TotalProductCost,
    SalesAmount,
    TaxAmt,
    Freight,
    CarrierTrackingNumber,
    CustomerPONumber,
    OrderDate,
    DueDate,
    ShipDate
   );

SET @Progress = CONVERT(char(8), CURRENT_TIMESTAMP, 108) + ': CS index created.';
RAISERROR (@Progress, 0, 0) WITH NOWAIT;

SELECT COUNT(*) FROM dbo.FactResellerSalesXL;
go
