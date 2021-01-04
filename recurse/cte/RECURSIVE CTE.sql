The following shows the syntax of a recursive CTE:


WITH expression_name (column_list)
AS
(
    -- Anchor member
    initial_query  
    UNION ALL
    -- Recursive member that references expression_name.
    recursive_query  
)
-- references expression name
SELECT *
FROM   expression_name


/*
In general, a recursive CTE has three parts:

An initial query that returns the base result set of the CTE. The initial query is called an anchor member.
A recursive query that references the common table expression, therefore, it is called the recursive member. The recursive member is union-ed with the anchor member using the UNION ALL operator.
A termination condition specified in the recursive member that terminates the execution of the recursive member.
The execution order of a recursive CTE is as follows:

First, execute the anchor member to form the base result set (R0), use this result for the next iteration.
Second, execute the recursive member with the input result set from the previous iteration (Ri-1) and return a sub-result set (Ri) until the termination condition is met.
Third, combine all result sets R0, R1, … Rn using UNION ALL operator to produce the final result set.
*/