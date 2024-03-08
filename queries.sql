--Данный запрос подсчитывает общее количество покупателей из таблицы customers
SELECT
	COUNT (*) AS customers_count
FROM
	customers;


--Данный запрос определяет десятку лучших продавцов по суммарной выручке. Также содержит информацию о количестве операций каждого из них.
SELECT
	(first_name || ' ' || last_name) AS name,
	COUNT (sales_person_id) AS operations,
	FLOOR(SUM(s.quantity * p.price)) AS income
FROM
	employees e
LEFT JOIN sales s
ON
	e.employee_id = s.sales_person_id
LEFT JOIN products p 
ON
	s.product_id = p.product_id
GROUP BY
	(first_name || ' ' || last_name)
ORDER BY
	income DESC NULLS LAST
LIMIT 10;

--Данный содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
--Таблица отсортирована по выручке по возрастанию.
SELECT
	(first_name || ' ' || last_name) AS name,
	FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM
	employees e
LEFT JOIN sales s
ON
	e.employee_id = s.sales_person_id
LEFT JOIN products p 
ON
	s.product_id = p.product_id
GROUP BY
	(first_name || ' ' || last_name)
HAVING
	FLOOR(AVG(s.quantity * p.price))<(
	SELECT
		FLOOR(AVG(s.quantity * p.price))
		FROM
	sales s
	LEFT JOIN products p 
ON
		s.product_id = p.product_id)
ORDER BY
	average_income ASC;

--Данный запрос предостовляет информацию по суммарной выручке по дням недели по каждому продавцу.
WITH tab AS (
SELECT
	(e.first_name || ' ' || e.last_name) as name,
	TO_CHAR(s.sale_date, 'Day') as weekday,
	EXTRACT(ISODOW FROM	s.sale_date) AS dow,
	FLOOR(SUM(s.quantity * p.price)) as income
FROM
	employees e
INNER JOIN sales s
ON
	e.employee_id = s.sales_person_id
LEFT JOIN products p 
ON
	s.product_id = p.product_id
GROUP BY
	(e.first_name || ' ' || e.last_name),
	weekday,
	dow)
	SELECT
	name,
	lower(weekday) AS weekday,
	income
FROM
	tab
ORDER BY
	dow,
	name;