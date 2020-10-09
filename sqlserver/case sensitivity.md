If Column1 of Table1 has following values ‘CaseSearch, casesearch, CASESEARCH, CaSeSeArCh’, following statement will return you all the four records.

<table><tbody><tr><td><div>1</div><div>2</div><div>3</div></td><td><div><div><code>SELECT</code> <code>Column1</code></div><div><code>FROM</code> <code>Table1</code></div><div><code>WHERE</code> <code>Column1 = </code><code>'casesearch'</code></div></div></td></tr></tbody></table>

To make the query case sensitive and retrieve only one record (“casesearch”) from the above query, the collation of the query needs to be changed as follows.

<table><tbody><tr><td><div>1</div><div>2</div><div>3</div></td><td><div><div><code>SELECT</code> <code>Column1</code></div><div><code>FROM</code> <code>Table1</code></div><div><code>WHERE</code> <code>Column1 </code><code>COLLATE</code> <code>Latin1_General_CS_AS = </code><code>'casesearch'</code></div></div></td></tr></tbody></table>

Adding COLLATE Latin1\_General\_CS\_AS makes the search case sensitive.

Default Collation of the SQL Server installation SQL\_Latin1\_General\_CP1\_CI\_AS is not case sensitive.

To change the collation of the any column for any table permanently run following query.

<table><tbody><tr><td><div>1</div><div>2</div><div>3</div></td><td><div><div><code>ALTER</code> <code>TABLE</code> <code>Table1</code></div><div><code>ALTER</code> <code>COLUMN</code> <code>Column1 </code><code>VARCHAR</code><code>(20)</code></div><div><code>COLLATE</code> <code>Latin1_General_CS_AS</code></div></div></td></tr></tbody></table>

To know the collation of the column for any table run following Stored Procedure.

<table><tbody><tr><td><div>1</div></td><td><div><div><code>EXEC</code> <code>sp_help DatabaseName</code></div></div></td></tr></tbody></table>