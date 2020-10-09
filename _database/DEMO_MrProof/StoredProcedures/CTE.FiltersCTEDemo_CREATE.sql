SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE CTE.FiltersCTEDemo_CREATE
AS

DROP TABLE IF EXISTS CONECPTS.CTE.FiltersCTE_Demo

CREATE TABLE CONECPTS.CTE.FiltersCTE_Demo(
   [ICFilterID] [int] IDENTITY(1,1) NOT NULL,
   [ParentID] [int] NOT NULL DEFAULT 0,
   [FilterDesc] [varchar](50) NOT NULL,
   [Active] [tinyint] NOT NULL DEFAULT 1,
 CONSTRAINT [PK_ICFilters] PRIMARY KEY CLUSTERED 
 ( [ICFilterID] ASC ) 
) ON [PRIMARY]

INSERT INTO CONECPTS.CTE.FiltersCTE_Demo (ParentID,FilterDesc,Active)
Values 
(0,'Product Type',1),
(1,'ProdSubType_1',1),
(1,'ProdSubType_2',1),
(1,'ProdSubType_3',1),
(1,'ProdSubType_4',1),
(2,'PST_1.1',1),
(2,'PST_1.2',1),
(2,'PST_1.3',1),
(2,'PST_1.4',1),
(2,'PST_1.5',1),
(2,'PST_1.6',1),
(2,'PST_1.7',0),
(3,'PST_2.1',1),
(3,'PST_2.2',0),
(3,'PST_2.3',1),
(3,'PST_2.4',1),
(14,'PST_2.2.1',1),
(14,'PST_2.2.2',1),
(14,'PST_2.2.3',1),
(3,'PST_2.8',1)
GO
