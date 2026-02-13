-- Convert lookup to CTE and join with UKG_EMPLOYEE_DATA_TEMP
WITH
    PositionBS
    AS
    (
        SELECT P.posn_status,
            P.position_nbr,
            B.*
        FROM health_ods.health_ods.[stage].[CURRENT_POSITION_PRI_FIN_UNIT_ALL_LOOKUP] AS P
            LEFT JOIN [hts].[UKG_BusinessStructure] B
            ON P.fdm_combo_cd = B.[COMBOCODE]
        WHERE P.fdm_combo_cd IS NOT NULL
            AND B.[COMBOCODE] IS NOT NULL
            AND P.POSN_STATUS <> 'A'
    )
SELECT pb.posn_status, u.*
FROM PositionBS pb
    INNER JOIN [dbo].[UKG_EMPLOYEE_DATA_TEMP] u
    ON pb.position_nbr = u.position_nbr;