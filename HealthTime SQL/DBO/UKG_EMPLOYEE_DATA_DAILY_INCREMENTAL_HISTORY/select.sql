WITH
    ordered
    AS
    (
        SELECT *, LAG(hash_value) OVER (ORDER BY snapshot_date_TXT, snapshot_date) AS prev_hash, LAG(position_nbr) OVER (ORDER BY snapshot_date_TXT, snapshot_date) AS prev_pos, LAG(EMPL_RCD) OVER (ORDER BY snapshot_date_TXT, snapshot_date) AS prev_empl_rcd, LAG(termination_dt) OVER (ORDER BY snapshot_date_TXT, snapshot_date) AS prev_term, LAG(action) OVER (ORDER BY snapshot_date_TXT, snapshot_date) AS prev_action, LAG(action_dt) OVER (ORDER BY snapshot_date_TXT, snapshot_date) AS prev_action_dt, LAG(snapshot_date_TXT) OVER (ORDER BY snapshot_date_TXT, snapshot_date) AS prev_snap_txt
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
        WHERE EMPLID = '10473712'
    )
SELECT ROW_NUMBER() OVER (ORDER BY snapshot_date_TXT DESC, snapshot_date DESC) AS rn, snapshot_date, snapshot_date_TXT, NOTE, CONVERT(varchar(100), hash_value, 1) AS hash_value_text, CASE WHEN ISNULL(CONVERT(varchar(100),hash_value,1),'') = ISNULL(CONVERT(varchar(100),prev_hash,1),'') THEN 'SAME' ELSE 'DIFF' END AS hash_cmp, CASE WHEN ISNULL(CAST(position_nbr AS varchar(50)),'') = ISNULL(CAST(prev_pos AS varchar(50)),'') THEN 'SAME' ELSE 'DIFF' END AS pos_cmp, CASE WHEN ISNULL(CAST(EMPL_RCD AS varchar(10)),'') = ISNULL(CAST(prev_empl_rcd AS varchar(10)),'') THEN 'SAME' ELSE 'DIFF' END AS empl_rcd_cmp, CASE WHEN ISNULL(CONVERT(varchar(30),termination_dt,121),'') = ISNULL(CONVERT(varchar(30),prev_term,121),'') THEN 'SAME' ELSE 'DIFF' END AS term_cmp, CASE WHEN ISNULL(action,'') = ISNULL(prev_action,'') THEN 'SAME' ELSE 'DIFF' END AS action_cmp, CASE WHEN ISNULL(CONVERT(varchar(30),action_dt,121),'') = ISNULL(CONVERT(varchar(30),prev_action_dt,121),'') THEN 'SAME' ELSE 'DIFF' END AS action_dt_cmp, CASE WHEN snapshot_date_TXT = prev_snap_txt THEN 'SAME' ELSE 'DIFF' END AS snap_txt_cmp
FROM ordered
ORDER BY snapshot_date_TXT DESC, snapshot_date DESC;