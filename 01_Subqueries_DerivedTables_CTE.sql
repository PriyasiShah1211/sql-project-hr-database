-- Advanced SQL script to work with Subqueries , Derived Tables and Common Table Expressions (CTEs)


-- Put relevant database to use
use HR_2

-- Subqueries

/*
A subquery is a query within another query. The outer query is called as main query and inner query is called as subquery. 
1. The subquery gets executed first. 
2. Subquery must be enclosed in parentheses.
3. A subquery can be placed in a number of SQL clauses like WHERE clause, FROM clause, HAVING clause.
In the Subquery, ORDER BY command cannot be used.
*/


-- Example 1 - Show the details of employees with a dependent

-- Step 1: Investigate tables
select * from dependents

select * from employees

-- Step 2: Write a Subquery
select * from employees
where employee_id in (select employee_id from dependents);


-----------------------------------------------------------------
-- Table Expressions
-----------------------------------------------------------------
/*
A table expression is a query that represents a valid relational table. 

T-SQL supports 4 types of table expressions: 
	Derived tables
	Common table expressions (CTEs)
	Views
	Table-valued functions (TVFs)

These kind of queries must meet three requirements:
	1) Order is not guaranteed (No Order By)
	2) All columns must have names
	3) All column names must be unique

One of the benefits of using table expressions is that, you can refer to column aliases that were assigned 
in the SELECT clause of the inner query. This behaviour helps you get around the fact that you can’t refer to 
column aliases assigned in the SELECT clause in query clauses that are logically processed prior to the SELECT clause 
(for example, WHERE or GROUP BY).
*/


/* Derived Tables
Derived tables (also known as Table Subqueries) are defined in the FROM clause of an outer query.
Inner query defines the derived table within parentheses, followed by the AS clause and the derived table name.
*/

-- Example 1 - Count how many employees are in High and Low SalCategory
select 
SalCategory, 
count(*) as 'Count of Employees'
from 
(select 
	employee_id,
	email,
	salary,
	IIF(salary > 8000, 'High', 'Low') as SalCategory
from employees) as x
group by SalCategory;

-- Example 2 - Count how many employees are in High, Mid and Low SalCategory
select [Salary Category],
count (*) as 'Count of Employees'
from
(select 
	employee_id, 
	email, 
	salary,
	iif(salary > 15000, 'High', iif(salary > 8000, 'Mid', 'Low')) as [Salary Category]
from employees) as y
Group by [Salary Category];


/*
Common table expressions (CTEs) are another standard form of table expression similar to derived tables.
CTEs are defined by using a WITH statement.
*/

-- Example 1 - Count how many employees are in High and Low SalCategory
with x as
(
	select 
		employee_id,
		email,
		salary,
		IIF(salary > 8000, 'High', 'Low') as SalCategory
	from employees
)
		
select SalCategory, count(*) as 'Count of Employees'
from x
group by SalCategory;

-- Example 2 - Count how many employees are in High, Mid and Low SalCategory
with y as
(select employee_id, email, salary,
iif(salary > 15000, 'High', iif(salary > 8000, 'Mid', 'Low')) as [Salary Category]
from employees)

select [Salary Category], COUNT(*) as 'Count of Employees'
from y
group by [Salary Category];



/*
On the surface, the difference between derived tables and CTEs might seem to be merely semantic. 
However, the fact that you first name and define a CTE and then use it gives it several important advantages over
derived tables. One advantage is that if you need to refer to one CTE from another, you don’t nest them; 
rather, you separate them by commas. Each CTE can refer to all previously defined CTEs, and the outer query 
can refer to all CTEs.

The fact that a CTE is named and defined first and then queried has another advantage: 
as far as the FROM clause of the outer query is concerned, the CTE already exists; therefore, 
you can refer to multiple instances of the same CTE in table operators like joins.

CTEs are unique among table expressions in the sense that they support recursion.
*/



/*
Derived tables and CTEs have a single-statement scope, which means they are not reusable. 
Views and table-valued functions (TVFs) are two types of table expressions whose definitions are stored as
permanent objects in the database, making them reusable.
*/