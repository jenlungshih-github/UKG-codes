SELECT p.[Person Number]
      , p.[First Name]
      , p.[Last Name]
      , p.[Parent Path]
	  , bs.[Parent Path] as UKG_BusinessStructure
FROM [BCK].[Person_Import_LOOKUP] p
    JOIN [BCK].[UKG_BusinessStructure_lookup] bs
    ON p.[Parent Path] = bs.[Parent Path]
WHERE p.[Person Number] IN (
    '10420386', '10467173', '10703043', '10703234', '10403560', '10406748'
)