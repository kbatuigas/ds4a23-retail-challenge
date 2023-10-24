WITH MonthlyRetention AS (
    SELECT
        DATE_TRUNC('month', order_date_yyyy_mm_dd) AS YearMonth,
        COUNT(DISTINCT order_customer_id) AS TotalCustomers
    FROM
        orders
    GROUP BY
        --EXTRACT(YEAR_MONTH FROM order_date_yyyy_mm_dd)
		YearMonth
),
NewCustomers AS (
    SELECT
        DATE_TRUNC('month', first_order_date) AS YearMonth,
        COUNT(DISTINCT order_customer_id) AS NewCustomers
    FROM
        (
            SELECT
                order_customer_id,
                MIN(order_date_yyyy_mm_dd) AS first_order_date
            FROM
                orders
            GROUP BY
                order_customer_id
        ) first_time_order
    GROUP BY
        --EXTRACT(YEAR_MONTH FROM first_order_date)
		YearMonth
)

SELECT 
    a.YearMonth,
    a.TotalCustomers,
    COALESCE(b.NewCustomers, 0) AS NewCustomers,
    ROUND(
		CAST(
			a.TotalCustomers - COALESCE(b.NewCustomers, 0) AS numeric) / a.TotalCustomers * 100, 
		2) AS RetentionRate,
    ROUND(
		LAG(
			CAST(a.TotalCustomers - COALESCE(b.NewCustomers, 0) AS numeric) / a.TotalCustomers * 100) 
			OVER (ORDER BY a.YearMonth),
		2) AS PreviousRetentionRate
FROM 
    MonthlyRetention a
LEFT JOIN 
    NewCustomers b 
ON 
    a.YearMonth = b.YearMonth;

