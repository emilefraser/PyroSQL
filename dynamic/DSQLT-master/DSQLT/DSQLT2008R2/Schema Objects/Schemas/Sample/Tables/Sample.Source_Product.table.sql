CREATE TABLE [Sample].[Source_Product] (
    [ProductID]      INT             NOT NULL,
    [ProductModelID] INT             NULL,
    [Name]           NVARCHAR (1000) NOT NULL,
    [Color]          NVARCHAR (15)   NULL,
    [ListPrice]      MONEY           NULL,
    [Created]        DATETIME        NULL
);

