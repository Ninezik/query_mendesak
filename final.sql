SELECT
    date(np.connote__created_at) AS connote__created_at,
    np.customer_code,
    badan_hukum.kategori,
    COUNT(connote__connote_code) AS produksi,
    SUM(
        COALESCE(connote__connote_service_price,0)
        + COALESCE(connote__connote_surcharge_amount,0)
    ) +
    SUM(
        CASE 
            WHEN UPPER(customer_code) = 'DAGSHOPEE04120A'
             AND UPPER(custom_field__cod) != 'NONCOD'
            THEN COALESCE(t_webhook.good_value, 0) * 0.005
            ELSE COALESCE(np.custom_field__fee_value, 0)
        END
    ) pendapatan
FROM nipos.nipos np
LEFT JOIN (
    SELECT DISTINCT resi, good_value
    FROM nipos.webhook_marketplace
    WHERE member_id = 'DAGSHOPEE04120A'
) t_webhook
ON np.connote__connote_booking_code = t_webhook.resi
join (select idregpelanggan,
m_pelanggan.id_badan_hukum,
CASE
    WHEN badan_hukum.badan_hukum like '%BUMN%' THEN 'BUMN'
    WHEN badan_hukum.badan_hukum = 'PEMERINTAH' THEN 'PEMERINTAH'
    ELSE 'SWASTA'
END AS kategori
from referensi.m_pelanggan
join (SELECT id_badan_hukum, badan_hukum
FROM referensi.ref_badan_hukum)badan_hukum
on m_pelanggan.id_badan_hukum=badan_hukum.id_badan_hukum )badan_hukum
on np.customer_code =UPPER(badan_hukum.idregpelanggan)
WHERE
    UPPER(connote__location_name) != 'AGP TESTING LOCATION'
    AND connote__connote_amount >= 0
    AND connote__connote_service != 'LNINCOMING'
    AND UPPER(connote__connote_state) NOT IN ('CANCEL', 'PENDING')
    and np.connote__created_at >'20250101'
GROUP BY 1,2,3
