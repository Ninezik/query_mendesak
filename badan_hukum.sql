select idregpelanggan,
m_pelanggan.id_badan_hukum,
CASE
    WHEN badan_hukum.badan_hukum like '%BUMN%' THEN 'BUMN'
    WHEN badan_hukum.badan_hukum = 'PEMERINTAH' THEN 'PEMERINTAH'
    ELSE 'SWASTA'
END AS kategori
from m_pelanggan
join (SELECT id_badan_hukum, badan_hukum
FROM referensi.ref_badan_hukum)badan_hukum
on m_pelanggan.id_badan_hukum=badan_hukum.id_badan_hukum 
