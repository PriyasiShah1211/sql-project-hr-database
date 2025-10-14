# 🧠 **Advanced SQL Portfolio – HR Database**

### 📊 *Exploring Advanced SQL Concepts with a Realistic HR Scenario*

---

## 👩‍💻 **About Me**

Hi! I’m **Priyasi Shah**, an aspiring **SQL Developer / Data Analyst** passionate about transforming raw data into meaningful insights.  

This repository showcases my **SQL practice project** built using the **HR sample database** - focusing on analytical queries, performance tuning, and automation through database objects.

---

## 🗄️ **Database Used**

**HR Database**  
A standard in-built sample dataset used for learning SQL, containing details about:
- Employees 👩‍💼  
- Departments 🏢  
- Jobs 💼  

It models a typical HR system with relationships between employees, job roles, and organizational departments.

---

## 🎯 **About This Project**

This project demonstrates **advanced SQL concepts** using the HR sample database.  It simulates an **HR department’s analytics and data management needs**, covering:

- Employee details  
- Department structures  
- Salary and job role analytics  
- Database automation through UDFs, triggers, and indexing  

---

## 🧩 **Objectives**

1. 📈 Analyze salary and job trends  
2. ⚙️ Automate calculations using **triggers** and **user-defined functions (UDFs)**  
3. 🚀 Improve query performance using **indexing and optimization**  

---

## 📂 **Repository Overview**

| **File** | **Description** |
|-----------|-----------------|
| `01_Subqueries_DerivedTables_CTE.sql` | Advanced SQL script using Subqueries, Derived Tables, and Common Table Expressions (CTEs) |
| `02_Views_WindowsFunctions_StoredProcedures.sql` | Implementation of Views, Window Functions, and Stored Procedures |
| `03_UDFs_Triggers_Indexing.sql` | Scripts for creating User Defined Functions, Triggers, and Indexes |
| `HR_2_ERD.png` | Entity Relationship Diagram illustrating database relationships |
| `Screenshots/` | Folder containing output screenshots from executed queries |

---


## 🧰 **Tools Used**

- 🖥️ **SQL Server Management Studio (SSMS)** / **Microsoft SQL Server**  
  Used for writing, testing, and executing SQL queries, creating database objects, and optimizing performance.  

- 🔧 **Git & GitHub**  
  Used for version control, documentation, and sharing this project as part of my SQL portfolio.

---

## 👨‍💻 **Author**
**Priyasi Shah**  

📧 mailto:shahpriyasi1111@gmail.com

💼 https://www.linkedin.com/in/priyasi-shah/

🌐 https://github.com/PriyasiShah1211

---

## 💡 **Sample Query – Employee Salary Insights**

**Goal:**  
Compare each employee’s salary against the highest-paid person in their respective department.

**Concepts Used:**  
Aggregation, Window Functions

```sql
SELECT
    employee_id,
    email,
    department_name,
    salary,
    MAX(salary) OVER (PARTITION BY department_name) AS 'Highest_Dept_Sal'
FROM v_FullEmpData


