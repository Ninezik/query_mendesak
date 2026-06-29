select*,
ROUND(
    (
        user_baru - LAG(user_baru) OVER (ORDER BY connote__created_at)
    ) * 100.0
    /
    NULLIF(LAG(user_baru) OVER (ORDER BY connote__created_at),0)
,2) AS growth_user_bar
FROM
(WITH first_transaction AS (
    SELECT
        connote__connote_sender_phone,
        MIN(date(connote__created_at)) AS first_transaction_date
    FROM nipos.nipos
    WHERE
        UPPER(connote__location_name) != 'AGP TESTING LOCATION'
        AND connote__connote_amount >= 0
        AND connote__connote_service != 'LNINCOMING'
        AND UPPER(connote__connote_state) NOT IN ('CANCEL', 'PENDING')
        AND LEFT(UPPER(connote__connote_booking_code),3) IN ('PON','QOB')
    GROUP BY connote__connote_sender_phone
)

SELECT
    DATE_TRUNC('month', np.connote__created_at) AS connote__created_at,

    COUNT(DISTINCT np.connote__connote_sender_phone) AS user_aktif,

    COUNT(DISTINCT CASE
        WHEN DATE_TRUNC('month', ft.first_transaction_date)
           = DATE_TRUNC('month', np.connote__created_at)
        THEN np.connote__connote_sender_phone
    END) AS user_baru,

    COUNT(np.connote__connote_code) AS produksi,

    SUM(
        COALESCE(connote__connote_service_price,0)
        + COALESCE(connote__connote_surcharge_amount,0)
    )
    +
    SUM(
        CASE
            WHEN UPPER(customer_code) = 'DAGSHOPEE04120A'
             AND UPPER(custom_field__cod) != 'NONCOD'
            THEN COALESCE(t_webhook.good_value,0) * 0.005
            ELSE COALESCE(np.custom_field__fee_value,0)
        END
    ) AS pendapatan
FROM nipos.nipos np
LEFT JOIN first_transaction ft
    ON np.connote__connote_sender_phone = ft.connote__connote_sender_phone
LEFT JOIN (
    SELECT DISTINCT
        resi,
        good_value
    FROM nipos.webhook_marketplace
    WHERE member_id='DAGSHOPEE04120A'
) t_webhook
ON np.connote__connote_booking_code=t_webhook.resi
WHERE
    UPPER(connote__location_name) != 'AGP TESTING LOCATION'
    AND connote__connote_amount >= 0
    AND connote__connote_service != 'LNINCOMING'
    AND UPPER(connote__connote_state) NOT IN ('CANCEL', 'PENDING')
    AND LEFT(UPPER(connote__connote_booking_code),3) IN ('PON','QOB')
    AND np.connote__created_at > '20250101'
GROUP BY 1)t1
order by 1
