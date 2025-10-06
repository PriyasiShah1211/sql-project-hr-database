-- Advanced SQL script to work with UDFs , Triggers , Indexes

-- Put relevant database to use
use HR_2

--------------------------------------
-- User Defined Function
--------------------------------------

/*
Like functions in programming languages, SQL Server user-defined functions are routines that accept parameters, perform an action, such as a 
complex calculation, and return the result of that action as a value. The return value can either be a single scalar value or a result set.

UDF are of two types:
1) Scalar functions - return a single data value
2) Table-valued functions - return a table


Scalar UDF syntax:

CREATE FUNCTION [database_name.]function_name (parameters)
RETURNS data_type AS
BEGIN
    SQL statements
    RETURN value
END;
    
ALTER FUNCTION [database_name.]function_name (parameters)
RETURNS data_type AS
BEGIN
    SQL statements
    RETURN value
END;
    
DROP FUNCTION [database_name.]function_name;

For Table-valued functions the BEGIN - END statements are not needed
*/

-- Scalar functions will always return a single (scalar) value
-- Example 1 - 
create function f_bonus(@Sal as float)
returns float
as
begin
	declare @bns float
	set @bns = @Sal * 0.1
	return @bns
end

-- Check
select employee_id, salary, dbo.f_bonus(salary) as BonusAmount
from v_FullEmpData


-- We cannot use a stored procedure in a select or where clause. But we can use functions
select employee_id, salary, dbo.f_bonus(salary) as BonusAmount
from v_FullEmpData
where dbo.f_bonus(salary) > 1000

-- Like stored procedures, we can encrypt the function as well
alter function f_bonus (@Sal as float)
returns float
with encryption
as
begin
	declare @bns float
	set @bns = @Sal * 0.1
	return @bns
end


-- after encryption try the sp_helptext again
sp_helptext f_bonus


-- Example 2 - 
create function f_Compa(@Sal as float, @MinSal as float, @MaxSal as float)
returns float
as
begin
	declare @MedianSal float
	set @MedianSal = (@MinSal + @MaxSal)/2
	declare @CompaRatio float
	set @CompaRatio = @Sal / @MedianSal
	return @CompaRatio
end

-- Check
select 
	employee_id, 
	email, 
	salary, 
	min_salary, 
	max_salary, 
	dbo.f_compa(salary, min_salary, max_salary) as 'Compa Ratio'
from v_FullEmpData


-- Example 3 - 
create function f_BonusDate (@hire_dt as date)
returns date
as
begin
	declare @bonus_dt as date
	declare @year as int
	set @year = year(getdate())
	set @bonus_dt = DATEFROMPARTS(@year, month(@hire_dt),day(@hire_dt))
	return @bonus_dt
end


-- use the function
select employee_id, hire_date, dbo.f_BonusDate(hire_date) as DateOfBonusPay
from v_FullEmpData


---------------------------------------
/*
Simple definition of the table-valued function (TVF) - Its a user-defined function that returns a table data type and also it can accept parameters. 
TVFs can be used after the FROM clause in the SELECT statements so that we can use them just like a table in the queries.
*/
-------------------------------------

-- Example 1 -
Create function f_t_getEmpDetails(@empid as int)
returns table
as
return 
(
	select email, phone_number, salary from employees 
	where employee_id = @empid
)

-- use the function to fetch the records for employee number 101
select * from f_t_getEmpDetails(100)


-- Alter the function. We already restricted columns, now lets restrict rows as well
alter function f_t_getEmpDetails(@empid as int)
returns table
as
return 
(
	select email, phone_number, salary from employees 
	where department_id = 6
	and employee_id = @empid
)

-- Use the TVF to fetch the required data.
-- Employee ID 105 works in department number 6 
select * from f_t_getEmpDetails(105)

-- Employee ID 101 works in department number 9
select * from f_t_getEmpDetails(101)


---------------------------------------------------------
/*
What is a trigger?

A trigger is a stored procedure in a database that automatically invokes whenever an event in the database occurs. 

What kind of events?
	1) Data Definition Language (DDL) events such as Create table, Create view, drop table, Drop view, and Alter table, etc.
	2) Data Manipulation Language (DML) events that begin with Insert, Update, and Delete.

Because a trigger cannot be called directly, unlike a stored procedure, it is referred to as a special procedure. 
A trigger is automatically called whenever a data modification event against a table takes place, which is the main distinction between a trigger 
and a procedure. Since a trigger cannot be called directly hence we cannot pass a parameter to it. 

Some of the benefits of using SQL triggers:
	> Data integrity: Triggers allow you to enforce complex business rules and constraints at the database level, ensuring that data remains consistent and accurate.
	> Automation: Triggers can automate repetitive or complex tasks by executing predefined actions whenever a specified event occurs. This reduces the need for manual intervention and improves efficiency.
	> Audit trails: Triggers can be used to track changes made to data, such as logging modifications in a separate audit table. This helps in auditing and maintaining a history of data changes.
*/


-----------------------------------------------------
-----  DDL Trigger
-----------------------------------------------------

-- Example 1 - Create a trigger which prevents deleting or creating tables in the database
create trigger tr_trigger1
on database  
for create_table , drop_table
as
begin
	rollback
	print 'Sorry. Hard Luck. Thats not allowed. My trigger will block you'
end

-- To delete the trigger permanently
drop trigger tr_trigger1 on database


---------------------------------------------------------
----   DML Trigger
---------------------------------------------------------

/*
	DML trigger statements use two special tables: the deleted table and the inserted table. You can use these temporary, memory-resident tables 
	to test certain data modifications' effects and set conditions for DML trigger actions. SQL Server automatically creates and manages these 
	tables.

For multiple DML operations being done in the trigger, these tables are affected in the following manner.

    If any record is being inserted into the main table, a new entry of the document being created is also inserted into the INSERTED table.  
    If any record is being deleted from the main table, an entry of the record is being deleted is inserted into the DELETED table.  
    If any record is being updated in the main table, an entry of that record (before it was updated) is added to the DELETED table, and another entry of that record (after it was updated) is inserted into the INSERTED table.
*/


-- To test the inserted and deleted tables lets create a new temporary table
drop table if exists temp
create table temp
(ID int, Gender varchar(10), Age int)


-- Example 1 - Create a trigger through which we will be able to select the inserted and deleted tables 
create or alter trigger tr_trigger
on temp
for insert, update, delete
as
begin
	select * from inserted
	select * from deleted
end


-- Execute the trigger by inserting some record
insert into temp
values
(123,'M',34),
(222, 'F', 64)


-- Lets delete that record
delete from temp
where id = 222


select * from temp


update temp set Gender = 'F', age = 19
where id = 123



/*
Example 2 - 

Create 3 tables 
	> t_active_emp_details to hold details of all employees currently employed
	> t_terminated_emp_list to hold a list of employee ids which have been terminated
	> t_past_emp_details to hold details of past employees

As soon as we enter an employee id in t_terminated_emp_list, the record of the corresponding employee should move automatically from 
t_active_emp_details to t_past_emp_details
*/


-- Create the first table

create table t_active_emp_details
(
emp_id INT NOT NULL,
name VARCHAR(50) NOT NULL,
gender VARCHAR(50) NOT NULL,
age INT NOT NULL
)


-- Lets insert some values into the table

INSERT INTO t_active_emp_details
VALUES
(4, 'Ana', 'Female', 40),
(2, 'Jon', 'Male', 20),
(3, 'Mike', 'Male', 54),
(1, 'Sara', 'Female', 34),
(6, 'Bill', 'Male', 23),
(5, 'Nicky', 'Female', 29),
(7, 'Ruby', 'Female', 44)


-- Create the 2nd table
create table t_terminated_emp_list (emp_id INT)


-- Create the 3rd table
create table t_past_emp_details
(
emp_id INT NOT NULL,
name VARCHAR(50) NOT NULL,
gender VARCHAR(50) NOT NULL,
age INT NOT NULL
)


-- Create a trigger which will fire if a new value is inserted in termination list
-- the trigger should remove the employee from active list and move them into past list
create or alter trigger tr_trigger2
on t_terminated_emp_list
for insert
as
begin
	declare @id int
	select @id = emp_id from inserted
	
	insert into t_past_emp_details select * from t_active_emp_details where emp_id = @id
	delete from t_active_emp_details where emp_id = @id 
end


-- Check the existing values in the tables
-- We can run all 3 select below together if we want
select * from t_terminated_emp_list
select * from t_past_emp_details
select * from t_active_emp_details


-- Now terminate an employee and run the select again
insert into t_terminated_emp_list values (6)



-------------------------------------------
-- Index
-------------------------------------------

/*
An index is a database object. It is used by the server to speed up the retrieval of rows.
An index helps to speed up select queries and where clauses, but it slows down data input like the update, delete and the insert statements. 
Indexes can be created or dropped with no effect on the data. 


Syntax:
	CREATE INDEX index
	ON TABLE column;

and
	DROP INDEX index;

and 
	ALTER INDEX IndexName
	ON TableName;
*/


-- Example 1 - Create an index on salary columns to enhance the performance of our queries

create index ix_employee_salary
on employees (salary)


-- To list the indexes in a table, use the following stored procedure
sp_helpindex employees

-- To drop an index
drop index employees.ix_employee_salary


-- A clustered index is an index which defines the physical order in which table records are stored in a database. 
-- Since there can be only one way in which records are physically stored in a database table, there can be only one clustered index per table. 
-- By default a clustered index is created on a primary key column.


CREATE TABLE tmp_employees
(
emp_id INT NOT NULL,
name VARCHAR(50) NOT NULL,
gender VARCHAR(50) NOT NULL,
age INT NOT NULL
)

-- Lets insert some values into the table
INSERT INTO tmp_employees
VALUES
(4, 'Ana', 'Female', 40),
(2, 'Jon', 'Male', 20),
(3, 'Mike', 'Male', 54),
(1, 'Sara', 'Female', 34),
(5, 'Nick', 'Female', 29)


-- Lets look at the records
select * from tmp_employees


-- Lets also check the current indexes in the table
sp_helpindex tmp_employees


-- Lets make emp_id a primary key
ALTER TABLE tmp_employees
ADD CONSTRAINT pk_tmp_emp_id PRIMARY KEY (emp_id)


-- Now look at the table again. Notice the sorting
select * from tmp_employees


-- Lets also check the current indexes in the table
sp_helpindex tmp_employees



------------------------------------

/*
Non-Clustered Indexes
A non-clustered index is also used to speed up search operations. Unlike a clustered index, a non-clustered index doesn’t physically define the order in which records are inserted into a table. In fact, a non-clustered index is stored in a separate location from the data table and hence there can be multiple non-clustered indexes per table.

To create a non-clustered index, you have to use the “CREATE NONCLUSTERED” statement. The rest of the syntax remains the same as the syntax for creating a clustered index. 
*/


-- Example
CREATE NONCLUSTERED INDEX ix_tmp_employees_Name
ON tmp_employees(name)


sp_helpindex tmp_employees


-- We can create as many non clustered index as required
CREATE NONCLUSTERED INDEX ix_tmp_employees_Age
ON tmp_employees(age)


-- We can also create an index with multiple columns
CREATE NONCLUSTERED INDEX ix_tmp_employees_NameAgeGender
ON tmp_employees(Name)
INCLUDE (gender,age)