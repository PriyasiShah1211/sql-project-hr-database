ADVANCED SQL PORTFOLIO – HR DATABASE

1. About Me
Hi! I am Priyasi Shah, an aspiring SQL Developer / Data Analyst passionate about turning raw data into insights. This repository showcases my SQL practice project built using HR sample database.

2. Database Used
HR Database – employee, department, and job data. It is a standard in-built database used to learn SQL.

3. About This Project
This project uses the HR sample database to demonstrate advanced SQL concepts from Analytical Queries to Performance Optimization and Automation.
It simulates an HR department’s data analysis needs - including employee details, department structures, salaries, and job roles.

4. Objectives
	1. Analyse salary and job trends
	2. Automate calculations using triggers and user-defined functions
	3. Improve performance using indexing

5. Repository Overview
File : 01_Subqueries_DerivedTables_CTEDescription : Advanced SQL script to work with Subqueries, Derived Tables, and Common Table Expressions (CTEs)
File : 02_Views_WindowsFunctions_StoredProceduresDescription : Advanced SQL script to work with Views, Windows Function, and Stored ProceduresFile : 03_UDFs_Triggers_IndexingDescription : Advanced SQL script to work with UDFs, Triggers, IndexesFile : HR_2_ERDDescription : Highlights relationships between database entitiesFile : ScreenshotsDescription : Sample output screenshots from executed queries
6. Sample Query - Employee Salary Insights
Goal - Compare the salary of each employee against the salary of the highest paid person in their respective department.
Concept/s used – Aggregation, Windows Function

	select	
		employee_id, email, department_name, salary,max(salary) over(partition by department_name) as 'Highest_Dept_Sal'
	from v_FullEmpData

7. Tools Used
	1. SQL Server Management Studio / MS SQL Server
	2. Git & GitHub (for version control)

8. Skills Demonstrated
	1. Query Optimization & Indexing
	2. Analytical SQL (aggregations, subqueries, window functions)
	3. Creating and Managing Views, Triggers, and UDFs
	4. Writing Maintainable SQL Code

9. Connect With Me
	1. LinkedIn: www.linkedin.com/in/priyasi-shah/
	2. Email: shahpriyasi1111@gmail.com
	3. GitHub: github.com/PriyasiShah1211

