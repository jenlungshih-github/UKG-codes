SELECT p.[Person Number]
      , p.[First Name]
      , p.[Last Name]
      , p.[Parent Path]
	  , bs.[Parent Path] as UKG_BusinessStructure
FROM [BCK].[Person_Import_LOOKUP] p
    LEFT JOIN [BCK].[UKG_BusinessStructure_lookup] bs
    ON p.[Parent Path] = bs.[Parent Path]
WHERE p.[Person Number] IN (
    '10401420', '10405360', '10406848', '10409321', '10413689',
    '10415110', '10420612', '10422674', '10438746', '10467173',
    '10491749', '10578994', '10624479', '10649385', '10705785',
    '10715715', '10730925', '10744203', '10822439'
)