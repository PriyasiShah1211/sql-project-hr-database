-- Advanced SQL script to work with Views , Windows Function and Stored Procedures

-- Put relevant database to use
use HR_2

--------------------------------------------------------------
---- Views:
--------------------------------------------------------------

/* 
In SQL, a view is a virtual table based on the result-set of an SQL statement.

A view contains rows and columns, just like a real table. The fields in a view are fields from one or more real tables in the database.

You can add SQL statements and functions to a view and present the data as if the data were coming from one single table.

Views have the following benefits:
	> Security - Views can be made accessible to users while the underlying tables are not directly accessible. This allows the DBA to give users only the data they need, while protecting other data in the same table.
	> Simplicity - Views can be used to hide and reuse complex queries.
	> Column Name Simplification or Clarification - Views can be used to provide aliases on column names to make them more memorable and/or meaningful.
	> Stepping Stone - Views can provide a stepping stone in a "multi-level" query. 
*/

-- Example 1 - Create a view which combines employee data from all the tables (except dependents)

create view v_FullEmpData as
(
	select 
		employees.*, job_title, min_salary, max_salary, department_name, street_address, postal_code,
		city, state_province, country_name, region_name
	from employees
	inner join jobs on employees.job_id = jobs.job_id
	inner join departments on employees.department_id = departments.department_id
	inner join locations on departments.location_id = locations.location_id
	inner join countries on locations.country_id = countries.country_id
	inner join regions on countries.region_id = regions.region_id
)

-- check
select * from v_FullEmpData


-- To delete a view
-- drop view if exists v_FullEmpData


----------------------------------------------------
----Windows Function:
----------------------------------------------------

/*
A window function performs a calculation across a set of table rows that are somehow related to the current row. 
This is comparable to the type of calculation that can be done with an aggregate function. 
But unlike regular aggregate functions, use of a window function does not cause rows to become 
grouped into a single output row — the rows retain their separate identities.

The key to windowing functions is in controlling the order in which the rows are evaluated

Windows functions are performed using the OVER clause.

There are three groups of functions that the OVER clause can be applied to:
	1) aggregate functions (sum, avg, max, min, etc.)
	2) ranking functions (row_number, rank, dense_rank, etc.)
	3) analytic functions (first_value, last_value, lag, lead, etc.)
*/

-- lets look at employee id, email, salary and dept name

select employee_id, email, department_name, salary
from v_FullEmpData

-- Aggregation query

select max(salary) from v_FullEmpData


select department_name, max(Salary)
from v_FullEmpData
group by department_name

-- Please note that in above queries we are losing row level details

-- If we use windows functions then we will be able to see both row level and aggregate level data together

-- Example 1 - Compare the salary of each employee against the salary of the highest paid person in the company

select	
	employee_id, 
	email, 
	department_name, 
	salary,
	max(salary) over() as 'Highest_Company_Sal'
from v_FullEmpData


-- Example 2 - Compare the salary of each employee against the salary of the highest paid person in their respective department

select	
	employee_id, 
	email, 
	department_name, 
	salary,
	max(salary) over(partition by department_name) as 'Highest_Dept_Sal'
from v_FullEmpData


-- Example 3 - Show top paid employee of each department
select * from
(
	select	employee_id, email, department_name, salary,
			ROW_NUMBER() over(partition by department_name order by salary desc) as 'rn' 
	from v_FullEmpData) as x
where rn = 1


-- Example 4 - Compare row_number, rank and dense_rank

select	employee_id, email, department_name, salary,
		ROW_NUMBER() over(order by salary desc) as 'rn',
		rank() over(order by salary desc) as 'rnk',
		dense_rank() over(order by salary desc) as 'drnk'
from v_FullEmpData


-- Example 5 - Increase in Salary budget over time
select	employee_id, email, hire_date, salary,
		sum(salary) over(order by hire_date) as 'Cumulative_SalExpense'
from v_FullEmpData


-- Example 6 - Increase in Salary Expense over time for each department
select	employee_id, email, hire_date, department_name, salary,
		sum(salary) over(partition by department_name order by hire_date) as 'Cumulative_SalExpense'
from v_FullEmpData


------------------------------------------------------------------
-- Stored Procedures
------------------------------------------------------------------

/* A stored procedure is a group of SQL statements that are created and stored in a database management system, 
allowing multiple users and programs to share and reuse the procedure. A stored procedure can accept 
input parameters, perform the defined operations, and return multiple output values. */

/* Syntax:
CREATE PROCEDURE procedure_name     (we can also use PROC)
AS 
BEGIN 
sql_statement 
END 
*/

/* Best Practices:
> Use SET NOCOUNT ON
> Use a consistent nomenclature like spABC (but not sp_ABC)
*/


-- Create a simple stored procedure
create procedure spDemo1
as
begin
	select * from v_FullEmpData where department_name = 'Sales'
end


-- Execute the stored procedure
spDemo1

-- or
exec spDemo1

-- or
execute spDemo1


/* When each statement is executed in a stored procedure, the SQL Server returns the number of rows 
that are affected as part of the results. To reduce network traffic and improve performance, 
use SET NOCOUNT ON at the beginning of the stored procedure.*/
create proc spDemo2
as
begin
	set nocount on
	select * from v_FullEmpData where department_name = 'Sales'
end


-- Execute and look at the message window
exec spDemo2


-- There are some system stored procedures as well. We use sp_helptext to view our code
sp_helptext spDemo1

sp_helptext spDemo2


-- To modify a stored procedure use the alter command
alter proc spDemo2
as
begin
	set nocount on
	select * from v_FullEmpData where department_name = 'IT'
end


-- To delete a stored procedure use the DROP command
drop proc spDemo2

-- or, just to play it safe
drop proc if exists spDemo2


-- we can encrypt a stored procedure
alter procedure spDemo1
with encryption    -- check out this new line
as
begin
	select * from v_FullEmpData where department_name = 'Sales'
end

-- we can not see the logic inside the procedure now
sp_helptext spDemo1


-- Stored Procedures can accept input parameters
create proc spDemo3
	@DepName as varchar(50)
as
begin
	select * from v_FullEmpData where department_name = @DepName
end


-- Execute the proc to get data for IT department
exec spDemo3 @DepName = 'IT'


-- Execute the proc to get data for Sales department
exec spDemo3 'Sales'


-- Stored Procedures can accept multiple input parameters
create proc spDemo4 
	@DepName as varchar(50), 
	@SalCutOff as int
as
begin
	select * from v_FullEmpData where department_name = @DepName and salary > @SalCutOff
end

-- Implicit passing of parameter values. Order is important
exec spDemo4 'Sales', 7500

-- Explicit passing of parameter values
exec spDemo4 @SalCutOff = 5000, @DepName = 'IT'