-- 1.Retrieve the first name and last name of all employees.
SELECT first_name, last_name
FROM employees;

-- 2.Find the department numbers and names.
SELECT department_id, department_name
FROM departments;

-- 3.Get the total number of employees.
SELECT COUNT(employee_id) AS total_employees
FROM employees;

-- 4.Find the average salary of all employees.

SELECT AVG(salary) AS average_salary
FROM employees;

-- 5.Retrieve the birth date and hire date of employee with emp_no 10003.
SELECT birth_date, hire_date
FROM employees
WHERE emp_no = 10003;

-- 6.Find the titles of all employees.
SELECT title
FROM titles;

-- 7.Get the total number of departments.
SELECT COUNT(department_id) AS total_departments
FROM departments;

-- 8.Retrieve the department number and name where employee with emp_no 10004 works.
SELECT d.department_id, d.department_name
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
WHERE de.emp_no = 10004;

-- 9.Find the gender of employee with emp_no 10007.

SELECT gender
FROM employees
WHERE emp_no = 10007;

-- 10.Get the highest salary among all employees.
SELECT MAX(salary) AS highest_salary
FROM employees;

-- 11.Retrieve the names of all managers along with their department names.
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
JOIN departments d ON dm.department_id = d.department_id;

-- 12.Find the department with the highest number of employees.

SELECT d.department_id, d.department_name, COUNT(de.emp_no) AS employee_count
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC
LIMIT 1;

-- 13.Retrieve the employee number, first name, last name, and salary of employees earning more
--  than $60,000.
SELECT emp_no, first_name, last_name, salary
FROM employees
WHERE salary > 60000;

-- 14.Get the average salary for each department.
SELECT d.department_name, AVG(s.salary) AS average_salary
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
JOIN salaries s ON de.emp_no = s.emp_no
GROUP BY d.department_name;

-- 15.Retrieve the employee number, first name, last name, and title of all employees who are
-- currently managers.
SELECT e.emp_no, e.first_name, e.last_name, t.title
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
JOIN titles t ON e.emp_no = t.emp_no
WHERE CURRENT_DATE BETWEEN t.from_date AND t.to_date
AND CURRENT_DATE BETWEEN dm.from_date AND dm.to_date;

-- 16.Find the total number of employees in each department.
SELECT d.department_name, COUNT(de.emp_no) AS employee_count
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
GROUP BY d.department_id, d.department_name;

-- 17. Retrieve the department number and name where the most recently hired employee works.
SELECT d.department_id, d.department_name
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
JOIN (
    SELECT emp_no
    FROM employees
    ORDER BY hire_date DESC
    LIMIT 1
) e ON de.emp_no = e.emp_no;

-- 18.Get the department number, name, and average salary for departments with more than 3
-- employees.
SELECT d.department_id, d.department_name, AVG(s.salary) AS average_salary
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
JOIN salaries s ON de.emp_no = s.emp_no
GROUP BY d.department_id, d.department_name
HAVING COUNT(de.emp_no) > 3;

-- 19.Retrieve the employee number, first name, last name, and title of all employees hired in 2005.
SELECT e.emp_no, e.first_name, e.last_name, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE YEAR(e.hire_date) = 2005;

-- 20.Find the department with the highest average salary.

SELECT d.department_id, d.department_name, AVG(s.salary) AS average_salary
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
JOIN salaries s ON de.emp_no = s.emp_no
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC
LIMIT 1;
-- 21.Retrieve the employee number, first name, last name, and salary of employees hired before the
-- year 2005.

SELECT e.emp_no, e.first_name, e.last_name, s.salary
FROM employees e
JOIN salaries s ON e.emp_no = s.emp_no
WHERE e.hire_date < '2005-01-01';

-- 22.Get the department number, name, and total number of employees for departments with a
-- female manager.

SELECT d.department_id, d.department_name, COUNT(de.emp_no) AS total_employees
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
JOIN dept_manager dm ON d.department_id = dm.department_id
JOIN employees e ON dm.emp_no = e.emp_no
WHERE e.gender = 'F'
GROUP BY d.department_id, d.department_name;

-- 23.Retrieve the employee number, first name, last name, and department name of employees who
-- are currently working in the Finance department.

SELECT e.emp_no, e.first_name, e.last_name, d.department_name
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.department_id = d.department_id
WHERE d.department_name = 'Finance'
  AND (de.to_date IS NULL OR de.to_date > CURRENT_DATE);

-- 24.Find the employee with the highest salary in each department.

WITH DepartmentSalaries AS (
    SELECT de.department_id, e.emp_no, e.first_name, e.last_name, s.salary,
           ROW_NUMBER() OVER (PARTITION BY de.department_id ORDER BY s.salary DESC) AS rank
    FROM employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    JOIN salaries s ON e.emp_no = s.emp_no
    JOIN departments d ON de.department_id = d.department_id
)
SELECT ds.department_id, d.department_name, ds.emp_no, ds.first_name, ds.last_name, ds.salary
FROM DepartmentSalaries ds
JOIN departments d ON ds.department_id = d.department_id
WHERE ds.rank = 1;

-- 25.Retrieve the employee number, first name, last name, and department name of employees who
-- have held a managerial position.

SELECT e.emp_no, e.first_name, e.last_name, d.department_name
FROM employees e
JOIN dept_manager dm ON e.emp_no = dm.emp_no
JOIN departments d ON dm.department_id = d.department_id
JOIN dept_emp de ON e.emp_no = de.emp_no AND d.department_id = de.department_id
GROUP BY e.emp_no, e.first_name, e.last_name, d.department_name;

-- 26.Get the total number of employees who have held the title "Senior Manager."
SELECT COUNT(DISTINCT emp_no) AS total_senior_managers
FROM titles
WHERE title = 'Senior Manager';


-- 27.Retrieve the department number, name, and the number of employees who have worked there
-- for more than 5 years.

SELECT d.department_id, d.department_name, COUNT(de.emp_no) AS employee_count
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
JOIN employees e ON de.emp_no = e.emp_no
WHERE DATEDIFF(CURRENT_DATE, de.from_date) > 365 * 5
  AND (de.to_date IS NULL OR de.to_date > CURRENT_DATE)
GROUP BY d.department_id, d.department_name;

-- 28.Find the employee with the longest tenure in the company.
SELECT e.emp_no, e.first_name, e.last_name, e.hire_date, DATEDIFF(CURRENT_DATE, e.hire_date) AS tenure_days
FROM employees e
ORDER BY tenure_days DESC
LIMIT 1;
----------------------
SELECT e.emp_no, e.first_name, e.last_name, MIN(de.from_date) AS start_date, DATEDIFF(CURRENT_DATE, MIN(de.from_date)) AS tenure_days
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
GROUP BY e.emp_no, e.first_name, e.last_name
ORDER BY tenure_days DESC
LIMIT 1;


-- 29.Retrieve the employee number, first name, last name, and title of employees whose hire date is
-- between '2005-01-01' and '2006-01-01'.
SELECT e.emp_no, e.first_name, e.last_name, t.title
FROM employees e
JOIN titles t ON e.emp_no = t.emp_no
WHERE e.hire_date BETWEEN '2005-01-01' AND '2006-01-01';

-- 30.Get the department number, name, and the oldest employee's birth date for each department.
SELECT d.department_id, d.department_name, MIN(e.birth_date) AS oldest_birth_date
FROM departments d
JOIN dept_emp de ON d.department_id = de.department_id
JOIN employees e ON de.emp_no = e.emp_no
GROUP BY d.department_id, d.department_name;
