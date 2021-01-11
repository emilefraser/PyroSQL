DECLARE @JsonData NVARCHAR(MAX) = '[
  {
    "ContactTypeID": 1,
    "Name": "Accounting Manager",
    "ModifiedDate": "2002-06-01T00:00:00"
  },
  {
    "ContactTypeID": 2,
    "Name": "Assistant Sales Agent",
    "ModifiedDate": "2002-06-01T00:00:00"
  },
  {
    "ContactTypeID": 3,
    "Name": "Assistant Sales Representative",
    "ModifiedDate": "2002-13-01T00:00:00"
  }
]'

--Option 1
SELECT *
FROM OPENJSON(@JsonData) 
WITH (
 ContactTypeID INT,
 Name NVARCHAR(50),
 ModifiedDate DATETIME
)

--Option 2
SELECT 
 TRY_CAST(JSON_VALUE(j.value, '$.ContactTypeID') AS INT) AS ContactTypeID,
 TRY_CAST(JSON_VALUE(j.value, '$.Name') AS NVARCHAR(50)) AS Name,
 TRY_CAST(JSON_VALUE(j.value, '$.ModifiedDate') AS DATETIME) AS ModifiedDate
FROM OPENJSON(@JsonData) j