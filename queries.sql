--Данный запрос подсчитывает общее количество покупателей из таблицы customers
SELECT
	COUNT (*) AS customers_count
FROM
	customers;

--Данный запрос определяет десятку лучших продавцов по суммарной выручке. Также содержит информацию о количестве операций каждого из них.
SELECT
	first_name || ' ' || last_name AS name,
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
	1
ORDER BY
	income DESC NULLS LAST
LIMIT 10;

--Данный содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
--Таблица отсортирована по выручке по возрастанию.
SELECT
	first_name || ' ' || last_name AS name,
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
	1
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
	e.first_name || ' ' || e.last_name as name,
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
	1, 2, 3
	)
	SELECT
	name,
	lower(weekday) AS weekday,
	income
FROM
	tab
ORDER BY
	dow,
	name;

--Данный запрос выводит количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. Сортировка по возрастным группам
SELECT
	CASE
		WHEN age BETWEEN 16 AND 25 THEN '16-25'
		WHEN age BETWEEN 26 AND 40 THEN '26-40'
		WHEN age > 40 THEN '40+'
	END AS age_category,
	COUNT(*)
FROM
	customers
GROUP BY
	age_category
ORDER BY
	age_category;

--Данный запрос выводит данные по количеству уникальных покупателей и выручке за месяц. Сортировка по дате по возрастанию.
select
	to_char(sale_date,'YYYY-MM') as date,
	count (distinct customer_id) as total_customers,
	FLOOR(SUM(s.quantity * p.price)) as income
from
	sales s
join products p
on
		s.product_id = p.product_id
group by
	1
order by
	date;

--Данный запрос предоставляет отчет о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0) с данными о дате и продавце. 
--Сортировка по id.
select
	distinct on
	(c.customer_id)
    c.first_name || ' ' || c.last_name as customer,
	sale_date,
	e.first_name || ' ' || e.last_name as seller
from
	sales s
left join customers c 
on
	s.customer_id = c.customer_id
left join employees e
on
	s.sales_person_id = e.employee_id
left join products p
on
	s.product_id = p.product_id
where
	p.price = 0
order by
	c.customer_id,
	sale_date;