SELECT
    date_part('year',np.connote__created_at) AS connote__created_at,
    badan_hukum.kategori,
    COUNT(distinct np.customer_code)total_pelanggan
FROM nipos.nipos np
join (select idregpelanggan,
m_pelanggan.id_badan_hukum,
CASE
    WHEN badan_hukum.badan_hukum like '%BUMN%' THEN 'BUMN'
    WHEN badan_hukum.badan_hukum = 'PEMERINTAH' THEN 'PEMERINTAH'
    ELSE 'SWASTA'
END AS kategori
from m_pelanggan
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
GROUP BY 1,2
