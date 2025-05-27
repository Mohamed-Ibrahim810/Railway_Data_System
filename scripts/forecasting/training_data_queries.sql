--* Number of rides for each day *
-- count transactions for each day
SELECT dd.full_date, COUNT(transaction_id) AS Rides_Count
FROM gold.fact_railway f
JOIN gold.dim_date dd ON f.journey_date_id = dd.date_id
GROUP BY dd.full_date
ORDER BY dd.full_date

-- * Revenue for each day *
-- sum of price for each day, group by full_date(journey_date)
-- where "refund = NO"
-- tables: fact,date,journey

SELECT * FROM gold.

SELECT dd.full_date, SUM(f.price) AS Revenue
FROM gold.fact_railway f
JOIN gold.dim_date dd ON f.purchase_date_id = dd.date_id
JOIN gold.dim_journey j ON f.journey_id = j.journey_id
WHERE refund_request = 'No'
GROUP BY dd.full_date
ORDER BY dd.full_date

SELECT 
    date_of_purchase,
	time_of_purchase,
    SUM(price) AS revenue,
    ticket_type,
    railcard,
    ticket_class,
    purchase_type,
    departure_station,
	arrival_station,
    date_of_journey
FROM silver.railway
WHERE refund_request = 'No'
GROUP BY
    date_of_purchase,
	time_of_purchase,
    ticket_type,
    railcard,
    ticket_class,
    purchase_type,
    departure_station,
	arrival_station,
    date_of_journey
-- * Specify the demand on different ticket classes *
-- ticket classes: first or standerd
-- num of journeys each day with first or standerd class
--- columns: full_date, count of first class, count of standerd class
--- tables: fact, date, ticket

SELECT date_of_purchase,
COUNT(CASE WHEN ticket_class = 'First Class' THEN 1 END) AS First_Class_Count
FROM silver.railway
where month(date_of_purchase) != '12'
GROUP BY date_of_purchase
ORDER BY date_of_purchase

SELECT date_of_purchase,
COUNT(CASE WHEN ticket_class = 'Standard' THEN 1 END) AS Standard_Class_Count
FROM silver.railway
where month(date_of_purchase) != '12'
GROUP BY date_of_purchase
ORDER BY date_of_purchase


SELECT dd.full_date,
COUNT(CASE WHEN t.ticket_class = 'Standard' THEN 1 END) AS Standard_Class_Count
FROM gold.fact_railway f
JOIN gold.dim_date dd ON f.purchase_date_id = dd.date_id
JOIN gold.dim_ticket t ON f.ticket_id = t.ticket_id
GROUP BY dd.full_date
ORDER BY dd.full_date
