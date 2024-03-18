--Данный запрос подсчитывает общее количество покупателей из таблицы customers
SELECT COUNT(*) AS customers_count
FROM
    customers;

/*Данный запрос определяет десятку лучших продавцов по суммарной выручке.
Также содержит информацию о количестве операций каждого из них.*/
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    COUNT(s.sales_person_id) AS operations,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    employees AS e
LEFT JOIN sales AS s
    ON
        e.employee_id = s.sales_person_id
LEFT JOIN products AS p
    ON
        s.product_id = p.product_id
GROUP BY
    seller
ORDER BY
    income DESC NULLS LAST
LIMIT 10;

/*Данный содержит информацию о продавцах,
чья средняя выручка за сделку меньше средней
выручки за сделку по всем продавцам.
Таблица отсортирована по выручке по возрастанию.*/
SELECT
    e.first_name || ' ' || e.last_name AS seller,
    FLOOR(AVG(s.quantity * p.price)) AS average_income
FROM
    employees AS e
LEFT JOIN sales AS s
    ON
        e.employee_id = s.sales_person_id
LEFT JOIN products AS p
    ON
        s.product_id = p.product_id
GROUP BY
    seller
HAVING
    FLOOR(AVG(s.quantity * p.price)) < (
        SELECT FLOOR(AVG(s.quantity * p.price))
        FROM
            sales AS s
        LEFT JOIN products AS p
            ON
                s.product_id = p.product_id
    )
ORDER BY
    average_income ASC;

/*Данный запрос предостовляет информацию по
суммарной выручке по дням недели по каждому продавцу.*/
WITH tab AS (
    SELECT
        e.first_name || ' ' || e.last_name AS seller,
        TO_CHAR(s.sale_date, 'Day') AS day_of_week,
        EXTRACT(ISODOW FROM s.sale_date) AS dow,
        FLOOR(SUM(s.quantity * p.price)) AS income
    FROM
        employees AS e
    INNER JOIN sales AS s
        ON
            e.employee_id = s.sales_person_id
    LEFT JOIN products AS p
        ON
            s.product_id = p.product_id
    GROUP BY
        seller, day_of_week, dow
)

SELECT
    seller,
    income,
    LOWER(day_of_week) AS day_of_week
FROM
    tab
ORDER BY
    dow,
    seller;

/*Данный запрос выводит количество покупателей
в разных возрастных группах: 16-25, 26-40 и 40+.
Сортировка по возрастным группам*/
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 THEN '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM
    customers
GROUP BY
    age_category
ORDER BY
    age_category;

/*Данный запрос выводит данные по количеству уникальных покупателей и
выручке за месяц. Сортировка по дате по возрастанию.*/
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM
    sales AS s
INNER JOIN products AS p
    ON
        s.product_id = p.product_id
GROUP BY
    selling_month
ORDER BY
    selling_month;

/*Данный запрос предоставляет отчет о покупателях, первая покупка которых была
в ходе проведения акций (акционные товары отпускали
со стоимостью равной 0) с данными о дате и продавце.
Сортировка по id покупателя.*/
SELECT DISTINCT ON
(c.customer_id)
    s.sale_date,
    c.first_name || ' ' || c.last_name AS customer,
    e.first_name || ' ' || e.last_name AS seller
FROM
    sales AS s
LEFT JOIN customers AS c
    ON
        s.customer_id = c.customer_id
LEFT JOIN employees AS e
    ON
        s.sales_person_id = e.employee_id
LEFT JOIN products AS p
    ON
        s.product_id = p.product_id
WHERE
    p.price = 0
ORDER BY
    c.customer_id,
    s.sale_date;
