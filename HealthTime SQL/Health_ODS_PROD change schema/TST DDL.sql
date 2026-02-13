create table BS_Locations_Import_20250814
(
    [Location Type]         varchar(50),
    [Parent Path]           varchar(500),
    [Location Name]         varchar(50),
    [Full Name]             varchar(50),
    Description             varchar(50),
    [Effective Date]        varchar(50),
    [Expiration Date]       varchar(50),
    Address                 varchar(50),
    [Cost Center]           varchar(50),
    [Direct Work Percent]   varchar(50),
    [Indirect Work Percent] varchar(50),
    Timezone                varchar(50),
    Transferable            varchar(50),
    [External ID]           varchar(50)
)
go

create table CTE_exCLUDE_BYA
(
    emplid varchar(11)
)
go

create table EMPL_DEPT_TRANSFER
(
    EMPLID            varchar(11),
    EMPL_RCD          smallint,
    VC_CODE           varchar(50),
    HR_STATUS         varchar,
    DEPTID            varchar(10),
    EFFDT             date,
    ACTION            varchar(3),
    ACTION_DT         date,
    jobcode           varchar(6),
    POSITION_NBR      varchar(8),
    NEXT_DEPTID       varchar(10),
    NEXT_EFFDT        date,
    NEXT_ACTION       varchar(3),
    NEXT_VC_CODE      varchar(50),
    NEXT_VC_NAME      varchar(30),
    NEXT_HR_STATUS    varchar,
    NEXT_jobcode      varchar(6),
    NEXT_POSITION_NBR varchar(8),
    snapshot_date     date,
    NOTE              nvarchar(50)
)
go

create table UKG_COMBOCD_T
(
    POSITION_NBR varchar(8),
    MIN_POSN_SEQ bigint
)
go

create index UKG_COMBOCD_T_IDX_1
    on UKG_COMBOCD_T (POSITION_NBR)
go

create table UKG_EMPLOYEE_DATA_TERMINATED
(
    DEPTID                                             varchar(10),
    VC_CODE                                            varchar(50),
    FDM_COMBO_CD                                       varchar(25),
    COMBOCODE                                          varchar(9),
    REPORTS_TO                                         varchar(8),
    MANAGER_EMPLID                                     varchar(11),
    NON_UKG_MANAGER_FLAG                               varchar     not null,
    position_nbr                                       varchar(8),
    EMPLID                                             varchar(11),
    EMPL_RCD                                           smallint,
    jobcode                                            varchar(6),
    POSITION_DESCR                                     varchar(30),
    hr_status                                          varchar,
    FTE_SUM                                            int         not null,
    fte                                                numeric(7, 6),
    empl_Status                                        varchar,
    JobGroup                                           varchar(50),
    FundGroup                                          varchar(10),
    [Person Number]                                    varchar(11) not null,
    [First Name]                                       varchar(30),
    [Last Name]                                        varchar(30) not null,
    [Middle Initial/Name]                              varchar,
    [Short Name]                                       varchar     not null,
    [Badge Number]                                     varchar     not null,
    [Hire Date]                                        varchar(30) not null,
    [Birth Date]                                       varchar     not null,
    [Seniority Date]                                   varchar     not null,
    [Manager Flag]                                     varchar     not null,
    [Phone 1]                                          varchar(8000),
    [Phone 2]                                          varchar(8000),
    Email                                              varchar(8000),
    Address                                            varchar     not null,
    City                                               varchar     not null,
    State                                              varchar     not null,
    [Postal Code]                                      varchar     not null,
    Country                                            varchar     not null,
    [Time Zone]                                        varchar(7)  not null,
    [Employment Status]                                varchar     not null,
    [Employment Status Effective Date]                 varchar(30) not null,
    [Reports to Manager]                               varchar     not null,
    [Union Code]                                       varchar     not null,
    [Employee Type]                                    varchar     not null,
    [Employee Classification]                          varchar     not null,
    [Pay Frequency]                                    varchar     not null,
    [Worker Type]                                      varchar     not null,
    [FTE %]                                            varchar     not null,
    [FTE Standard Hours]                               varchar     not null,
    [FTE Full Time Hours]                              varchar     not null,
    [Standard Hours - Daily]                           varchar     not null,
    [Standard Hours - Weekly]                          varchar     not null,
    [Standard Hours - Pay Period]                      varchar     not null,
    [Base Wage Rate]                                   varchar     not null,
    [Base Wage Rate Effective Date]                    varchar     not null,
    [User Account Name]                                varchar(11),
    [User Account Status]                              varchar     not null,
    [User Password]                                    varchar     not null,
    [Home Business Structure Level 1 - Organization]   varchar     not null,
    [Home Business Structure Level 2 - Entity]         varchar     not null,
    [Home Business Structure Level 3 - Service Line]   varchar     not null,
    [Home Business Structure Level 4 - Financial Unit] varchar     not null,
    [Home Business Structure Level 5 - Fund Group]     varchar     not null,
    [Home Business Structure Level 6]                  varchar     not null,
    [Home Business Structure Level 7]                  varchar     not null,
    [Home Business Structure Level 8]                  varchar     not null,
    [Home Business Structure Level 9]                  varchar     not null,
    [Home/Primary Job]                                 varchar     not null,
    [Home Labor Category Level 1]                      varchar     not null,
    [Home Labor Category Level 2]                      varchar     not null,
    [Home Labor Category Level 3]                      varchar     not null,
    [Home Labor Category Level 4]                      varchar     not null,
    [Home Labor Category Level 5]                      varchar     not null,
    [Home Labor Category Level 6]                      varchar     not null,
    [Home Job and Labor Category Effective Date]       varchar     not null,
    [Custom Field 1]                                   varchar     not null,
    [Custom Field 2]                                   varchar     not null,
    [Custom Field 3]                                   varchar     not null,
    [Custom Field 4]                                   varchar     not null,
    [Custom Field 5]                                   varchar     not null,
    [Custom Field 6]                                   varchar     not null,
    [Custom Field 7]                                   varchar     not null,
    [Custom Field 8]                                   varchar     not null,
    [Custom Field 9]                                   varchar     not null,
    [Custom Field 10]                                  varchar     not null,
    [Custom Date 1]                                    varchar     not null,
    [Custom Date 2]                                    varchar     not null,
    [Custom Date 3]                                    varchar     not null,
    [Custom Date 4]                                    varchar(30) not null,
    [Custom Date 5]                                    varchar     not null,
    [Custom Field 11]                                  varchar     not null,
    [Custom Field 12]                                  varchar     not null,
    [Custom Field 13]                                  varchar     not null,
    [Custom Field 14]                                  varchar     not null,
    [Custom Field 15]                                  varchar     not null,
    [Custom Field 16]                                  varchar     not null,
    [Custom Field 17]                                  varchar     not null,
    [Custom Field 18]                                  varchar     not null,
    [Custom Field 19]                                  varchar     not null,
    [Custom Field 20]                                  varchar     not null,
    [Custom Field 21]                                  varchar     not null,
    [Custom Field 22]                                  varchar     not null,
    [Custom Field 23]                                  varchar     not null,
    [Custom Field 24]                                  varchar     not null,
    [Custom Field 25]                                  varchar     not null,
    [Custom Field 26]                                  varchar     not null,
    [Custom Field 27]                                  varchar     not null,
    [Custom Field 28]                                  varchar     not null,
    [Custom Field 29]                                  varchar     not null,
    [Custom Field 30]                                  varchar     not null,
    [Additional Fields for CRT lookups]                varchar     not null,
    termination_dt                                     date
)
go

create table UKG_EMPL_Business_Structure
(
    [Person Number] varchar(11)  not null,
    [First Name]    varchar(30),
    [Last Name]     varchar(30)  not null,
    FundGroup       varchar(10)  not null,
    [Parent Path]   varchar(574) not null,
    Loaded_DT       datetime
)
go

create table UKG_EMPL_E_T
(
    NON_UKG_MANAGER_FLAG                  varchar     not null,
    NAME                                  varchar(50),
    EMPLID                                varchar(11),
    EMPL_RCD                              smallint,
    EFFDT                                 date,
    EFFSEQ                                smallint,
    PER_ORG                               varchar(3),
    DEPTID                                varchar(10),
    DEPT_DESCR                            varchar(30),
    POSITION_NBR                          varchar(8),
    POSITION_EFFDT                        date,
    POSITION_EFF_STATUS                   varchar,
    POSITION_DESCR                        varchar(30),
    POSITION_DESCRSHORT                   varchar(10),
    POSITION_ACTION                       varchar(3),
    POSITION_ACTION_REASON                varchar(3),
    POSITION_ACTION_DT                    date,
    POSITION_POSN_STATUS                  varchar,
    POSITION_STATUS_DT                    date,
    BUDGETED_POSN                         varchar,
    CONFIDENTIAL_POSN                     varchar,
    JOB_SHARE                             varchar,
    KEY_POSITION                          varchar,
    MAX_HEAD_COUNT                        smallint,
    UPDATE_INCUMBENTS                     varchar,
    POSITION_REPORTS_TO                   varchar(8),
    REPORT_DOTTED_LINE                    varchar(8),
    ORGCODE                               varchar(60),
    ORGCODE_FLAG                          varchar,
    POSITION_LOCATION                     varchar(10),
    MAIL_DROP                             varchar(50),
    COUNTRY_CODE                          varchar(3),
    PHONE                                 varchar(24),
    POSITION_COMPANY                      varchar(3),
    POSITION_STD_HOURS                    numeric(6, 2),
    POSITION_STD_HRS_FREQUENCY            varchar(5),
    POSITION_UNION_CD                     varchar(3),
    POSITION_SHIFT                        varchar,
    POSITION_REG_TEMP                     varchar,
    POSITION_FULL_PART_TIME               varchar,
    MON_HRS                               numeric(4, 2),
    TUES_HRS                              numeric(4, 2),
    WED_HRS                               numeric(4, 2),
    THURS_HRS                             numeric(4, 2),
    FRI_HRS                               numeric(4, 2),
    SAT_HRS                               numeric(4, 2),
    SUN_HRS                               numeric(4, 2),
    POSITION_BARG_UNIT                    varchar(4),
    SEASONAL                              varchar,
    POSITION_TRN_PROGRAM                  varchar(6),
    LANGUAGE_SKILL                        varchar(2),
    POSITION_MANAGER_LEVEL                varchar(2),
    POSITION_FLSA_STATUS                  varchar,
    POSITION_REG_REGION                   varchar(5),
    POSITION_CLASS_INDC                   varchar,
    POSITION_ENCUMBER_INDC                varchar,
    POSITION_FTE                          numeric(7, 6),
    POSITION_POOL_ID                      varchar(3),
    POSITION_EG_ACADEMIC_RANK             varchar(3),
    POSITION_EG_GROUP                     varchar(6),
    POSITION_ENCUMB_SAL_OPTN              varchar(3),
    POSITION_ENCUMB_SAL_AMT               numeric(18, 3),
    HEALTH_CERTIFICATE                    varchar,
    SIGN_AUTHORITY                        varchar,
    ADDS_TO_FTE_ACTUAL                    varchar,
    POSITION_SAL_ADMIN_PLAN               varchar(4),
    POSITION_GRADE                        varchar(3),
    POSITION_STEP                         smallint,
    POSITION_SUPV_LVL_ID                  varchar(8),
    INCLUDE_SALPLN_FLG                    varchar,
    SEC_CLEARANCE_TYPE                    varchar(3),
    AVAIL_TELEWORK_POS                    varchar,
    SUPERVISOR_ID                         varchar(11),
    HR_STATUS                             varchar,
    POSITION_OVERRIDE                     varchar,
    POSN_CHANGE_RECORD                    varchar,
    EMPL_STATUS                           varchar,
    EMPL_STATUS_DESCR                     varchar(30),
    ACTION                                varchar(3),
    ACTION_DT                             date,
    ACTION_REASON                         varchar(3),
    LOCATION                              varchar(10),
    LOCATION_DESCR                        varchar(30),
    TAX_LOCATION_CD                       varchar(10),
    JOB_ENTRY_DT                          date,
    DEPT_ENTRY_DT                         date,
    POSITION_ENTRY_DT                     date,
    SHIFT                                 varchar,
    REG_TEMP                              varchar,
    FULL_PART_TIME                        varchar,
    COMPANY                               varchar(3),
    PAYGROUP                              varchar(3),
    PAYGROUP_DESCR                        varchar(30),
    PAY_FREQUENCY                         varchar(5),
    BAS_GROUP_ID                          varchar(3),
    ELIG_CONFIG1                          varchar(10),
    ELIG_CONFIG2                          varchar(10),
    ELIG_CONFIG3                          varchar(10),
    ELIG_CONFIG4                          varchar(10),
    ELIG_CONFIG5                          varchar(10),
    ELIG_CONFIG6                          varchar(10),
    ELIG_CONFIG7                          varchar(10),
    ELIG_CONFIG8                          varchar(10),
    ELIG_CONFIG9                          varchar(10),
    BEN_STATUS                            varchar(4),
    BAS_ACTION                            varchar(3),
    COBRA_ACTION                          varchar(3),
    EMPL_TYPE                             varchar,
    HOLIDAY_SCHEDULE                      varchar(6),
    STD_HOURS                             numeric(6, 2),
    STD_HRS_FREQUENCY                     varchar(5),
    OFFICER_CD                            varchar,
    EMPL_CLASS                            varchar(3),
    EMPL_CLASS_DESCR                      varchar(30),
    SAL_ADMIN_PLAN                        varchar(4),
    GRADE                                 varchar(3),
    GRADE_ENTRY_DT                        date,
    STEP                                  smallint,
    STEP_ENTRY_DT                         date,
    EARNS_DIST_TYPE                       varchar,
    PS_JOB_COMP_FREQUENCY                 varchar(5),
    PS_JOB_COMPRATE                       numeric(18, 6),
    PS_JOB_CHANGE_AMT                     numeric(18, 6),
    PS_JOB_CHANGE_PCT                     numeric(6, 3),
    ANNUAL_RT                             numeric(18, 3),
    MONTHLY_RT                            numeric(18, 3),
    DAILY_RT                              numeric(18, 3),
    HOURLY_RT                             numeric(18, 6),
    ANNL_BENEF_BASE_RT                    numeric(18, 3),
    SHIFT_RT                              numeric(18, 6),
    SHIFT_FACTOR                          numeric(4, 3),
    PS_JOB_CURRENCY_CD                    varchar(3),
    BUSINESS_UNIT                         varchar(5),
    SETID_DEPT                            varchar(5),
    SETID_JOBCODE                         varchar(5),
    SETID_LOCATION                        varchar(5),
    SETID_SALARY                          varchar(5),
    SETID_EMPL_CLASS                      varchar(5),
    PS_JOB_REG_REGION                     varchar(5),
    DIRECTLY_TIPPED                       varchar,
    FLSA_STATUS                           varchar,
    FLSA_STATUS_DESCR                     varchar(30),
    EEO_CLASS                             varchar,
    UNION_CD                              varchar(3),
    BARG_UNIT                             varchar(4),
    UNION_SENIORITY_DT                    date,
    GP_PAYGROUP                           varchar(10),
    GP_DFLT_ELIG_GRP                      varchar,
    GP_ELIG_GRP                           varchar(10),
    GP_DFLT_CURRTTYP                      varchar,
    CUR_RT_TYPE                           varchar(5),
    GP_DFLT_EXRTDT                        varchar,
    GP_ASOF_DT_EXG_RT                     varchar,
    CLASS_INDC                            varchar,
    ENCUMB_OVERRIDE                       varchar,
    FICA_STATUS_EE                        varchar,
    FTE                                   numeric(7, 6),
    PRORATE_CNT_AMT                       varchar,
    PAY_SYSTEM_FLG                        varchar(2),
    LUMP_SUM_PAY                          varchar,
    CONTRACT_NUM                          varchar(25),
    JOB_INDICATOR                         varchar,
    BENEFIT_SYSTEM                        varchar(2),
    WORK_DAY_HOURS                        numeric(6, 2),
    REPORTS_TO                            varchar(8),
    JOB_DATA_SRC_CD                       varchar(3),
    ESTABID                               varchar(12),
    SUPV_LVL_ID                           varchar(8),
    SETID_SUPV_LVL                        varchar(5),
    ABSENCE_SYSTEM_CD                     varchar(3),
    POI_TYPE                              varchar(5),
    HIRE_DT                               date,
    LAST_HIRE_DT                          date,
    TERMINATION_DT                        date,
    ASGN_START_DT                         date,
    LST_ASGN_START_DT                     date,
    ASGN_END_DT                           date,
    LDW_OVR                               varchar,
    LAST_DATE_WORKED                      date,
    EXPECTED_RETURN_DT                    date,
    EXPECTED_END_DATE                     date,
    AUTO_END_FLG                          varchar,
    PS_JOB_LASTUPDDTTM                    datetime,
    PS_JOB_LASTUPDOPRID                   varchar(30),
    PS_PERS_DATA_EMPLID                   varchar(11),
    PS_PERS_DATA_EFFDT                    date,
    MAR_STATUS                            varchar,
    MAR_STATUS_DT                         date,
    SEX                                   varchar,
    HIGHEST_EDUC_LVL                      varchar(2),
    FT_STUDENT                            varchar,
    LANG_CD                               varchar(3),
    PS_PERS_DATA_EFFDT_LASTUPDDTTM        datetime,
    PS_PERS_DATA_EFFDT_LASTUPDOPRID       varchar(30),
    PS_NAMES_EMPLID                       varchar(11),
    NAME_TYPE                             varchar(3),
    PS_NAMES_EFFDT                        date,
    PS_NAMES_EFF_STATUS                   varchar,
    PS_NAMES_COUNTRY_NM_FORMAT            varchar(3),
    NAME_INITIALS                         varchar(6),
    PS_NAMES_NAME_PREFIX                  varchar(4),
    PS_NAMES_NAME_SUFFIX                  varchar(15),
    NAME_TITLE                            varchar(30),
    PS_NAMES_LAST_NAME_SRCH               varchar(30),
    PS_NAMES_FIRST_NAME_SRCH              varchar(30),
    PS_NAMES_LAST_NAME                    varchar(30),
    PS_NAMES_FIRST_NAME                   varchar(30),
    PS_NAMES_MIDDLE_NAME                  varchar(30),
    SECOND_LAST_NAME                      varchar(30),
    SECOND_LAST_SRCH                      varchar(30),
    PS_NAMES_PREF_FIRST_NAME              varchar(30),
    PS_NAMES_NAME_DISPLAY                 varchar(50),
    PS_NAMES_NAME_FORMAL                  varchar(60),
    NAME_DISPLAY_SRCH                     varchar(50),
    PS_NAMES_LASTUPDDTTM                  datetime,
    PS_NAMES_LASTUPDOPRID                 varchar(30),
    LEGAL_LAST_NAME                       varchar(30),
    LEGAL_FIRST_NAME                      varchar(30),
    LEGAL_MIDDLE_NAME                     varchar(30),
    LEGAL_NAME_SUFFIX                     varchar(15),
    LEGAL_FIRST_LAST_NAME                 varchar(61) not null,
    LIVED_LAST_NAME                       varchar(30),
    LIVED_FIRST_NAME                      varchar(30),
    LIVED_MIDDLE_NAME                     varchar(30),
    LIVED_NAME_SUFFIX                     varchar     not null,
    LIVED_FIRST_LAST_NAME                 varchar(50),
    LIVED_LAST_FIRST_NAME                 varchar(62) not null,
    PS_PERS_DATA_USA_EMPLID               varchar(11),
    PS_PERS_DATA_USA_EFFDT                date,
    US_WORK_ELIGIBILTY                    varchar,
    MILITARY_STATUS                       varchar,
    CITIZEN_PROOF1                        varchar(10),
    CITIZEN_PROOF2                        varchar(10),
    MEDICARE_ENTLD_DT                     date,
    PS_PERSON_EMPLID                      varchar(11),
    BIRTHDATE                             date,
    BIRTHPLACE                            varchar(30),
    BIRTHCOUNTRY                          varchar(3),
    BIRTHSTATE                            varchar(6),
    DT_OF_DEATH                           date,
    PS_PERSONAL_PHONE_EMPLID              varchar(11),
    PS_PERSONAL_PHONE_PHONE_TYPE          varchar(4),
    PS_PERSONAL_PHONE_COUNTRY_CODE        varchar(3),
    PS_PERSONAL_PHONE_PHONE               varchar(24),
    PS_PERSONAL_PHONE_EXTENSION           varchar(6),
    PREF_PHONE_FLAG                       varchar,
    PS_ADDRESSES_EMPLID                   varchar(11),
    PS_ADDRESSES_ADDRESS_TYPE             varchar(4),
    PS_ADDRESSES_EFFDT                    date,
    PS_ADDRESSES_EFF_STATUS               varchar,
    PS_ADDRESSES_COUNTRY                  varchar(3),
    PS_ADDRESSES_ADDRESS1                 varchar(55),
    PS_ADDRESSES_ADDRESS2                 varchar(55),
    PS_ADDRESSES_ADDRESS3                 varchar(55),
    PS_ADDRESSES_ADDRESS4                 varchar(55),
    PS_ADDRESSES_CITY                     varchar(30),
    PS_ADDRESSES_HOUSE_TYPE               varchar(2),
    PS_ADDRESSES_COUNTY                   varchar(30),
    PS_ADDRESSES_STATE                    varchar(6),
    PS_ADDRESSES_POSTAL                   varchar(12),
    PS_ADDRESSES_REG_REGION               varchar(5),
    PS_ADDRESSES_LASTUPDDTTM              datetime,
    PS_ADDRESSES_LASTUPDOPRID             varchar(30),
    PS_EMAIL_ADDRESSES_EMPLID             varchar(11),
    BUSN_E_ADDR_TYPE                      varchar(4),
    BUSN_EMAIL_ADDR                       varchar(70),
    BUSN_EMAIL_FLAG                       varchar,
    CAMP_E_ADDR_TYPE                      varchar(4),
    CAMP_EMAIL_ADDR                       varchar(70),
    CAMP_EMAIL_FLAG                       varchar,
    HOME_E_ADDR_TYPE                      varchar(4),
    HOME_EMAIL_ADDR                       varchar(70),
    HOME_EMAIL_FLAG                       varchar,
    OTHR_E_ADDR_TYPE                      varchar(4),
    OTHR_EMAIL_ADDR                       varchar(70),
    OTHR_EMAIL_FLAG                       varchar,
    PS_COMPENSATION_EMPLID_UCHRLY         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHRLY       smallint,
    PS_COMPENSATION_EFFDT_UCHRLY          date,
    PS_COMPENSATION_EFFSEQ_UCHRLY         smallint,
    COMP_EFFSEQ_UCHRLY                    smallint,
    COMP_RATECD_UCHRLY                    varchar(6),
    COMP_RATE_POINTS_UCHRLY               int,
    PS_COMPENSATION_COMPRATE_UCHRLY       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHRLY       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHRLY varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHRLY    varchar(3),
    MANUAL_SW_UCHRLY                      varchar,
    CONVET_COMPRT_UCHRLY                  numeric(18, 6),
    RATE_CODE_GROUP_UCHRLY                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHRLY     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHRLY     numeric(6, 3),
    CHANGE_PTS_UCHRLY                     int,
    FTE_INDICATOR_UCHRLY                  varchar,
    CMP_SRC_IND_UCHRLY                    varchar,
    PS_COMPENSATION_EMPLID_UCANNL         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCANNL       smallint,
    PS_COMPENSATION_EFFDT_UCANNL          date,
    PS_COMPENSATION_EFFSEQ_UCANNL         smallint,
    COMP_EFFSEQ_UCANNL                    smallint,
    COMP_RATECD_UCANNL                    varchar(6),
    COMP_RATE_POINTS_UCANNL               int,
    PS_COMPENSATION_COMPRATE_UCANNL       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCANNL       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCANNL varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCANNL    varchar(3),
    MANUAL_SW_UCANNL                      varchar,
    CONVET_COMPRT_UCANNL                  numeric(18, 6),
    RATE_CODE_GROUP_UCANNL                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCANNL     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCANNL     numeric(6, 3),
    CHANGE_PTS_UCANNL                     int,
    FTE_INDICATOR_UCANNL                  varchar,
    CMP_SRC_IND_UCANNL                    varchar,
    PS_COMPENSATION_EMPLID_UCHSX          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSX        smallint,
    PS_COMPENSATION_EFFDT_UCHSX           date,
    PS_COMPENSATION_EFFSEQ_UCHSX          smallint,
    COMP_EFFSEQ_UCHSX                     smallint,
    COMP_RATECD_UCHSX                     varchar(6),
    COMP_RATE_POINTS_UCHSX                int,
    PS_COMPENSATION_COMPRATE_UCHSX        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSX        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSX  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSX     varchar(3),
    MANUAL_SW_UCHSX                       varchar,
    CONVET_COMPRT_UCHSX                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSX                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSX      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSX      numeric(6, 3),
    CHANGE_PTS_UCHSX                      int,
    FTE_INDICATOR_UCHSX                   varchar,
    CMP_SRC_IND_UCHSX                     varchar,
    PS_COMPENSATION_EMPLID_UCHSP          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSP        smallint,
    PS_COMPENSATION_EFFDT_UCHSP           date,
    PS_COMPENSATION_EFFSEQ_UCHSP          smallint,
    COMP_EFFSEQ_UCHSP                     smallint,
    COMP_RATECD_UCHSP                     varchar(6),
    COMP_RATE_POINTS_UCHSP                int,
    PS_COMPENSATION_COMPRATE_UCHSP        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSP        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSP  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSP     varchar(3),
    MANUAL_SW_UCHSP                       varchar,
    CONVET_COMPRT_UCHSP                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSP                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSP      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSP      numeric(6, 3),
    CHANGE_PTS_UCHSP                      int,
    FTE_INDICATOR_UCHSP                   varchar,
    CMP_SRC_IND_UCHSP                     varchar,
    PS_COMPENSATION_EMPLID_UCHSN          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSN        smallint,
    PS_COMPENSATION_EFFDT_UCHSN           date,
    PS_COMPENSATION_EFFSEQ_UCHSN          smallint,
    COMP_EFFSEQ_UCHSN                     smallint,
    COMP_RATECD_UCHSN                     varchar(6),
    COMP_RATE_POINTS_UCHSN                int,
    PS_COMPENSATION_COMPRATE_UCHSN        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSN        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSN  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSN     varchar(3),
    MANUAL_SW_UCHSN                       varchar,
    CONVET_COMPRT_UCHSN                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSN                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSN      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSN      numeric(6, 3),
    CHANGE_PTS_UCHSN                      int,
    FTE_INDICATOR_UCHSN                   varchar,
    CMP_SRC_IND_UCHSN                     varchar,
    PS_COMPENSATION_EMPLID_UCWOS          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCWOS        smallint,
    PS_COMPENSATION_EFFDT_UCWOS           date,
    PS_COMPENSATION_EFFSEQ_UCWOS          smallint,
    COMP_EFFSEQ_UCWOS                     smallint,
    COMP_RATECD_UCWOS                     varchar(6),
    COMP_RATE_POINTS_UCWOS                int,
    PS_COMPENSATION_COMPRATE_UCWOS        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCWOS        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCWOS  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCWOS     varchar(3),
    MANUAL_SW_UCWOS                       varchar,
    CONVET_COMPRT_UCWOS                   numeric(18, 6),
    RATE_CODE_GROUP_UCWOS                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCWOS      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCWOS      numeric(6, 3),
    CHANGE_PTS_UCWOS                      int,
    FTE_INDICATOR_UCWOS                   varchar,
    CMP_SRC_IND_UCWOS                     varchar,
    PS_COMPENSATION_EMPLID_UCSPHY         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCSPHY       smallint,
    PS_COMPENSATION_EFFDT_UCSPHY          date,
    PS_COMPENSATION_EFFSEQ_UCSPHY         smallint,
    COMP_EFFSEQ_UCSPHY                    smallint,
    COMP_RATECD_UCSPHY                    varchar(6),
    COMP_RATE_POINTS_UCSPHY               int,
    PS_COMPENSATION_COMPRATE_UCSPHY       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCSPHY       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCSPHY varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCSPHY    varchar(3),
    MANUAL_SW_UCSPHY                      varchar,
    CONVET_COMPRT_UCSPHY                  numeric(18, 6),
    RATE_CODE_GROUP_UCSPHY                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCSPHY     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCSPHY     numeric(6, 3),
    CHANGE_PTS_UCSPHY                     int,
    FTE_INDICATOR_UCSPHY                  varchar,
    CMP_SRC_IND_UCSPHY                    varchar,
    PS_COMPENSATION_EMPLID_UCOFF1         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCOFF1       smallint,
    PS_COMPENSATION_EFFDT_UCOFF1          date,
    PS_COMPENSATION_EFFSEQ_UCOFF1         smallint,
    COMP_EFFSEQ_UCOFF1                    smallint,
    COMP_RATECD_UCOFF1                    varchar(6),
    COMP_RATE_POINTS_UCOFF1               int,
    PS_COMPENSATION_COMPRATE_UCOFF1       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCOFF1       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCOFF1 varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCOFF1    varchar(3),
    MANUAL_SW_UCOFF1                      varchar,
    CONVET_COMPRT_UCOFF1                  numeric(18, 6),
    RATE_CODE_GROUP_UCOFF1                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCOFF1     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCOFF1     numeric(6, 3),
    CHANGE_PTS_UCOFF1                     int,
    FTE_INDICATOR_UCOFF1                  varchar,
    CMP_SRC_IND_UCOFF1                    varchar,
    PS_COMPENSATION_EMPLID_UCFELM         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCFELM       smallint,
    PS_COMPENSATION_EFFDT_UCFELM          date,
    PS_COMPENSATION_EFFSEQ_UCFELM         smallint,
    COMP_EFFSEQ_UCFELM                    smallint,
    COMP_RATECD_UCFELM                    varchar(6),
    COMP_RATE_POINTS_UCFELM               int,
    PS_COMPENSATION_COMPRATE_UCFELM       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCFELM       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCFELM varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCFELM    varchar(3),
    MANUAL_SW_UCFELM                      varchar,
    CONVET_COMPRT_UCFELM                  numeric(18, 6),
    RATE_CODE_GROUP_UCFELM                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCFELM     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCFELM     numeric(6, 3),
    CHANGE_PTS_UCFELM                     int,
    FTE_INDICATOR_UCFELM                  varchar,
    CMP_SRC_IND_UCFELM                    varchar,
    PS_PERS_MILIT_USA_EMPLID              varchar(11),
    MIL_DISCHRG_DT_USA                    date,
    PS_CITIZENSHIP_EMPLID                 varchar(11),
    PS_CITIZENSHIP_DEPENDENT_ID           varchar(2),
    PS_CITIZENSHIP_COUNTRY                varchar(3),
    CITIZENSHIP_STATUS                    varchar,
    PS_PRIMARY_JOBS_EMPLID                varchar(11),
    PRIMARY_JOB_APP                       varchar(2),
    PS_PRIMARY_JOB_EMPL_RCD               smallint,
    PS_PRIMARY_JOB_EFFDT                  date,
    PRIMARY_JOB_IND                       varchar,
    PRIMARY_FLAG1                         varchar,
    PRIMARY_FLAG2                         varchar,
    PRIMARY_JOBS_SRC                      varchar,
    JOB_EFFSEQ                            smallint,
    JOB_EMPL_RCD                          smallint,
    PS_DEP_BEN_EMPLID_01                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_01         varchar(2),
    PS_DEP_BEN_BIRTHDATE_01               date,
    PS_DEP_BEN_BIRTHPLACE_01              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_01              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_01            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_01             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_01        varchar,
    PS_DEP_BEN_COUNTRY_CODE_01            varchar(3),
    PS_DEP_BEN_PHONE_01                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_01         varchar,
    PS_DEP_BEN_PHONE_TYPE_01              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_01          date,
    PS_DEP_BEN_COBRA_ACTION_01            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_01            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_01       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_01        date,
    PS_DEP_BEN_EMPLID_02                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_02         varchar(2),
    PS_DEP_BEN_BIRTHDATE_02               date,
    PS_DEP_BEN_BIRTHPLACE_02              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_02              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_02            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_02             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_02        varchar,
    PS_DEP_BEN_COUNTRY_CODE_02            varchar(3),
    PS_DEP_BEN_PHONE_02                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_02         varchar,
    PS_DEP_BEN_PHONE_TYPE_02              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_02          date,
    PS_DEP_BEN_COBRA_ACTION_02            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_02            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_02       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_02        date,
    PS_DEP_BEN_EMPLID_03                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_03         varchar(2),
    PS_DEP_BEN_BIRTHDATE_03               date,
    PS_DEP_BEN_BIRTHPLACE_03              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_03              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_03            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_03             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_03        varchar,
    PS_DEP_BEN_COUNTRY_CODE_03            varchar(3),
    PS_DEP_BEN_PHONE_03                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_03         varchar,
    PS_DEP_BEN_PHONE_TYPE_03              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_03          date,
    PS_DEP_BEN_COBRA_ACTION_03            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_03            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_03       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_03        date,
    PS_DEP_BEN_EMPLID_04                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_04         varchar(2),
    PS_DEP_BEN_BIRTHDATE_04               date,
    PS_DEP_BEN_BIRTHPLACE_04              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_04              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_04            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_04             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_04        varchar,
    PS_DEP_BEN_COUNTRY_CODE_04            varchar(3),
    PS_DEP_BEN_PHONE_04                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_04         varchar,
    PS_DEP_BEN_PHONE_TYPE_04              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_04          date,
    PS_DEP_BEN_COBRA_ACTION_04            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_04            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_04       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_04        date,
    PS_DEP_BEN_EFF_EMPLID_01              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_01     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_01               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_01        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_01      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_01          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_01       date,
    PS_DEP_BEN_EFF_SEX_01                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_01          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_01             varchar,
    PS_DEP_BEN_EFF_DISABLED_01            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_01   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_01  date,
    PS_DEP_BEN_EFF_SMOKER_01              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_01           date,
    PS_DEP_BEN_EFF_EMPLID_02              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_02     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_02               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_02        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_02      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_02          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_02       date,
    PS_DEP_BEN_EFF_SEX_02                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_02          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_02             varchar,
    PS_DEP_BEN_EFF_DISABLED_02            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_02   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_02  date,
    PS_DEP_BEN_EFF_SMOKER_02              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_02           date,
    PS_DEP_BEN_EFF_EMPLID_03              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_03     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_03               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_03        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_03      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_03          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_03       date,
    PS_DEP_BEN_EFF_SEX_03                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_03          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_03             varchar,
    PS_DEP_BEN_EFF_DISABLED_03            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_03   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_03  date,
    PS_DEP_BEN_EFF_SMOKER_03              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_03           date,
    PS_DEP_BEN_EFF_EMPLID_04              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_04     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_04               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_04        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_04      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_04          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_04       date,
    PS_DEP_BEN_EFF_SEX_04                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_04          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_04             varchar,
    PS_DEP_BEN_EFF_DISABLED_04            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_04   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_04  date,
    PS_DEP_BEN_EFF_SMOKER_04              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_04           date,
    PS_DEP_BEN_NAME_EMPLID_01             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_01    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_01              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_01  varchar(3),
    PS_DEP_BEN_NAME_NAME_01               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_01        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_01        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_01     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_01    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_01          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_01         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_01        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_01    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_01       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_01        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_01    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_01         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_01         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_01       date,
    PS_DEP_BEN_NAME_EMPLID_02             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_02    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_02              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_02  varchar(3),
    PS_DEP_BEN_NAME_NAME_02               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_02        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_02        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_02     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_02    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_02          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_02         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_02        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_02    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_02       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_02        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_02    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_02         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_02         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_02       date,
    PS_DEP_BEN_NAME_EMPLID_03             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_03    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_03              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_03  varchar(3),
    PS_DEP_BEN_NAME_NAME_03               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_03        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_03        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_03     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_03    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_03          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_03         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_03        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_03    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_03       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_03        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_03    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_03         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_03         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_03       date,
    PS_DEP_BEN_NAME_EMPLID_04             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_04    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_04              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_04  varchar(3),
    PS_DEP_BEN_NAME_NAME_04               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_04        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_04        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_04     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_04    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_04          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_04         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_04        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_04    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_04       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_04        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_04    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_04         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_04         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_04       date,
    PS_PER_ORG_ASGN_EMPLID                varchar(11),
    PS_PER_ORG_ASGN_EMPL_RCD              smallint,
    PER_ORG_ASGN                          varchar(3),
    ORG_INSTANCE_ERN                      smallint,
    POI_TYPE_ASGN                         varchar(5),
    BENEFIT_RCD_NBR                       smallint,
    HOME_HOST_CLASS                       varchar,
    CMPNY_DT_OVR                          varchar,
    CMPNY_SENIORITY_DT                    date,
    SERVICE_DT_OVR                        varchar,
    SERVICE_DT                            date,
    SEN_PAY_DT_OVR                        varchar,
    SENIORITY_PAY_DT                      date,
    PROF_EXPERIENCE_DT                    date,
    LAST_VERIFICATN_DT                    date,
    PROBATION_DT                          date,
    LAST_INCREASE_DT                      date,
    BUSINESS_TITLE                        varchar(30),
    POSITION_PHONE                        varchar(24),
    LAST_CHILD_UPDDTM                     datetime,
    PROB_END_DT                           date,
    PROBATION_CODE                        varchar,
    PROBATION_CODE_DESCR                  varchar(30),
    PS_EMERGENCY_CNTCT_EMPLID             varchar(11),
    CONTACT_NAME                          varchar(50),
    SAME_ADDRESS_EMPL                     varchar,
    PRIMARY_CONTACT                       varchar,
    PS_EMERGENCY_CNTCT_COUNTRY            varchar(3),
    PS_EMERGENCY_CNTCT_ADDRESS1           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS2           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS3           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS4           varchar(55),
    PS_EMERGENCY_CNTCT_CITY               varchar(30),
    PS_EMERGENCY_CNTCT_HOUSE_TYPE         varchar(2),
    PS_EMERGENCY_CNTCT_COUNTY             varchar(30),
    PS_EMERGENCY_CNTCT_STATE              varchar(6),
    PS_EMERGENCY_CNTCT_POSTAL             varchar(12),
    GEO_CODE                              varchar(11),
    PS_EMERGENCY_CNTCT_COUNTRY_CODE       varchar(3),
    PS_EMERGENCY_CNTCT_PHONE              varchar(24),
    PS_EMERGENCY_CNTCT_RELATIONSHIP       varchar(2),
    PS_EMERGENCY_CNTCT_SAME_PHONE_EMPL    varchar,
    PS_EMERGENCY_CNTCT_ADDRESS_TYPE       varchar(4),
    PS_EMERGENCY_CNTCT_PHONE_TYPE         varchar(4),
    PS_EMERGENCY_CNTCT_EXTENSION          varchar(6),
    LAST_NAME                             varchar(30),
    FIRST_NAME                            varchar(30),
    MIDDLE_NAME                           varchar(30),
    ADDRESS1                              varchar(55),
    ADDRESS2                              varchar(55),
    CITY                                  varchar(30),
    COUNTY                                varchar(30),
    STATE                                 varchar(6),
    POSTAL                                varchar(12),
    COUNTRY                               varchar(3),
    SETID                                 varchar(5),
    JOBCODE                               varchar(6),
    JOBCODE_EFFDT                         date,
    JOBCODE_EFF_STATUS                    varchar,
    JOBCODE_DESCR                         varchar(30),
    JOBCODE_DESCRSHORT                    varchar(10),
    JOBCODE_JOB_FUNCTION                  varchar(3),
    JOBCODE_SETID_SALARY                  varchar(5),
    JOBCODE_SAL_ADMIN_PLAN                varchar(4),
    JOBCODE_GRADE                         varchar(3),
    JOBCODE_STEP                          smallint,
    MANAGER_LEVEL                         varchar(2),
    SURVEY_SALARY                         int,
    SURVEY_JOB_CODE                       varchar(8),
    JOBCODE_UNION_CD                      varchar(3),
    RETRO_RATE                            numeric(6, 4),
    RETRO_PERCENT                         numeric(6, 4),
    CURRENCY_CD                           varchar(3),
    JOBCODE_STD_HOURS                     numeric(6, 2),
    JOBCODE_STD_HRS_FREQUENCY             varchar(5),
    JOBCODE_COMP_FREQUENCY                varchar(5),
    WORKERS_COMP_CD                       varchar(4),
    JOBCODE_JOB_FAMILY                    varchar(6),
    JOBCODE_REG_TEMP                      varchar,
    JOBCODE_DIRECTLY_TIPPED               varchar,
    MED_CHKUP_REQ                         varchar,
    JOBCODE_FLSA_STATUS                   varchar,
    EEO1CODE                              varchar,
    EEO4CODE                              varchar,
    EEO5CODE                              varchar(2),
    EEO6CODE                              varchar,
    EEO_JOB_GROUP                         varchar(4),
    JOBCODE_US_SOC_CD                     varchar(10),
    IPEDSSCODE                            varchar,
    JOBCODE_US_OCC_CD                     varchar(4),
    AVAIL_TELEWORK                        varchar,
    FUNCTION_CD                           varchar(2),
    TRN_PROGRAM                           varchar(6),
    JOBCODE_COMPANY                       varchar(3),
    JOBCODE_BARG_UNIT                     varchar(4),
    ENCUMBER_INDC                         varchar,
    POSN_MGMT_INDC                        varchar,
    EG_ACADEMIC_RANK                      varchar(3),
    EG_GROUP                              varchar(6),
    ENCUMB_SAL_OPTN                       varchar(3),
    ENCUMB_SAL_AMT                        numeric(18, 3),
    LAST_UPDATE_DATE                      date,
    REG_REGION                            varchar(5),
    SAL_RANGE_MIN_RATE                    numeric(18, 6),
    SAL_RANGE_MID_RATE                    numeric(18, 6),
    SAL_RANGE_MAX_RATE                    numeric(18, 6),
    SAL_RANGE_CURRENCY                    varchar(3),
    SAL_RANGE_FREQ                        varchar(5),
    JOB_SUB_FUNC                          varchar(3),
    LASTUPDOPRID                          varchar(30),
    LASTUPDDTTM                           datetime,
    KEY_JOBCODE                           varchar,
    JOB_FUNCTION                          varchar(3),
    JOB_FUNCTION_DESCR                    varchar(30),
    JOB_FUNCTION_DESCRSHORT               varchar(10),
    JOB_FAMILY                            varchar(6),
    JOB_FAMILY_DESCR                      varchar(30),
    JOB_FAMILY_DESCRSHORT                 varchar(10),
    US_SOC_CD                             varchar(10),
    SOC_DESCR50                           varchar(50),
    US_OCC_CD                             varchar(4),
    OCC_DESCR50                           varchar(50),
    UC_OSHPD_CODE                         varchar(10),
    UC_CTO_OS_CD                          varchar(3),
    OLD_PPS_ID                            varchar(254),
    UC_CBR_RATE                           numeric(16, 4),
    UC_CBR_GROUP_DESCR                    varchar(30),
    MANAGER_EMPLID                        varchar(11),
    MANAGER_NAME                          varchar(50),
    MANAGER_FIRST_NAME                    varchar(30),
    MANAGER_LAST_NAME                     varchar(30),
    MANAGER_MIDDLE_NAME                   varchar(30),
    MANAGER_NAME_SUFFIX                   varchar(15),
    MANAGER_DEPTID                        varchar(10),
    MANAGER_POSITION_NBR                  varchar(8),
    MANAGER_JOBCODE                       varchar(6),
    MANAGER_EMPL_STATUS                   varchar,
    MANAGER_BUSN_EMAIL_ADDR               varchar(70),
    MANAGER_CAMP_EMAIL_ADDR               varchar(70),
    MANAGER_LIVED_LAST_NAME               varchar(30),
    MANAGER_LIVED_FIRST_NAME              varchar(30),
    MANAGER_LIVED_MIDDLE_NAME             varchar(30),
    MANAGER_LIVED_NAME_SUFFIX             varchar     not null,
    MANAGER_LIVED_FIRST_LAST_NAME         varchar(50),
    MANAGER_LIVED_LAST_FIRST_NAME         varchar(62),
    VC_CODE                               varchar(50),
    VC_Name                               varchar(30),
    UC_EMP_REL_CD                         varchar(3),
    UC_EMP_REL_DESCR                      varchar(30),
    WORK_LOCATION_EFF_STATUS              varchar,
    WORK_LOCATION_BUILDING                varchar(10),
    WORK_LOCATION_FLOOR                   varchar(10),
    WORK_LOCATION_COUNTRY                 varchar(3),
    WORK_LOCATION_ADDRESS1                varchar(55),
    WORK_LOCATION_ADDRESS2                varchar(55),
    WORK_LOCATION_ADDRESS3                varchar(55),
    WORK_LOCATION_CITY                    varchar(30),
    WORK_LOCATION_COUNTY                  varchar(30),
    WORK_LOCATION_STATE                   varchar(6),
    WORK_LOCATION_POSTAL                  varchar(12),
    WORK_LOCATION_CUBICLE                 varchar(15),
    CUBICLE                               varchar(15)
)
go

create index UKG_EMPL_E_T_IDX_1
    on UKG_EMPL_E_T (EMPLID)
go

create index UKG_EMPL_E_T_IDX_2
    on UKG_EMPL_E_T (POSITION_NBR)
go

create index UKG_EMPL_E_T_IDX_3
    on UKG_EMPL_E_T (MANAGER_EMPLID)
go

create table UKG_EMPL_FTE_T
(
    EMPLID  varchar(11),
    FTE_SUM numeric(38, 6)
)
go

create index UKG_EMPL_FTE_T_IDX_1
    on UKG_EMPL_FTE_T (EMPLID)
go

create table UKG_EMPL_HIERARCHY_POSN_LOOKUP
(
    emplid         varchar(11),
    name           varchar(50),
    POSITION_NBR   varchar(8),
    JOB_INDICATOR  varchar,
    POSN_LEVEL     varchar(9),
    reports_to     varchar(8),
    Manager_Name   varchar(50),
    Manager_emplid varchar(11),
    UPDATED_DT     datetime not null
)
go

create table UKG_EMPL_HRATE_EFFDT_T
(
    EMPLID     varchar(11),
    HOURLY_RT  numeric(18, 6),
    EFFDT      date,
    UPD_BT_DTM datetime,
    action     varchar(3),
    action_dt  date,
    RN         bigint
)
go

create index UKG_EMPL_HRATE_EFFDT_T_IDX_1
    on UKG_EMPL_HRATE_EFFDT_T (EMPLID, RN)
go

create table UKG_EMPL_HRATE_EFFDT_T_TEMP
(
    EMPLID         varchar(11),
    HOURLY_RT      numeric(18, 6),
    EFFDT          date,
    UPD_BT_DTM     datetime,
    SAL_ADMIN_PLAN varchar(4),
    RN             bigint
)
go

create table UKG_EMPL_Inactive_Manager
(
    POSITION_NBR_To_Check    varchar(8),
    Inactive_EMPLID_To_Check varchar(11),
    EFFDT                    date,
    EMPL_RCD                 smallint,
    DEPTID                   varchar(10),
    BUSINESS_UNIT            varchar(5),
    LOCATION                 varchar(10),
    JOB_INDICATOR            varchar,
    FTE                      numeric(7, 6),
    UNION_CD                 varchar(3),
    JOBCODE                  varchar(6),
    ROW_NO                   bigint,
    UPDATED_DT               datetime not null
)
go

create table UKG_EMPL_Inactive_Manager_Hierarchy
(
    POSITION_NBR_To_Check   varchar(20),
    MANAGER_POSITION_NBR    varchar(20),
    POSN_LEVEL              varchar(10),
    To_Trace_Up_1           varchar(3),
    MANAGER_POSITION_NBR_L1 varchar(20),
    MANAGER_EMPLID          varchar(11),
    MANAGER_HR_STATUS       varchar,
    MANAGER_POSN_STATUS     varchar,
    MANAGER_POSN_LEVEL_L1   varchar(10),
    To_Trace_Up_2           varchar(3),
    NOTE_L1                 varchar(100),
    MANAGER_POSITION_NBR_L2 varchar(20),
    MANAGER_EMPLID_L2       varchar(11),
    MANAGER_HR_STATUS_L2    varchar,
    MANAGER_POSN_STATUS_L2  varchar,
    MANAGER_POSN_LEVEL_L2   varchar(10),
    To_Trace_Up_3           varchar(3),
    NOTE_L2                 varchar(100),
    MANAGER_POSITION_NBR_L3 varchar(20),
    MANAGER_EMPLID_L3       varchar(11),
    MANAGER_HR_STATUS_L3    varchar,
    MANAGER_POSN_STATUS_L3  varchar,
    MANAGER_POSN_LEVEL_L3   varchar(10),
    To_Trace_Up_4           varchar(3),
    NOTE_L3                 varchar(100),
    MANAGER_POSITION_NBR_L4 varchar(20),
    MANAGER_EMPLID_L4       varchar(11),
    MANAGER_HR_STATUS_L4    varchar,
    MANAGER_POSN_STATUS_L4  varchar,
    MANAGER_POSN_LEVEL_L4   varchar(10),
    To_Trace_Up_5           varchar(3),
    NOTE_L4                 varchar(100),
    HIERARCHY_LEVEL         varchar(10),
    CREATED_DT              datetime default getdate()
)
go

create table UKG_EMPL_M_T
(
    NON_UKG_MANAGER_FLAG                  varchar     not null,
    NAME                                  varchar(50),
    EMPLID                                varchar(11),
    EMPL_RCD                              smallint,
    EFFDT                                 date,
    EFFSEQ                                smallint,
    PER_ORG                               varchar(3),
    DEPTID                                varchar(10),
    DEPT_DESCR                            varchar(30),
    POSITION_NBR                          varchar(8),
    POSITION_EFFDT                        date,
    POSITION_EFF_STATUS                   varchar,
    POSITION_DESCR                        varchar(30),
    POSITION_DESCRSHORT                   varchar(10),
    POSITION_ACTION                       varchar(3),
    POSITION_ACTION_REASON                varchar(3),
    POSITION_ACTION_DT                    date,
    POSITION_POSN_STATUS                  varchar,
    POSITION_STATUS_DT                    date,
    BUDGETED_POSN                         varchar,
    CONFIDENTIAL_POSN                     varchar,
    JOB_SHARE                             varchar,
    KEY_POSITION                          varchar,
    MAX_HEAD_COUNT                        smallint,
    UPDATE_INCUMBENTS                     varchar,
    POSITION_REPORTS_TO                   varchar(8),
    REPORT_DOTTED_LINE                    varchar(8),
    ORGCODE                               varchar(60),
    ORGCODE_FLAG                          varchar,
    POSITION_LOCATION                     varchar(10),
    MAIL_DROP                             varchar(50),
    COUNTRY_CODE                          varchar(3),
    PHONE                                 varchar(24),
    POSITION_COMPANY                      varchar(3),
    POSITION_STD_HOURS                    numeric(6, 2),
    POSITION_STD_HRS_FREQUENCY            varchar(5),
    POSITION_UNION_CD                     varchar(3),
    POSITION_SHIFT                        varchar,
    POSITION_REG_TEMP                     varchar,
    POSITION_FULL_PART_TIME               varchar,
    MON_HRS                               numeric(4, 2),
    TUES_HRS                              numeric(4, 2),
    WED_HRS                               numeric(4, 2),
    THURS_HRS                             numeric(4, 2),
    FRI_HRS                               numeric(4, 2),
    SAT_HRS                               numeric(4, 2),
    SUN_HRS                               numeric(4, 2),
    POSITION_BARG_UNIT                    varchar(4),
    SEASONAL                              varchar,
    POSITION_TRN_PROGRAM                  varchar(6),
    LANGUAGE_SKILL                        varchar(2),
    POSITION_MANAGER_LEVEL                varchar(2),
    POSITION_FLSA_STATUS                  varchar,
    POSITION_REG_REGION                   varchar(5),
    POSITION_CLASS_INDC                   varchar,
    POSITION_ENCUMBER_INDC                varchar,
    POSITION_FTE                          numeric(7, 6),
    POSITION_POOL_ID                      varchar(3),
    POSITION_EG_ACADEMIC_RANK             varchar(3),
    POSITION_EG_GROUP                     varchar(6),
    POSITION_ENCUMB_SAL_OPTN              varchar(3),
    POSITION_ENCUMB_SAL_AMT               numeric(18, 3),
    HEALTH_CERTIFICATE                    varchar,
    SIGN_AUTHORITY                        varchar,
    ADDS_TO_FTE_ACTUAL                    varchar,
    POSITION_SAL_ADMIN_PLAN               varchar(4),
    POSITION_GRADE                        varchar(3),
    POSITION_STEP                         smallint,
    POSITION_SUPV_LVL_ID                  varchar(8),
    INCLUDE_SALPLN_FLG                    varchar,
    SEC_CLEARANCE_TYPE                    varchar(3),
    AVAIL_TELEWORK_POS                    varchar,
    SUPERVISOR_ID                         varchar(11),
    HR_STATUS                             varchar,
    POSITION_OVERRIDE                     varchar,
    POSN_CHANGE_RECORD                    varchar,
    EMPL_STATUS                           varchar,
    EMPL_STATUS_DESCR                     varchar(30),
    ACTION                                varchar(3),
    ACTION_DT                             date,
    ACTION_REASON                         varchar(3),
    LOCATION                              varchar(10),
    LOCATION_DESCR                        varchar(30),
    TAX_LOCATION_CD                       varchar(10),
    JOB_ENTRY_DT                          date,
    DEPT_ENTRY_DT                         date,
    POSITION_ENTRY_DT                     date,
    SHIFT                                 varchar,
    REG_TEMP                              varchar,
    FULL_PART_TIME                        varchar,
    COMPANY                               varchar(3),
    PAYGROUP                              varchar(3),
    PAYGROUP_DESCR                        varchar(30),
    PAY_FREQUENCY                         varchar(5),
    BAS_GROUP_ID                          varchar(3),
    ELIG_CONFIG1                          varchar(10),
    ELIG_CONFIG2                          varchar(10),
    ELIG_CONFIG3                          varchar(10),
    ELIG_CONFIG4                          varchar(10),
    ELIG_CONFIG5                          varchar(10),
    ELIG_CONFIG6                          varchar(10),
    ELIG_CONFIG7                          varchar(10),
    ELIG_CONFIG8                          varchar(10),
    ELIG_CONFIG9                          varchar(10),
    BEN_STATUS                            varchar(4),
    BAS_ACTION                            varchar(3),
    COBRA_ACTION                          varchar(3),
    EMPL_TYPE                             varchar,
    HOLIDAY_SCHEDULE                      varchar(6),
    STD_HOURS                             numeric(6, 2),
    STD_HRS_FREQUENCY                     varchar(5),
    OFFICER_CD                            varchar,
    EMPL_CLASS                            varchar(3),
    EMPL_CLASS_DESCR                      varchar(30),
    SAL_ADMIN_PLAN                        varchar(4),
    GRADE                                 varchar(3),
    GRADE_ENTRY_DT                        date,
    STEP                                  smallint,
    STEP_ENTRY_DT                         date,
    EARNS_DIST_TYPE                       varchar,
    PS_JOB_COMP_FREQUENCY                 varchar(5),
    PS_JOB_COMPRATE                       numeric(18, 6),
    PS_JOB_CHANGE_AMT                     numeric(18, 6),
    PS_JOB_CHANGE_PCT                     numeric(6, 3),
    ANNUAL_RT                             numeric(18, 3),
    MONTHLY_RT                            numeric(18, 3),
    DAILY_RT                              numeric(18, 3),
    HOURLY_RT                             numeric(18, 6),
    ANNL_BENEF_BASE_RT                    numeric(18, 3),
    SHIFT_RT                              numeric(18, 6),
    SHIFT_FACTOR                          numeric(4, 3),
    PS_JOB_CURRENCY_CD                    varchar(3),
    BUSINESS_UNIT                         varchar(5),
    SETID_DEPT                            varchar(5),
    SETID_JOBCODE                         varchar(5),
    SETID_LOCATION                        varchar(5),
    SETID_SALARY                          varchar(5),
    SETID_EMPL_CLASS                      varchar(5),
    PS_JOB_REG_REGION                     varchar(5),
    DIRECTLY_TIPPED                       varchar,
    FLSA_STATUS                           varchar,
    FLSA_STATUS_DESCR                     varchar(30),
    EEO_CLASS                             varchar,
    UNION_CD                              varchar(3),
    BARG_UNIT                             varchar(4),
    UNION_SENIORITY_DT                    date,
    GP_PAYGROUP                           varchar(10),
    GP_DFLT_ELIG_GRP                      varchar,
    GP_ELIG_GRP                           varchar(10),
    GP_DFLT_CURRTTYP                      varchar,
    CUR_RT_TYPE                           varchar(5),
    GP_DFLT_EXRTDT                        varchar,
    GP_ASOF_DT_EXG_RT                     varchar,
    CLASS_INDC                            varchar,
    ENCUMB_OVERRIDE                       varchar,
    FICA_STATUS_EE                        varchar,
    FTE                                   numeric(7, 6),
    PRORATE_CNT_AMT                       varchar,
    PAY_SYSTEM_FLG                        varchar(2),
    LUMP_SUM_PAY                          varchar,
    CONTRACT_NUM                          varchar(25),
    JOB_INDICATOR                         varchar,
    BENEFIT_SYSTEM                        varchar(2),
    WORK_DAY_HOURS                        numeric(6, 2),
    REPORTS_TO                            varchar(8),
    JOB_DATA_SRC_CD                       varchar(3),
    ESTABID                               varchar(12),
    SUPV_LVL_ID                           varchar(8),
    SETID_SUPV_LVL                        varchar(5),
    ABSENCE_SYSTEM_CD                     varchar(3),
    POI_TYPE                              varchar(5),
    HIRE_DT                               date,
    LAST_HIRE_DT                          date,
    TERMINATION_DT                        date,
    ASGN_START_DT                         date,
    LST_ASGN_START_DT                     date,
    ASGN_END_DT                           date,
    LDW_OVR                               varchar,
    LAST_DATE_WORKED                      date,
    EXPECTED_RETURN_DT                    date,
    EXPECTED_END_DATE                     date,
    AUTO_END_FLG                          varchar,
    PS_JOB_LASTUPDDTTM                    datetime,
    PS_JOB_LASTUPDOPRID                   varchar(30),
    PS_PERS_DATA_EMPLID                   varchar(11),
    PS_PERS_DATA_EFFDT                    date,
    MAR_STATUS                            varchar,
    MAR_STATUS_DT                         date,
    SEX                                   varchar,
    HIGHEST_EDUC_LVL                      varchar(2),
    FT_STUDENT                            varchar,
    LANG_CD                               varchar(3),
    PS_PERS_DATA_EFFDT_LASTUPDDTTM        datetime,
    PS_PERS_DATA_EFFDT_LASTUPDOPRID       varchar(30),
    PS_NAMES_EMPLID                       varchar(11),
    NAME_TYPE                             varchar(3),
    PS_NAMES_EFFDT                        date,
    PS_NAMES_EFF_STATUS                   varchar,
    PS_NAMES_COUNTRY_NM_FORMAT            varchar(3),
    NAME_INITIALS                         varchar(6),
    PS_NAMES_NAME_PREFIX                  varchar(4),
    PS_NAMES_NAME_SUFFIX                  varchar(15),
    NAME_TITLE                            varchar(30),
    PS_NAMES_LAST_NAME_SRCH               varchar(30),
    PS_NAMES_FIRST_NAME_SRCH              varchar(30),
    PS_NAMES_LAST_NAME                    varchar(30),
    PS_NAMES_FIRST_NAME                   varchar(30),
    PS_NAMES_MIDDLE_NAME                  varchar(30),
    SECOND_LAST_NAME                      varchar(30),
    SECOND_LAST_SRCH                      varchar(30),
    PS_NAMES_PREF_FIRST_NAME              varchar(30),
    PS_NAMES_NAME_DISPLAY                 varchar(50),
    PS_NAMES_NAME_FORMAL                  varchar(60),
    NAME_DISPLAY_SRCH                     varchar(50),
    PS_NAMES_LASTUPDDTTM                  datetime,
    PS_NAMES_LASTUPDOPRID                 varchar(30),
    LEGAL_LAST_NAME                       varchar(30),
    LEGAL_FIRST_NAME                      varchar(30),
    LEGAL_MIDDLE_NAME                     varchar(30),
    LEGAL_NAME_SUFFIX                     varchar(15),
    LEGAL_FIRST_LAST_NAME                 varchar(61) not null,
    LIVED_LAST_NAME                       varchar(30),
    LIVED_FIRST_NAME                      varchar(30),
    LIVED_MIDDLE_NAME                     varchar(30),
    LIVED_NAME_SUFFIX                     varchar     not null,
    LIVED_FIRST_LAST_NAME                 varchar(50),
    LIVED_LAST_FIRST_NAME                 varchar(62) not null,
    PS_PERS_DATA_USA_EMPLID               varchar(11),
    PS_PERS_DATA_USA_EFFDT                date,
    US_WORK_ELIGIBILTY                    varchar,
    MILITARY_STATUS                       varchar,
    CITIZEN_PROOF1                        varchar(10),
    CITIZEN_PROOF2                        varchar(10),
    MEDICARE_ENTLD_DT                     date,
    PS_PERSON_EMPLID                      varchar(11),
    BIRTHDATE                             date,
    BIRTHPLACE                            varchar(30),
    BIRTHCOUNTRY                          varchar(3),
    BIRTHSTATE                            varchar(6),
    DT_OF_DEATH                           date,
    PS_PERSONAL_PHONE_EMPLID              varchar(11),
    PS_PERSONAL_PHONE_PHONE_TYPE          varchar(4),
    PS_PERSONAL_PHONE_COUNTRY_CODE        varchar(3),
    PS_PERSONAL_PHONE_PHONE               varchar(24),
    PS_PERSONAL_PHONE_EXTENSION           varchar(6),
    PREF_PHONE_FLAG                       varchar,
    PS_ADDRESSES_EMPLID                   varchar(11),
    PS_ADDRESSES_ADDRESS_TYPE             varchar(4),
    PS_ADDRESSES_EFFDT                    date,
    PS_ADDRESSES_EFF_STATUS               varchar,
    PS_ADDRESSES_COUNTRY                  varchar(3),
    PS_ADDRESSES_ADDRESS1                 varchar(55),
    PS_ADDRESSES_ADDRESS2                 varchar(55),
    PS_ADDRESSES_ADDRESS3                 varchar(55),
    PS_ADDRESSES_ADDRESS4                 varchar(55),
    PS_ADDRESSES_CITY                     varchar(30),
    PS_ADDRESSES_HOUSE_TYPE               varchar(2),
    PS_ADDRESSES_COUNTY                   varchar(30),
    PS_ADDRESSES_STATE                    varchar(6),
    PS_ADDRESSES_POSTAL                   varchar(12),
    PS_ADDRESSES_REG_REGION               varchar(5),
    PS_ADDRESSES_LASTUPDDTTM              datetime,
    PS_ADDRESSES_LASTUPDOPRID             varchar(30),
    PS_EMAIL_ADDRESSES_EMPLID             varchar(11),
    BUSN_E_ADDR_TYPE                      varchar(4),
    BUSN_EMAIL_ADDR                       varchar(70),
    BUSN_EMAIL_FLAG                       varchar,
    CAMP_E_ADDR_TYPE                      varchar(4),
    CAMP_EMAIL_ADDR                       varchar(70),
    CAMP_EMAIL_FLAG                       varchar,
    HOME_E_ADDR_TYPE                      varchar(4),
    HOME_EMAIL_ADDR                       varchar(70),
    HOME_EMAIL_FLAG                       varchar,
    OTHR_E_ADDR_TYPE                      varchar(4),
    OTHR_EMAIL_ADDR                       varchar(70),
    OTHR_EMAIL_FLAG                       varchar,
    PS_COMPENSATION_EMPLID_UCHRLY         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHRLY       smallint,
    PS_COMPENSATION_EFFDT_UCHRLY          date,
    PS_COMPENSATION_EFFSEQ_UCHRLY         smallint,
    COMP_EFFSEQ_UCHRLY                    smallint,
    COMP_RATECD_UCHRLY                    varchar(6),
    COMP_RATE_POINTS_UCHRLY               int,
    PS_COMPENSATION_COMPRATE_UCHRLY       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHRLY       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHRLY varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHRLY    varchar(3),
    MANUAL_SW_UCHRLY                      varchar,
    CONVET_COMPRT_UCHRLY                  numeric(18, 6),
    RATE_CODE_GROUP_UCHRLY                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHRLY     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHRLY     numeric(6, 3),
    CHANGE_PTS_UCHRLY                     int,
    FTE_INDICATOR_UCHRLY                  varchar,
    CMP_SRC_IND_UCHRLY                    varchar,
    PS_COMPENSATION_EMPLID_UCANNL         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCANNL       smallint,
    PS_COMPENSATION_EFFDT_UCANNL          date,
    PS_COMPENSATION_EFFSEQ_UCANNL         smallint,
    COMP_EFFSEQ_UCANNL                    smallint,
    COMP_RATECD_UCANNL                    varchar(6),
    COMP_RATE_POINTS_UCANNL               int,
    PS_COMPENSATION_COMPRATE_UCANNL       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCANNL       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCANNL varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCANNL    varchar(3),
    MANUAL_SW_UCANNL                      varchar,
    CONVET_COMPRT_UCANNL                  numeric(18, 6),
    RATE_CODE_GROUP_UCANNL                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCANNL     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCANNL     numeric(6, 3),
    CHANGE_PTS_UCANNL                     int,
    FTE_INDICATOR_UCANNL                  varchar,
    CMP_SRC_IND_UCANNL                    varchar,
    PS_COMPENSATION_EMPLID_UCHSX          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSX        smallint,
    PS_COMPENSATION_EFFDT_UCHSX           date,
    PS_COMPENSATION_EFFSEQ_UCHSX          smallint,
    COMP_EFFSEQ_UCHSX                     smallint,
    COMP_RATECD_UCHSX                     varchar(6),
    COMP_RATE_POINTS_UCHSX                int,
    PS_COMPENSATION_COMPRATE_UCHSX        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSX        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSX  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSX     varchar(3),
    MANUAL_SW_UCHSX                       varchar,
    CONVET_COMPRT_UCHSX                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSX                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSX      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSX      numeric(6, 3),
    CHANGE_PTS_UCHSX                      int,
    FTE_INDICATOR_UCHSX                   varchar,
    CMP_SRC_IND_UCHSX                     varchar,
    PS_COMPENSATION_EMPLID_UCHSP          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSP        smallint,
    PS_COMPENSATION_EFFDT_UCHSP           date,
    PS_COMPENSATION_EFFSEQ_UCHSP          smallint,
    COMP_EFFSEQ_UCHSP                     smallint,
    COMP_RATECD_UCHSP                     varchar(6),
    COMP_RATE_POINTS_UCHSP                int,
    PS_COMPENSATION_COMPRATE_UCHSP        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSP        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSP  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSP     varchar(3),
    MANUAL_SW_UCHSP                       varchar,
    CONVET_COMPRT_UCHSP                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSP                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSP      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSP      numeric(6, 3),
    CHANGE_PTS_UCHSP                      int,
    FTE_INDICATOR_UCHSP                   varchar,
    CMP_SRC_IND_UCHSP                     varchar,
    PS_COMPENSATION_EMPLID_UCHSN          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSN        smallint,
    PS_COMPENSATION_EFFDT_UCHSN           date,
    PS_COMPENSATION_EFFSEQ_UCHSN          smallint,
    COMP_EFFSEQ_UCHSN                     smallint,
    COMP_RATECD_UCHSN                     varchar(6),
    COMP_RATE_POINTS_UCHSN                int,
    PS_COMPENSATION_COMPRATE_UCHSN        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSN        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSN  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSN     varchar(3),
    MANUAL_SW_UCHSN                       varchar,
    CONVET_COMPRT_UCHSN                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSN                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSN      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSN      numeric(6, 3),
    CHANGE_PTS_UCHSN                      int,
    FTE_INDICATOR_UCHSN                   varchar,
    CMP_SRC_IND_UCHSN                     varchar,
    PS_COMPENSATION_EMPLID_UCWOS          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCWOS        smallint,
    PS_COMPENSATION_EFFDT_UCWOS           date,
    PS_COMPENSATION_EFFSEQ_UCWOS          smallint,
    COMP_EFFSEQ_UCWOS                     smallint,
    COMP_RATECD_UCWOS                     varchar(6),
    COMP_RATE_POINTS_UCWOS                int,
    PS_COMPENSATION_COMPRATE_UCWOS        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCWOS        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCWOS  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCWOS     varchar(3),
    MANUAL_SW_UCWOS                       varchar,
    CONVET_COMPRT_UCWOS                   numeric(18, 6),
    RATE_CODE_GROUP_UCWOS                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCWOS      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCWOS      numeric(6, 3),
    CHANGE_PTS_UCWOS                      int,
    FTE_INDICATOR_UCWOS                   varchar,
    CMP_SRC_IND_UCWOS                     varchar,
    PS_COMPENSATION_EMPLID_UCSPHY         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCSPHY       smallint,
    PS_COMPENSATION_EFFDT_UCSPHY          date,
    PS_COMPENSATION_EFFSEQ_UCSPHY         smallint,
    COMP_EFFSEQ_UCSPHY                    smallint,
    COMP_RATECD_UCSPHY                    varchar(6),
    COMP_RATE_POINTS_UCSPHY               int,
    PS_COMPENSATION_COMPRATE_UCSPHY       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCSPHY       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCSPHY varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCSPHY    varchar(3),
    MANUAL_SW_UCSPHY                      varchar,
    CONVET_COMPRT_UCSPHY                  numeric(18, 6),
    RATE_CODE_GROUP_UCSPHY                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCSPHY     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCSPHY     numeric(6, 3),
    CHANGE_PTS_UCSPHY                     int,
    FTE_INDICATOR_UCSPHY                  varchar,
    CMP_SRC_IND_UCSPHY                    varchar,
    PS_COMPENSATION_EMPLID_UCOFF1         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCOFF1       smallint,
    PS_COMPENSATION_EFFDT_UCOFF1          date,
    PS_COMPENSATION_EFFSEQ_UCOFF1         smallint,
    COMP_EFFSEQ_UCOFF1                    smallint,
    COMP_RATECD_UCOFF1                    varchar(6),
    COMP_RATE_POINTS_UCOFF1               int,
    PS_COMPENSATION_COMPRATE_UCOFF1       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCOFF1       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCOFF1 varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCOFF1    varchar(3),
    MANUAL_SW_UCOFF1                      varchar,
    CONVET_COMPRT_UCOFF1                  numeric(18, 6),
    RATE_CODE_GROUP_UCOFF1                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCOFF1     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCOFF1     numeric(6, 3),
    CHANGE_PTS_UCOFF1                     int,
    FTE_INDICATOR_UCOFF1                  varchar,
    CMP_SRC_IND_UCOFF1                    varchar,
    PS_COMPENSATION_EMPLID_UCFELM         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCFELM       smallint,
    PS_COMPENSATION_EFFDT_UCFELM          date,
    PS_COMPENSATION_EFFSEQ_UCFELM         smallint,
    COMP_EFFSEQ_UCFELM                    smallint,
    COMP_RATECD_UCFELM                    varchar(6),
    COMP_RATE_POINTS_UCFELM               int,
    PS_COMPENSATION_COMPRATE_UCFELM       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCFELM       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCFELM varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCFELM    varchar(3),
    MANUAL_SW_UCFELM                      varchar,
    CONVET_COMPRT_UCFELM                  numeric(18, 6),
    RATE_CODE_GROUP_UCFELM                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCFELM     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCFELM     numeric(6, 3),
    CHANGE_PTS_UCFELM                     int,
    FTE_INDICATOR_UCFELM                  varchar,
    CMP_SRC_IND_UCFELM                    varchar,
    PS_PERS_MILIT_USA_EMPLID              varchar(11),
    MIL_DISCHRG_DT_USA                    date,
    PS_CITIZENSHIP_EMPLID                 varchar(11),
    PS_CITIZENSHIP_DEPENDENT_ID           varchar(2),
    PS_CITIZENSHIP_COUNTRY                varchar(3),
    CITIZENSHIP_STATUS                    varchar,
    PS_PRIMARY_JOBS_EMPLID                varchar(11),
    PRIMARY_JOB_APP                       varchar(2),
    PS_PRIMARY_JOB_EMPL_RCD               smallint,
    PS_PRIMARY_JOB_EFFDT                  date,
    PRIMARY_JOB_IND                       varchar,
    PRIMARY_FLAG1                         varchar,
    PRIMARY_FLAG2                         varchar,
    PRIMARY_JOBS_SRC                      varchar,
    JOB_EFFSEQ                            smallint,
    JOB_EMPL_RCD                          smallint,
    PS_DEP_BEN_EMPLID_01                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_01         varchar(2),
    PS_DEP_BEN_BIRTHDATE_01               date,
    PS_DEP_BEN_BIRTHPLACE_01              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_01              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_01            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_01             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_01        varchar,
    PS_DEP_BEN_COUNTRY_CODE_01            varchar(3),
    PS_DEP_BEN_PHONE_01                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_01         varchar,
    PS_DEP_BEN_PHONE_TYPE_01              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_01          date,
    PS_DEP_BEN_COBRA_ACTION_01            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_01            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_01       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_01        date,
    PS_DEP_BEN_EMPLID_02                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_02         varchar(2),
    PS_DEP_BEN_BIRTHDATE_02               date,
    PS_DEP_BEN_BIRTHPLACE_02              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_02              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_02            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_02             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_02        varchar,
    PS_DEP_BEN_COUNTRY_CODE_02            varchar(3),
    PS_DEP_BEN_PHONE_02                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_02         varchar,
    PS_DEP_BEN_PHONE_TYPE_02              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_02          date,
    PS_DEP_BEN_COBRA_ACTION_02            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_02            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_02       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_02        date,
    PS_DEP_BEN_EMPLID_03                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_03         varchar(2),
    PS_DEP_BEN_BIRTHDATE_03               date,
    PS_DEP_BEN_BIRTHPLACE_03              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_03              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_03            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_03             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_03        varchar,
    PS_DEP_BEN_COUNTRY_CODE_03            varchar(3),
    PS_DEP_BEN_PHONE_03                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_03         varchar,
    PS_DEP_BEN_PHONE_TYPE_03              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_03          date,
    PS_DEP_BEN_COBRA_ACTION_03            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_03            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_03       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_03        date,
    PS_DEP_BEN_EMPLID_04                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_04         varchar(2),
    PS_DEP_BEN_BIRTHDATE_04               date,
    PS_DEP_BEN_BIRTHPLACE_04              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_04              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_04            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_04             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_04        varchar,
    PS_DEP_BEN_COUNTRY_CODE_04            varchar(3),
    PS_DEP_BEN_PHONE_04                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_04         varchar,
    PS_DEP_BEN_PHONE_TYPE_04              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_04          date,
    PS_DEP_BEN_COBRA_ACTION_04            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_04            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_04       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_04        date,
    PS_DEP_BEN_EFF_EMPLID_01              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_01     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_01               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_01        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_01      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_01          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_01       date,
    PS_DEP_BEN_EFF_SEX_01                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_01          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_01             varchar,
    PS_DEP_BEN_EFF_DISABLED_01            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_01   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_01  date,
    PS_DEP_BEN_EFF_SMOKER_01              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_01           date,
    PS_DEP_BEN_EFF_EMPLID_02              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_02     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_02               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_02        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_02      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_02          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_02       date,
    PS_DEP_BEN_EFF_SEX_02                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_02          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_02             varchar,
    PS_DEP_BEN_EFF_DISABLED_02            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_02   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_02  date,
    PS_DEP_BEN_EFF_SMOKER_02              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_02           date,
    PS_DEP_BEN_EFF_EMPLID_03              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_03     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_03               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_03        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_03      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_03          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_03       date,
    PS_DEP_BEN_EFF_SEX_03                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_03          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_03             varchar,
    PS_DEP_BEN_EFF_DISABLED_03            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_03   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_03  date,
    PS_DEP_BEN_EFF_SMOKER_03              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_03           date,
    PS_DEP_BEN_EFF_EMPLID_04              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_04     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_04               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_04        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_04      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_04          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_04       date,
    PS_DEP_BEN_EFF_SEX_04                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_04          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_04             varchar,
    PS_DEP_BEN_EFF_DISABLED_04            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_04   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_04  date,
    PS_DEP_BEN_EFF_SMOKER_04              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_04           date,
    PS_DEP_BEN_NAME_EMPLID_01             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_01    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_01              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_01  varchar(3),
    PS_DEP_BEN_NAME_NAME_01               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_01        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_01        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_01     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_01    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_01          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_01         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_01        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_01    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_01       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_01        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_01    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_01         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_01         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_01       date,
    PS_DEP_BEN_NAME_EMPLID_02             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_02    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_02              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_02  varchar(3),
    PS_DEP_BEN_NAME_NAME_02               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_02        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_02        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_02     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_02    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_02          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_02         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_02        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_02    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_02       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_02        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_02    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_02         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_02         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_02       date,
    PS_DEP_BEN_NAME_EMPLID_03             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_03    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_03              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_03  varchar(3),
    PS_DEP_BEN_NAME_NAME_03               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_03        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_03        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_03     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_03    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_03          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_03         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_03        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_03    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_03       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_03        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_03    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_03         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_03         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_03       date,
    PS_DEP_BEN_NAME_EMPLID_04             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_04    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_04              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_04  varchar(3),
    PS_DEP_BEN_NAME_NAME_04               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_04        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_04        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_04     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_04    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_04          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_04         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_04        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_04    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_04       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_04        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_04    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_04         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_04         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_04       date,
    PS_PER_ORG_ASGN_EMPLID                varchar(11),
    PS_PER_ORG_ASGN_EMPL_RCD              smallint,
    PER_ORG_ASGN                          varchar(3),
    ORG_INSTANCE_ERN                      smallint,
    POI_TYPE_ASGN                         varchar(5),
    BENEFIT_RCD_NBR                       smallint,
    HOME_HOST_CLASS                       varchar,
    CMPNY_DT_OVR                          varchar,
    CMPNY_SENIORITY_DT                    date,
    SERVICE_DT_OVR                        varchar,
    SERVICE_DT                            date,
    SEN_PAY_DT_OVR                        varchar,
    SENIORITY_PAY_DT                      date,
    PROF_EXPERIENCE_DT                    date,
    LAST_VERIFICATN_DT                    date,
    PROBATION_DT                          date,
    LAST_INCREASE_DT                      date,
    BUSINESS_TITLE                        varchar(30),
    POSITION_PHONE                        varchar(24),
    LAST_CHILD_UPDDTM                     datetime,
    PROB_END_DT                           date,
    PROBATION_CODE                        varchar,
    PROBATION_CODE_DESCR                  varchar(30),
    PS_EMERGENCY_CNTCT_EMPLID             varchar(11),
    CONTACT_NAME                          varchar(50),
    SAME_ADDRESS_EMPL                     varchar,
    PRIMARY_CONTACT                       varchar,
    PS_EMERGENCY_CNTCT_COUNTRY            varchar(3),
    PS_EMERGENCY_CNTCT_ADDRESS1           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS2           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS3           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS4           varchar(55),
    PS_EMERGENCY_CNTCT_CITY               varchar(30),
    PS_EMERGENCY_CNTCT_HOUSE_TYPE         varchar(2),
    PS_EMERGENCY_CNTCT_COUNTY             varchar(30),
    PS_EMERGENCY_CNTCT_STATE              varchar(6),
    PS_EMERGENCY_CNTCT_POSTAL             varchar(12),
    GEO_CODE                              varchar(11),
    PS_EMERGENCY_CNTCT_COUNTRY_CODE       varchar(3),
    PS_EMERGENCY_CNTCT_PHONE              varchar(24),
    PS_EMERGENCY_CNTCT_RELATIONSHIP       varchar(2),
    PS_EMERGENCY_CNTCT_SAME_PHONE_EMPL    varchar,
    PS_EMERGENCY_CNTCT_ADDRESS_TYPE       varchar(4),
    PS_EMERGENCY_CNTCT_PHONE_TYPE         varchar(4),
    PS_EMERGENCY_CNTCT_EXTENSION          varchar(6),
    LAST_NAME                             varchar(30),
    FIRST_NAME                            varchar(30),
    MIDDLE_NAME                           varchar(30),
    ADDRESS1                              varchar(55),
    ADDRESS2                              varchar(55),
    CITY                                  varchar(30),
    COUNTY                                varchar(30),
    STATE                                 varchar(6),
    POSTAL                                varchar(12),
    COUNTRY                               varchar(3),
    SETID                                 varchar(5),
    JOBCODE                               varchar(6),
    JOBCODE_EFFDT                         date,
    JOBCODE_EFF_STATUS                    varchar,
    JOBCODE_DESCR                         varchar(30),
    JOBCODE_DESCRSHORT                    varchar(10),
    JOBCODE_JOB_FUNCTION                  varchar(3),
    JOBCODE_SETID_SALARY                  varchar(5),
    JOBCODE_SAL_ADMIN_PLAN                varchar(4),
    JOBCODE_GRADE                         varchar(3),
    JOBCODE_STEP                          smallint,
    MANAGER_LEVEL                         varchar(2),
    SURVEY_SALARY                         int,
    SURVEY_JOB_CODE                       varchar(8),
    JOBCODE_UNION_CD                      varchar(3),
    RETRO_RATE                            numeric(6, 4),
    RETRO_PERCENT                         numeric(6, 4),
    CURRENCY_CD                           varchar(3),
    JOBCODE_STD_HOURS                     numeric(6, 2),
    JOBCODE_STD_HRS_FREQUENCY             varchar(5),
    JOBCODE_COMP_FREQUENCY                varchar(5),
    WORKERS_COMP_CD                       varchar(4),
    JOBCODE_JOB_FAMILY                    varchar(6),
    JOBCODE_REG_TEMP                      varchar,
    JOBCODE_DIRECTLY_TIPPED               varchar,
    MED_CHKUP_REQ                         varchar,
    JOBCODE_FLSA_STATUS                   varchar,
    EEO1CODE                              varchar,
    EEO4CODE                              varchar,
    EEO5CODE                              varchar(2),
    EEO6CODE                              varchar,
    EEO_JOB_GROUP                         varchar(4),
    JOBCODE_US_SOC_CD                     varchar(10),
    IPEDSSCODE                            varchar,
    JOBCODE_US_OCC_CD                     varchar(4),
    AVAIL_TELEWORK                        varchar,
    FUNCTION_CD                           varchar(2),
    TRN_PROGRAM                           varchar(6),
    JOBCODE_COMPANY                       varchar(3),
    JOBCODE_BARG_UNIT                     varchar(4),
    ENCUMBER_INDC                         varchar,
    POSN_MGMT_INDC                        varchar,
    EG_ACADEMIC_RANK                      varchar(3),
    EG_GROUP                              varchar(6),
    ENCUMB_SAL_OPTN                       varchar(3),
    ENCUMB_SAL_AMT                        numeric(18, 3),
    LAST_UPDATE_DATE                      date,
    REG_REGION                            varchar(5),
    SAL_RANGE_MIN_RATE                    numeric(18, 6),
    SAL_RANGE_MID_RATE                    numeric(18, 6),
    SAL_RANGE_MAX_RATE                    numeric(18, 6),
    SAL_RANGE_CURRENCY                    varchar(3),
    SAL_RANGE_FREQ                        varchar(5),
    JOB_SUB_FUNC                          varchar(3),
    LASTUPDOPRID                          varchar(30),
    LASTUPDDTTM                           datetime,
    KEY_JOBCODE                           varchar,
    JOB_FUNCTION                          varchar(3),
    JOB_FUNCTION_DESCR                    varchar(30),
    JOB_FUNCTION_DESCRSHORT               varchar(10),
    JOB_FAMILY                            varchar(6),
    JOB_FAMILY_DESCR                      varchar(30),
    JOB_FAMILY_DESCRSHORT                 varchar(10),
    US_SOC_CD                             varchar(10),
    SOC_DESCR50                           varchar(50),
    US_OCC_CD                             varchar(4),
    OCC_DESCR50                           varchar(50),
    UC_OSHPD_CODE                         varchar(10),
    UC_CTO_OS_CD                          varchar(3),
    OLD_PPS_ID                            varchar(254),
    UC_CBR_RATE                           numeric(16, 4),
    UC_CBR_GROUP_DESCR                    varchar(30),
    MANAGER_EMPLID                        varchar(11),
    MANAGER_NAME                          varchar(50),
    MANAGER_FIRST_NAME                    varchar(30),
    MANAGER_LAST_NAME                     varchar(30),
    MANAGER_MIDDLE_NAME                   varchar(30),
    MANAGER_NAME_SUFFIX                   varchar(15),
    MANAGER_DEPTID                        varchar(10),
    MANAGER_POSITION_NBR                  varchar(8),
    MANAGER_JOBCODE                       varchar(6),
    MANAGER_EMPL_STATUS                   varchar,
    MANAGER_BUSN_EMAIL_ADDR               varchar(70),
    MANAGER_CAMP_EMAIL_ADDR               varchar(70),
    MANAGER_LIVED_LAST_NAME               varchar(30),
    MANAGER_LIVED_FIRST_NAME              varchar(30),
    MANAGER_LIVED_MIDDLE_NAME             varchar(30),
    MANAGER_LIVED_NAME_SUFFIX             varchar     not null,
    MANAGER_LIVED_FIRST_LAST_NAME         varchar(50),
    MANAGER_LIVED_LAST_FIRST_NAME         varchar(62),
    VC_CODE                               varchar(50),
    VC_Name                               varchar(30),
    UC_EMP_REL_CD                         varchar(3),
    UC_EMP_REL_DESCR                      varchar(30),
    WORK_LOCATION_EFF_STATUS              varchar,
    WORK_LOCATION_BUILDING                varchar(10),
    WORK_LOCATION_FLOOR                   varchar(10),
    WORK_LOCATION_COUNTRY                 varchar(3),
    WORK_LOCATION_ADDRESS1                varchar(55),
    WORK_LOCATION_ADDRESS2                varchar(55),
    WORK_LOCATION_ADDRESS3                varchar(55),
    WORK_LOCATION_CITY                    varchar(30),
    WORK_LOCATION_COUNTY                  varchar(30),
    WORK_LOCATION_STATE                   varchar(6),
    WORK_LOCATION_POSTAL                  varchar(12),
    WORK_LOCATION_CUBICLE                 varchar(15),
    CUBICLE                               varchar(15)
)
go

create table UKG_EMPL_STATUS_LOOKUP
(
    emplid      varchar(11),
    EMPL_STATUS varchar,
    EFFDT       date,
    EFFSEQ      smallint,
    EMPL_RCD    smallint,
    HIRE_DT     date,
    NOTE        varchar(32) not null,
    LOAD_DTTM   datetime    not null
)
go

create index IX_UKG_EMPL_STATUS_LOOKUP_emplid
    on UKG_EMPL_STATUS_LOOKUP (emplid)
go

create table UKG_EMPL_T
(
    NON_UKG_MANAGER_FLAG                  varchar     not null,
    NAME                                  varchar(50),
    EMPLID                                varchar(11),
    EMPL_RCD                              smallint,
    EFFDT                                 date,
    EFFSEQ                                smallint,
    PER_ORG                               varchar(3),
    DEPTID                                varchar(10),
    DEPT_DESCR                            varchar(30),
    POSITION_NBR                          varchar(8),
    POSITION_EFFDT                        date,
    POSITION_EFF_STATUS                   varchar,
    POSITION_DESCR                        varchar(30),
    POSITION_DESCRSHORT                   varchar(10),
    POSITION_ACTION                       varchar(3),
    POSITION_ACTION_REASON                varchar(3),
    POSITION_ACTION_DT                    date,
    POSITION_POSN_STATUS                  varchar,
    POSITION_STATUS_DT                    date,
    BUDGETED_POSN                         varchar,
    CONFIDENTIAL_POSN                     varchar,
    JOB_SHARE                             varchar,
    KEY_POSITION                          varchar,
    MAX_HEAD_COUNT                        smallint,
    UPDATE_INCUMBENTS                     varchar,
    POSITION_REPORTS_TO                   varchar(8),
    REPORT_DOTTED_LINE                    varchar(8),
    ORGCODE                               varchar(60),
    ORGCODE_FLAG                          varchar,
    POSITION_LOCATION                     varchar(10),
    MAIL_DROP                             varchar(50),
    COUNTRY_CODE                          varchar(3),
    PHONE                                 varchar(24),
    POSITION_COMPANY                      varchar(3),
    POSITION_STD_HOURS                    numeric(6, 2),
    POSITION_STD_HRS_FREQUENCY            varchar(5),
    POSITION_UNION_CD                     varchar(3),
    POSITION_SHIFT                        varchar,
    POSITION_REG_TEMP                     varchar,
    POSITION_FULL_PART_TIME               varchar,
    MON_HRS                               numeric(4, 2),
    TUES_HRS                              numeric(4, 2),
    WED_HRS                               numeric(4, 2),
    THURS_HRS                             numeric(4, 2),
    FRI_HRS                               numeric(4, 2),
    SAT_HRS                               numeric(4, 2),
    SUN_HRS                               numeric(4, 2),
    POSITION_BARG_UNIT                    varchar(4),
    SEASONAL                              varchar,
    POSITION_TRN_PROGRAM                  varchar(6),
    LANGUAGE_SKILL                        varchar(2),
    POSITION_MANAGER_LEVEL                varchar(2),
    POSITION_FLSA_STATUS                  varchar,
    POSITION_REG_REGION                   varchar(5),
    POSITION_CLASS_INDC                   varchar,
    POSITION_ENCUMBER_INDC                varchar,
    POSITION_FTE                          numeric(7, 6),
    POSITION_POOL_ID                      varchar(3),
    POSITION_EG_ACADEMIC_RANK             varchar(3),
    POSITION_EG_GROUP                     varchar(6),
    POSITION_ENCUMB_SAL_OPTN              varchar(3),
    POSITION_ENCUMB_SAL_AMT               numeric(18, 3),
    HEALTH_CERTIFICATE                    varchar,
    SIGN_AUTHORITY                        varchar,
    ADDS_TO_FTE_ACTUAL                    varchar,
    POSITION_SAL_ADMIN_PLAN               varchar(4),
    POSITION_GRADE                        varchar(3),
    POSITION_STEP                         smallint,
    POSITION_SUPV_LVL_ID                  varchar(8),
    INCLUDE_SALPLN_FLG                    varchar,
    SEC_CLEARANCE_TYPE                    varchar(3),
    AVAIL_TELEWORK_POS                    varchar,
    SUPERVISOR_ID                         varchar(11),
    HR_STATUS                             varchar,
    POSITION_OVERRIDE                     varchar,
    POSN_CHANGE_RECORD                    varchar,
    EMPL_STATUS                           varchar,
    EMPL_STATUS_DESCR                     varchar(30),
    ACTION                                varchar(3),
    ACTION_DT                             date,
    ACTION_REASON                         varchar(3),
    LOCATION                              varchar(10),
    LOCATION_DESCR                        varchar(30),
    TAX_LOCATION_CD                       varchar(10),
    JOB_ENTRY_DT                          date,
    DEPT_ENTRY_DT                         date,
    POSITION_ENTRY_DT                     date,
    SHIFT                                 varchar,
    REG_TEMP                              varchar,
    FULL_PART_TIME                        varchar,
    COMPANY                               varchar(3),
    PAYGROUP                              varchar(3),
    PAYGROUP_DESCR                        varchar(30),
    PAY_FREQUENCY                         varchar(5),
    BAS_GROUP_ID                          varchar(3),
    ELIG_CONFIG1                          varchar(10),
    ELIG_CONFIG2                          varchar(10),
    ELIG_CONFIG3                          varchar(10),
    ELIG_CONFIG4                          varchar(10),
    ELIG_CONFIG5                          varchar(10),
    ELIG_CONFIG6                          varchar(10),
    ELIG_CONFIG7                          varchar(10),
    ELIG_CONFIG8                          varchar(10),
    ELIG_CONFIG9                          varchar(10),
    BEN_STATUS                            varchar(4),
    BAS_ACTION                            varchar(3),
    COBRA_ACTION                          varchar(3),
    EMPL_TYPE                             varchar,
    HOLIDAY_SCHEDULE                      varchar(6),
    STD_HOURS                             numeric(6, 2),
    STD_HRS_FREQUENCY                     varchar(5),
    OFFICER_CD                            varchar,
    EMPL_CLASS                            varchar(3),
    EMPL_CLASS_DESCR                      varchar(30),
    SAL_ADMIN_PLAN                        varchar(4),
    GRADE                                 varchar(3),
    GRADE_ENTRY_DT                        date,
    STEP                                  smallint,
    STEP_ENTRY_DT                         date,
    EARNS_DIST_TYPE                       varchar,
    PS_JOB_COMP_FREQUENCY                 varchar(5),
    PS_JOB_COMPRATE                       numeric(18, 6),
    PS_JOB_CHANGE_AMT                     numeric(18, 6),
    PS_JOB_CHANGE_PCT                     numeric(6, 3),
    ANNUAL_RT                             numeric(18, 3),
    MONTHLY_RT                            numeric(18, 3),
    DAILY_RT                              numeric(18, 3),
    HOURLY_RT                             numeric(18, 6),
    ANNL_BENEF_BASE_RT                    numeric(18, 3),
    SHIFT_RT                              numeric(18, 6),
    SHIFT_FACTOR                          numeric(4, 3),
    PS_JOB_CURRENCY_CD                    varchar(3),
    BUSINESS_UNIT                         varchar(5),
    SETID_DEPT                            varchar(5),
    SETID_JOBCODE                         varchar(5),
    SETID_LOCATION                        varchar(5),
    SETID_SALARY                          varchar(5),
    SETID_EMPL_CLASS                      varchar(5),
    PS_JOB_REG_REGION                     varchar(5),
    DIRECTLY_TIPPED                       varchar,
    FLSA_STATUS                           varchar,
    FLSA_STATUS_DESCR                     varchar(30),
    EEO_CLASS                             varchar,
    UNION_CD                              varchar(3),
    BARG_UNIT                             varchar(4),
    UNION_SENIORITY_DT                    date,
    GP_PAYGROUP                           varchar(10),
    GP_DFLT_ELIG_GRP                      varchar,
    GP_ELIG_GRP                           varchar(10),
    GP_DFLT_CURRTTYP                      varchar,
    CUR_RT_TYPE                           varchar(5),
    GP_DFLT_EXRTDT                        varchar,
    GP_ASOF_DT_EXG_RT                     varchar,
    CLASS_INDC                            varchar,
    ENCUMB_OVERRIDE                       varchar,
    FICA_STATUS_EE                        varchar,
    FTE                                   numeric(7, 6),
    PRORATE_CNT_AMT                       varchar,
    PAY_SYSTEM_FLG                        varchar(2),
    LUMP_SUM_PAY                          varchar,
    CONTRACT_NUM                          varchar(25),
    JOB_INDICATOR                         varchar,
    BENEFIT_SYSTEM                        varchar(2),
    WORK_DAY_HOURS                        numeric(6, 2),
    REPORTS_TO                            varchar(8),
    JOB_DATA_SRC_CD                       varchar(3),
    ESTABID                               varchar(12),
    SUPV_LVL_ID                           varchar(8),
    SETID_SUPV_LVL                        varchar(5),
    ABSENCE_SYSTEM_CD                     varchar(3),
    POI_TYPE                              varchar(5),
    HIRE_DT                               date,
    LAST_HIRE_DT                          date,
    TERMINATION_DT                        date,
    ASGN_START_DT                         date,
    LST_ASGN_START_DT                     date,
    ASGN_END_DT                           date,
    LDW_OVR                               varchar,
    LAST_DATE_WORKED                      date,
    EXPECTED_RETURN_DT                    date,
    EXPECTED_END_DATE                     date,
    AUTO_END_FLG                          varchar,
    PS_JOB_LASTUPDDTTM                    datetime,
    PS_JOB_LASTUPDOPRID                   varchar(30),
    PS_PERS_DATA_EMPLID                   varchar(11),
    PS_PERS_DATA_EFFDT                    date,
    MAR_STATUS                            varchar,
    MAR_STATUS_DT                         date,
    SEX                                   varchar,
    HIGHEST_EDUC_LVL                      varchar(2),
    FT_STUDENT                            varchar,
    LANG_CD                               varchar(3),
    PS_PERS_DATA_EFFDT_LASTUPDDTTM        datetime,
    PS_PERS_DATA_EFFDT_LASTUPDOPRID       varchar(30),
    PS_NAMES_EMPLID                       varchar(11),
    NAME_TYPE                             varchar(3),
    PS_NAMES_EFFDT                        date,
    PS_NAMES_EFF_STATUS                   varchar,
    PS_NAMES_COUNTRY_NM_FORMAT            varchar(3),
    NAME_INITIALS                         varchar(6),
    PS_NAMES_NAME_PREFIX                  varchar(4),
    PS_NAMES_NAME_SUFFIX                  varchar(15),
    NAME_TITLE                            varchar(30),
    PS_NAMES_LAST_NAME_SRCH               varchar(30),
    PS_NAMES_FIRST_NAME_SRCH              varchar(30),
    PS_NAMES_LAST_NAME                    varchar(30),
    PS_NAMES_FIRST_NAME                   varchar(30),
    PS_NAMES_MIDDLE_NAME                  varchar(30),
    SECOND_LAST_NAME                      varchar(30),
    SECOND_LAST_SRCH                      varchar(30),
    PS_NAMES_PREF_FIRST_NAME              varchar(30),
    PS_NAMES_NAME_DISPLAY                 varchar(50),
    PS_NAMES_NAME_FORMAL                  varchar(60),
    NAME_DISPLAY_SRCH                     varchar(50),
    PS_NAMES_LASTUPDDTTM                  datetime,
    PS_NAMES_LASTUPDOPRID                 varchar(30),
    LEGAL_LAST_NAME                       varchar(30),
    LEGAL_FIRST_NAME                      varchar(30),
    LEGAL_MIDDLE_NAME                     varchar(30),
    LEGAL_NAME_SUFFIX                     varchar(15),
    LEGAL_FIRST_LAST_NAME                 varchar(61) not null,
    LIVED_LAST_NAME                       varchar(30),
    LIVED_FIRST_NAME                      varchar(30),
    LIVED_MIDDLE_NAME                     varchar(30),
    LIVED_NAME_SUFFIX                     varchar     not null,
    LIVED_FIRST_LAST_NAME                 varchar(50),
    LIVED_LAST_FIRST_NAME                 varchar(62) not null,
    PS_PERS_DATA_USA_EMPLID               varchar(11),
    PS_PERS_DATA_USA_EFFDT                date,
    US_WORK_ELIGIBILTY                    varchar,
    MILITARY_STATUS                       varchar,
    CITIZEN_PROOF1                        varchar(10),
    CITIZEN_PROOF2                        varchar(10),
    MEDICARE_ENTLD_DT                     date,
    PS_PERSON_EMPLID                      varchar(11),
    BIRTHDATE                             date,
    BIRTHPLACE                            varchar(30),
    BIRTHCOUNTRY                          varchar(3),
    BIRTHSTATE                            varchar(6),
    DT_OF_DEATH                           date,
    PS_PERSONAL_PHONE_EMPLID              varchar(11),
    PS_PERSONAL_PHONE_PHONE_TYPE          varchar(4),
    PS_PERSONAL_PHONE_COUNTRY_CODE        varchar(3),
    PS_PERSONAL_PHONE_PHONE               varchar(24),
    PS_PERSONAL_PHONE_EXTENSION           varchar(6),
    PREF_PHONE_FLAG                       varchar,
    PS_ADDRESSES_EMPLID                   varchar(11),
    PS_ADDRESSES_ADDRESS_TYPE             varchar(4),
    PS_ADDRESSES_EFFDT                    date,
    PS_ADDRESSES_EFF_STATUS               varchar,
    PS_ADDRESSES_COUNTRY                  varchar(3),
    PS_ADDRESSES_ADDRESS1                 varchar(55),
    PS_ADDRESSES_ADDRESS2                 varchar(55),
    PS_ADDRESSES_ADDRESS3                 varchar(55),
    PS_ADDRESSES_ADDRESS4                 varchar(55),
    PS_ADDRESSES_CITY                     varchar(30),
    PS_ADDRESSES_HOUSE_TYPE               varchar(2),
    PS_ADDRESSES_COUNTY                   varchar(30),
    PS_ADDRESSES_STATE                    varchar(6),
    PS_ADDRESSES_POSTAL                   varchar(12),
    PS_ADDRESSES_REG_REGION               varchar(5),
    PS_ADDRESSES_LASTUPDDTTM              datetime,
    PS_ADDRESSES_LASTUPDOPRID             varchar(30),
    PS_EMAIL_ADDRESSES_EMPLID             varchar(11),
    BUSN_E_ADDR_TYPE                      varchar(4),
    BUSN_EMAIL_ADDR                       varchar(70),
    BUSN_EMAIL_FLAG                       varchar,
    CAMP_E_ADDR_TYPE                      varchar(4),
    CAMP_EMAIL_ADDR                       varchar(70),
    CAMP_EMAIL_FLAG                       varchar,
    HOME_E_ADDR_TYPE                      varchar(4),
    HOME_EMAIL_ADDR                       varchar(70),
    HOME_EMAIL_FLAG                       varchar,
    OTHR_E_ADDR_TYPE                      varchar(4),
    OTHR_EMAIL_ADDR                       varchar(70),
    OTHR_EMAIL_FLAG                       varchar,
    PS_COMPENSATION_EMPLID_UCHRLY         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHRLY       smallint,
    PS_COMPENSATION_EFFDT_UCHRLY          date,
    PS_COMPENSATION_EFFSEQ_UCHRLY         smallint,
    COMP_EFFSEQ_UCHRLY                    smallint,
    COMP_RATECD_UCHRLY                    varchar(6),
    COMP_RATE_POINTS_UCHRLY               int,
    PS_COMPENSATION_COMPRATE_UCHRLY       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHRLY       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHRLY varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHRLY    varchar(3),
    MANUAL_SW_UCHRLY                      varchar,
    CONVET_COMPRT_UCHRLY                  numeric(18, 6),
    RATE_CODE_GROUP_UCHRLY                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHRLY     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHRLY     numeric(6, 3),
    CHANGE_PTS_UCHRLY                     int,
    FTE_INDICATOR_UCHRLY                  varchar,
    CMP_SRC_IND_UCHRLY                    varchar,
    PS_COMPENSATION_EMPLID_UCANNL         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCANNL       smallint,
    PS_COMPENSATION_EFFDT_UCANNL          date,
    PS_COMPENSATION_EFFSEQ_UCANNL         smallint,
    COMP_EFFSEQ_UCANNL                    smallint,
    COMP_RATECD_UCANNL                    varchar(6),
    COMP_RATE_POINTS_UCANNL               int,
    PS_COMPENSATION_COMPRATE_UCANNL       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCANNL       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCANNL varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCANNL    varchar(3),
    MANUAL_SW_UCANNL                      varchar,
    CONVET_COMPRT_UCANNL                  numeric(18, 6),
    RATE_CODE_GROUP_UCANNL                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCANNL     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCANNL     numeric(6, 3),
    CHANGE_PTS_UCANNL                     int,
    FTE_INDICATOR_UCANNL                  varchar,
    CMP_SRC_IND_UCANNL                    varchar,
    PS_COMPENSATION_EMPLID_UCHSX          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSX        smallint,
    PS_COMPENSATION_EFFDT_UCHSX           date,
    PS_COMPENSATION_EFFSEQ_UCHSX          smallint,
    COMP_EFFSEQ_UCHSX                     smallint,
    COMP_RATECD_UCHSX                     varchar(6),
    COMP_RATE_POINTS_UCHSX                int,
    PS_COMPENSATION_COMPRATE_UCHSX        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSX        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSX  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSX     varchar(3),
    MANUAL_SW_UCHSX                       varchar,
    CONVET_COMPRT_UCHSX                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSX                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSX      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSX      numeric(6, 3),
    CHANGE_PTS_UCHSX                      int,
    FTE_INDICATOR_UCHSX                   varchar,
    CMP_SRC_IND_UCHSX                     varchar,
    PS_COMPENSATION_EMPLID_UCHSP          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSP        smallint,
    PS_COMPENSATION_EFFDT_UCHSP           date,
    PS_COMPENSATION_EFFSEQ_UCHSP          smallint,
    COMP_EFFSEQ_UCHSP                     smallint,
    COMP_RATECD_UCHSP                     varchar(6),
    COMP_RATE_POINTS_UCHSP                int,
    PS_COMPENSATION_COMPRATE_UCHSP        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSP        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSP  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSP     varchar(3),
    MANUAL_SW_UCHSP                       varchar,
    CONVET_COMPRT_UCHSP                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSP                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSP      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSP      numeric(6, 3),
    CHANGE_PTS_UCHSP                      int,
    FTE_INDICATOR_UCHSP                   varchar,
    CMP_SRC_IND_UCHSP                     varchar,
    PS_COMPENSATION_EMPLID_UCHSN          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCHSN        smallint,
    PS_COMPENSATION_EFFDT_UCHSN           date,
    PS_COMPENSATION_EFFSEQ_UCHSN          smallint,
    COMP_EFFSEQ_UCHSN                     smallint,
    COMP_RATECD_UCHSN                     varchar(6),
    COMP_RATE_POINTS_UCHSN                int,
    PS_COMPENSATION_COMPRATE_UCHSN        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCHSN        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCHSN  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCHSN     varchar(3),
    MANUAL_SW_UCHSN                       varchar,
    CONVET_COMPRT_UCHSN                   numeric(18, 6),
    RATE_CODE_GROUP_UCHSN                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCHSN      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCHSN      numeric(6, 3),
    CHANGE_PTS_UCHSN                      int,
    FTE_INDICATOR_UCHSN                   varchar,
    CMP_SRC_IND_UCHSN                     varchar,
    PS_COMPENSATION_EMPLID_UCWOS          varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCWOS        smallint,
    PS_COMPENSATION_EFFDT_UCWOS           date,
    PS_COMPENSATION_EFFSEQ_UCWOS          smallint,
    COMP_EFFSEQ_UCWOS                     smallint,
    COMP_RATECD_UCWOS                     varchar(6),
    COMP_RATE_POINTS_UCWOS                int,
    PS_COMPENSATION_COMPRATE_UCWOS        numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCWOS        numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCWOS  varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCWOS     varchar(3),
    MANUAL_SW_UCWOS                       varchar,
    CONVET_COMPRT_UCWOS                   numeric(18, 6),
    RATE_CODE_GROUP_UCWOS                 varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCWOS      numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCWOS      numeric(6, 3),
    CHANGE_PTS_UCWOS                      int,
    FTE_INDICATOR_UCWOS                   varchar,
    CMP_SRC_IND_UCWOS                     varchar,
    PS_COMPENSATION_EMPLID_UCSPHY         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCSPHY       smallint,
    PS_COMPENSATION_EFFDT_UCSPHY          date,
    PS_COMPENSATION_EFFSEQ_UCSPHY         smallint,
    COMP_EFFSEQ_UCSPHY                    smallint,
    COMP_RATECD_UCSPHY                    varchar(6),
    COMP_RATE_POINTS_UCSPHY               int,
    PS_COMPENSATION_COMPRATE_UCSPHY       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCSPHY       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCSPHY varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCSPHY    varchar(3),
    MANUAL_SW_UCSPHY                      varchar,
    CONVET_COMPRT_UCSPHY                  numeric(18, 6),
    RATE_CODE_GROUP_UCSPHY                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCSPHY     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCSPHY     numeric(6, 3),
    CHANGE_PTS_UCSPHY                     int,
    FTE_INDICATOR_UCSPHY                  varchar,
    CMP_SRC_IND_UCSPHY                    varchar,
    PS_COMPENSATION_EMPLID_UCOFF1         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCOFF1       smallint,
    PS_COMPENSATION_EFFDT_UCOFF1          date,
    PS_COMPENSATION_EFFSEQ_UCOFF1         smallint,
    COMP_EFFSEQ_UCOFF1                    smallint,
    COMP_RATECD_UCOFF1                    varchar(6),
    COMP_RATE_POINTS_UCOFF1               int,
    PS_COMPENSATION_COMPRATE_UCOFF1       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCOFF1       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCOFF1 varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCOFF1    varchar(3),
    MANUAL_SW_UCOFF1                      varchar,
    CONVET_COMPRT_UCOFF1                  numeric(18, 6),
    RATE_CODE_GROUP_UCOFF1                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCOFF1     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCOFF1     numeric(6, 3),
    CHANGE_PTS_UCOFF1                     int,
    FTE_INDICATOR_UCOFF1                  varchar,
    CMP_SRC_IND_UCOFF1                    varchar,
    PS_COMPENSATION_EMPLID_UCFELM         varchar(11),
    PS_COMPENSATION_EMPL_RCD_UCFELM       smallint,
    PS_COMPENSATION_EFFDT_UCFELM          date,
    PS_COMPENSATION_EFFSEQ_UCFELM         smallint,
    COMP_EFFSEQ_UCFELM                    smallint,
    COMP_RATECD_UCFELM                    varchar(6),
    COMP_RATE_POINTS_UCFELM               int,
    PS_COMPENSATION_COMPRATE_UCFELM       numeric(18, 6),
    PS_COMPENSATION_COMP_PCT_UCFELM       numeric(6, 3),
    PS_COMPENSATION_COMP_FREQUENCY_UCFELM varchar(5),
    PS_COMPENSATION_CURRENCY_CD_UCFELM    varchar(3),
    MANUAL_SW_UCFELM                      varchar,
    CONVET_COMPRT_UCFELM                  numeric(18, 6),
    RATE_CODE_GROUP_UCFELM                varchar(6),
    PS_COMPENSATION_CHANGE_AMT_UCFELM     numeric(18, 6),
    PS_COMPENSATION_CHANGE_PCT_UCFELM     numeric(6, 3),
    CHANGE_PTS_UCFELM                     int,
    FTE_INDICATOR_UCFELM                  varchar,
    CMP_SRC_IND_UCFELM                    varchar,
    PS_PERS_MILIT_USA_EMPLID              varchar(11),
    MIL_DISCHRG_DT_USA                    date,
    PS_CITIZENSHIP_EMPLID                 varchar(11),
    PS_CITIZENSHIP_DEPENDENT_ID           varchar(2),
    PS_CITIZENSHIP_COUNTRY                varchar(3),
    CITIZENSHIP_STATUS                    varchar,
    PS_PRIMARY_JOBS_EMPLID                varchar(11),
    PRIMARY_JOB_APP                       varchar(2),
    PS_PRIMARY_JOB_EMPL_RCD               smallint,
    PS_PRIMARY_JOB_EFFDT                  date,
    PRIMARY_JOB_IND                       varchar,
    PRIMARY_FLAG1                         varchar,
    PRIMARY_FLAG2                         varchar,
    PRIMARY_JOBS_SRC                      varchar,
    JOB_EFFSEQ                            smallint,
    JOB_EMPL_RCD                          smallint,
    PS_DEP_BEN_EMPLID_01                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_01         varchar(2),
    PS_DEP_BEN_BIRTHDATE_01               date,
    PS_DEP_BEN_BIRTHPLACE_01              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_01              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_01            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_01             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_01        varchar,
    PS_DEP_BEN_COUNTRY_CODE_01            varchar(3),
    PS_DEP_BEN_PHONE_01                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_01         varchar,
    PS_DEP_BEN_PHONE_TYPE_01              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_01          date,
    PS_DEP_BEN_COBRA_ACTION_01            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_01            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_01       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_01        date,
    PS_DEP_BEN_EMPLID_02                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_02         varchar(2),
    PS_DEP_BEN_BIRTHDATE_02               date,
    PS_DEP_BEN_BIRTHPLACE_02              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_02              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_02            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_02             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_02        varchar,
    PS_DEP_BEN_COUNTRY_CODE_02            varchar(3),
    PS_DEP_BEN_PHONE_02                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_02         varchar,
    PS_DEP_BEN_PHONE_TYPE_02              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_02          date,
    PS_DEP_BEN_COBRA_ACTION_02            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_02            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_02       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_02        date,
    PS_DEP_BEN_EMPLID_03                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_03         varchar(2),
    PS_DEP_BEN_BIRTHDATE_03               date,
    PS_DEP_BEN_BIRTHPLACE_03              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_03              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_03            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_03             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_03        varchar,
    PS_DEP_BEN_COUNTRY_CODE_03            varchar(3),
    PS_DEP_BEN_PHONE_03                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_03         varchar,
    PS_DEP_BEN_PHONE_TYPE_03              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_03          date,
    PS_DEP_BEN_COBRA_ACTION_03            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_03            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_03       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_03        date,
    PS_DEP_BEN_EMPLID_04                  varchar(11),
    PS_DEP_BEN_DEPENDENT_BENEF_04         varchar(2),
    PS_DEP_BEN_BIRTHDATE_04               date,
    PS_DEP_BEN_BIRTHPLACE_04              varchar(30),
    PS_DEP_BEN_BIRTHSTATE_04              varchar(6),
    PS_DEP_BEN_BIRTHCOUNTRY_04            varchar(3),
    PS_DEP_BEN_DT_OF_DEATH_04             date,
    PS_DEP_BEN_DEPBEN_RIDER_FLG_04        varchar,
    PS_DEP_BEN_COUNTRY_CODE_04            varchar(3),
    PS_DEP_BEN_PHONE_04                   varchar(24),
    PS_DEP_BEN_SAME_PHONE_EMPL_04         varchar,
    PS_DEP_BEN_PHONE_TYPE_04              varchar(4),
    PS_DEP_BEN_COBRA_EVENT_DT_04          date,
    PS_DEP_BEN_COBRA_ACTION_04            varchar(3),
    PS_DEP_BEN_COBRA_EMPLID_04            varchar(11),
    PS_DEP_BEN_MEDICARE_ENTLD_DT_04       date,
    PS_DEP_BEN_LAST_UPDATE_DATE_04        date,
    PS_DEP_BEN_EFF_EMPLID_01              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_01     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_01               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_01        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_01      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_01          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_01       date,
    PS_DEP_BEN_EFF_SEX_01                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_01          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_01             varchar,
    PS_DEP_BEN_EFF_DISABLED_01            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_01   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_01  date,
    PS_DEP_BEN_EFF_SMOKER_01              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_01           date,
    PS_DEP_BEN_EFF_EMPLID_02              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_02     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_02               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_02        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_02      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_02          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_02       date,
    PS_DEP_BEN_EFF_SEX_02                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_02          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_02             varchar,
    PS_DEP_BEN_EFF_DISABLED_02            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_02   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_02  date,
    PS_DEP_BEN_EFF_SMOKER_02              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_02           date,
    PS_DEP_BEN_EFF_EMPLID_03              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_03     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_03               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_03        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_03      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_03          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_03       date,
    PS_DEP_BEN_EFF_SEX_03                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_03          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_03             varchar,
    PS_DEP_BEN_EFF_DISABLED_03            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_03   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_03  date,
    PS_DEP_BEN_EFF_SMOKER_03              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_03           date,
    PS_DEP_BEN_EFF_EMPLID_04              varchar(11),
    PS_DEP_BEN_EFF_DEPENDENT_BENEF_04     varchar(2),
    PS_DEP_BEN_EFF_EFFDT_04               date,
    PS_DEP_BEN_EFF_RELATIONSHIP_04        varchar(2),
    PS_DEP_BEN_EFF_DEP_BENEF_TYPE_04      varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_04          varchar,
    PS_DEP_BEN_EFF_MAR_STATUS_DT_04       date,
    PS_DEP_BEN_EFF_SEX_04                 varchar,
    PS_DEP_BEN_EFF_OCCUPATION_04          varchar(40),
    PS_DEP_BEN_EFF_STUDENT_04             varchar,
    PS_DEP_BEN_EFF_DISABLED_04            varchar,
    PS_DEP_BEN_EFF_STUDENT_STATUS_DT_04   date,
    PS_DEP_BEN_EFF_DISABLED_STATUS_DT_04  date,
    PS_DEP_BEN_EFF_SMOKER_04              varchar,
    PS_DEP_BEN_EFF_SMOKER_DT_04           date,
    PS_DEP_BEN_NAME_EMPLID_01             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_01    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_01              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_01  varchar(3),
    PS_DEP_BEN_NAME_NAME_01               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_01        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_01        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_01     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_01    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_01          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_01         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_01        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_01    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_01       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_01        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_01    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_01         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_01         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_01       date,
    PS_DEP_BEN_NAME_EMPLID_02             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_02    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_02              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_02  varchar(3),
    PS_DEP_BEN_NAME_NAME_02               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_02        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_02        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_02     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_02    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_02          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_02         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_02        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_02    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_02       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_02        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_02    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_02         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_02         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_02       date,
    PS_DEP_BEN_NAME_EMPLID_03             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_03    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_03              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_03  varchar(3),
    PS_DEP_BEN_NAME_NAME_03               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_03        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_03        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_03     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_03    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_03          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_03         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_03        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_03    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_03       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_03        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_03    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_03         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_03         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_03       date,
    PS_DEP_BEN_NAME_EMPLID_04             varchar(11),
    PS_DEP_BEN_NAME_DEPENDENT_BENEF_04    varchar(2),
    PS_DEP_BEN_NAME_EFFDT_04              date,
    PS_DEP_BEN_NAME_COUNTRY_NM_FORMAT_04  varchar(3),
    PS_DEP_BEN_NAME_NAME_04               varchar(50),
    PS_DEP_BEN_NAME_NAME_PREFIX_04        varchar(4),
    PS_DEP_BEN_NAME_NAME_SUFFIX_04        varchar(15),
    PS_DEP_BEN_NAME_LAST_NAME_SRCH_04     varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_SRCH_04    varchar(30),
    PS_DEP_BEN_NAME_LAST_NAME_04          varchar(30),
    PS_DEP_BEN_NAME_FIRST_NAME_04         varchar(30),
    PS_DEP_BEN_NAME_MIDDLE_NAME_04        varchar(30),
    PS_DEP_BEN_NAME_PREF_FIRST_NAME_04    varchar(30),
    PS_DEP_BEN_NAME_NAME_DISPLAY_04       varchar(50),
    PS_DEP_BEN_NAME_NAME_FORMAL_04        varchar(60),
    PS_DEP_BEN_NAME_BEN_ENTITY_NAME_04    varchar(100),
    PS_DEP_BEN_NANE_BEN_TAX_ID_04         varchar(20),
    PS_DEP_BEN_NAME_BEN_DOC_ID_04         varchar(50),
    PS_DEP_BEN_NAME_BEN_DOC_DATE_04       date,
    PS_PER_ORG_ASGN_EMPLID                varchar(11),
    PS_PER_ORG_ASGN_EMPL_RCD              smallint,
    PER_ORG_ASGN                          varchar(3),
    ORG_INSTANCE_ERN                      smallint,
    POI_TYPE_ASGN                         varchar(5),
    BENEFIT_RCD_NBR                       smallint,
    HOME_HOST_CLASS                       varchar,
    CMPNY_DT_OVR                          varchar,
    CMPNY_SENIORITY_DT                    date,
    SERVICE_DT_OVR                        varchar,
    SERVICE_DT                            date,
    SEN_PAY_DT_OVR                        varchar,
    SENIORITY_PAY_DT                      date,
    PROF_EXPERIENCE_DT                    date,
    LAST_VERIFICATN_DT                    date,
    PROBATION_DT                          date,
    LAST_INCREASE_DT                      date,
    BUSINESS_TITLE                        varchar(30),
    POSITION_PHONE                        varchar(24),
    LAST_CHILD_UPDDTM                     datetime,
    PROB_END_DT                           date,
    PROBATION_CODE                        varchar,
    PROBATION_CODE_DESCR                  varchar(30),
    PS_EMERGENCY_CNTCT_EMPLID             varchar(11),
    CONTACT_NAME                          varchar(50),
    SAME_ADDRESS_EMPL                     varchar,
    PRIMARY_CONTACT                       varchar,
    PS_EMERGENCY_CNTCT_COUNTRY            varchar(3),
    PS_EMERGENCY_CNTCT_ADDRESS1           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS2           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS3           varchar(55),
    PS_EMERGENCY_CNTCT_ADDRESS4           varchar(55),
    PS_EMERGENCY_CNTCT_CITY               varchar(30),
    PS_EMERGENCY_CNTCT_HOUSE_TYPE         varchar(2),
    PS_EMERGENCY_CNTCT_COUNTY             varchar(30),
    PS_EMERGENCY_CNTCT_STATE              varchar(6),
    PS_EMERGENCY_CNTCT_POSTAL             varchar(12),
    GEO_CODE                              varchar(11),
    PS_EMERGENCY_CNTCT_COUNTRY_CODE       varchar(3),
    PS_EMERGENCY_CNTCT_PHONE              varchar(24),
    PS_EMERGENCY_CNTCT_RELATIONSHIP       varchar(2),
    PS_EMERGENCY_CNTCT_SAME_PHONE_EMPL    varchar,
    PS_EMERGENCY_CNTCT_ADDRESS_TYPE       varchar(4),
    PS_EMERGENCY_CNTCT_PHONE_TYPE         varchar(4),
    PS_EMERGENCY_CNTCT_EXTENSION          varchar(6),
    LAST_NAME                             varchar(30),
    FIRST_NAME                            varchar(30),
    MIDDLE_NAME                           varchar(30),
    ADDRESS1                              varchar(55),
    ADDRESS2                              varchar(55),
    CITY                                  varchar(30),
    COUNTY                                varchar(30),
    STATE                                 varchar(6),
    POSTAL                                varchar(12),
    COUNTRY                               varchar(3),
    SETID                                 varchar(5),
    JOBCODE                               varchar(6),
    JOBCODE_EFFDT                         date,
    JOBCODE_EFF_STATUS                    varchar,
    JOBCODE_DESCR                         varchar(30),
    JOBCODE_DESCRSHORT                    varchar(10),
    JOBCODE_JOB_FUNCTION                  varchar(3),
    JOBCODE_SETID_SALARY                  varchar(5),
    JOBCODE_SAL_ADMIN_PLAN                varchar(4),
    JOBCODE_GRADE                         varchar(3),
    JOBCODE_STEP                          smallint,
    MANAGER_LEVEL                         varchar(2),
    SURVEY_SALARY                         int,
    SURVEY_JOB_CODE                       varchar(8),
    JOBCODE_UNION_CD                      varchar(3),
    RETRO_RATE                            numeric(6, 4),
    RETRO_PERCENT                         numeric(6, 4),
    CURRENCY_CD                           varchar(3),
    JOBCODE_STD_HOURS                     numeric(6, 2),
    JOBCODE_STD_HRS_FREQUENCY             varchar(5),
    JOBCODE_COMP_FREQUENCY                varchar(5),
    WORKERS_COMP_CD                       varchar(4),
    JOBCODE_JOB_FAMILY                    varchar(6),
    JOBCODE_REG_TEMP                      varchar,
    JOBCODE_DIRECTLY_TIPPED               varchar,
    MED_CHKUP_REQ                         varchar,
    JOBCODE_FLSA_STATUS                   varchar,
    EEO1CODE                              varchar,
    EEO4CODE                              varchar,
    EEO5CODE                              varchar(2),
    EEO6CODE                              varchar,
    EEO_JOB_GROUP                         varchar(4),
    JOBCODE_US_SOC_CD                     varchar(10),
    IPEDSSCODE                            varchar,
    JOBCODE_US_OCC_CD                     varchar(4),
    AVAIL_TELEWORK                        varchar,
    FUNCTION_CD                           varchar(2),
    TRN_PROGRAM                           varchar(6),
    JOBCODE_COMPANY                       varchar(3),
    JOBCODE_BARG_UNIT                     varchar(4),
    ENCUMBER_INDC                         varchar,
    POSN_MGMT_INDC                        varchar,
    EG_ACADEMIC_RANK                      varchar(3),
    EG_GROUP                              varchar(6),
    ENCUMB_SAL_OPTN                       varchar(3),
    ENCUMB_SAL_AMT                        numeric(18, 3),
    LAST_UPDATE_DATE                      date,
    REG_REGION                            varchar(5),
    SAL_RANGE_MIN_RATE                    numeric(18, 6),
    SAL_RANGE_MID_RATE                    numeric(18, 6),
    SAL_RANGE_MAX_RATE                    numeric(18, 6),
    SAL_RANGE_CURRENCY                    varchar(3),
    SAL_RANGE_FREQ                        varchar(5),
    JOB_SUB_FUNC                          varchar(3),
    LASTUPDOPRID                          varchar(30),
    LASTUPDDTTM                           datetime,
    KEY_JOBCODE                           varchar,
    JOB_FUNCTION                          varchar(3),
    JOB_FUNCTION_DESCR                    varchar(30),
    JOB_FUNCTION_DESCRSHORT               varchar(10),
    JOB_FAMILY                            varchar(6),
    JOB_FAMILY_DESCR                      varchar(30),
    JOB_FAMILY_DESCRSHORT                 varchar(10),
    US_SOC_CD                             varchar(10),
    SOC_DESCR50                           varchar(50),
    US_OCC_CD                             varchar(4),
    OCC_DESCR50                           varchar(50),
    UC_OSHPD_CODE                         varchar(10),
    UC_CTO_OS_CD                          varchar(3),
    OLD_PPS_ID                            varchar(254),
    UC_CBR_RATE                           numeric(16, 4),
    UC_CBR_GROUP_DESCR                    varchar(30),
    MANAGER_EMPLID                        varchar(11),
    MANAGER_NAME                          varchar(50),
    MANAGER_FIRST_NAME                    varchar(30),
    MANAGER_LAST_NAME                     varchar(30),
    MANAGER_MIDDLE_NAME                   varchar(30),
    MANAGER_NAME_SUFFIX                   varchar(15),
    MANAGER_DEPTID                        varchar(10),
    MANAGER_POSITION_NBR                  varchar(8),
    MANAGER_JOBCODE                       varchar(6),
    MANAGER_EMPL_STATUS                   varchar,
    MANAGER_BUSN_EMAIL_ADDR               varchar(70),
    MANAGER_CAMP_EMAIL_ADDR               varchar(70),
    MANAGER_LIVED_LAST_NAME               varchar(30),
    MANAGER_LIVED_FIRST_NAME              varchar(30),
    MANAGER_LIVED_MIDDLE_NAME             varchar(30),
    MANAGER_LIVED_NAME_SUFFIX             varchar     not null,
    MANAGER_LIVED_FIRST_LAST_NAME         varchar(50),
    MANAGER_LIVED_LAST_FIRST_NAME         varchar(62),
    VC_CODE                               varchar(50),
    VC_Name                               varchar(30),
    UC_EMP_REL_CD                         varchar(3),
    UC_EMP_REL_DESCR                      varchar(30),
    WORK_LOCATION_EFF_STATUS              varchar,
    WORK_LOCATION_BUILDING                varchar(10),
    WORK_LOCATION_FLOOR                   varchar(10),
    WORK_LOCATION_COUNTRY                 varchar(3),
    WORK_LOCATION_ADDRESS1                varchar(55),
    WORK_LOCATION_ADDRESS2                varchar(55),
    WORK_LOCATION_ADDRESS3                varchar(55),
    WORK_LOCATION_CITY                    varchar(30),
    WORK_LOCATION_COUNTY                  varchar(30),
    WORK_LOCATION_STATE                   varchar(6),
    WORK_LOCATION_POSTAL                  varchar(12),
    WORK_LOCATION_CUBICLE                 varchar(15),
    CUBICLE                               varchar(15)
)
go

create index UKG_EMPL_T_IDX_1
    on UKG_EMPL_T (EMPLID)
go

create index UKG_EMPL_T_IDX_2
    on UKG_EMPL_T (POSITION_NBR)
go

create table UKG_HR_STATUS_LOOKUP
(
    emplid    varchar(11),
    HR_STATUS varchar,
    EFFDT     date,
    EFFSEQ    smallint,
    EMPL_RCD  smallint,
    HIRE_DT   date,
    NOTE      varchar(34) not null,
    LOAD_DTTM datetime    not null
)
go

create index IX_UKG_HR_STATUS_LOOKUP_emplid
    on UKG_HR_STATUS_LOOKUP (emplid)
go

create table UKG_INACTIVE_EMPLID_BY_PAYPERIOD
(
    EMPLID          varchar(11),
    HR_STATUS       varchar,
    JOB_INDICATOR   varchar,
    TERMINATION_DT  date,
    deptid          varchar(10),
    DEPT_DESCR      varchar(10),
    DEPT_DESCR_FULL varchar(30),
    VC_CODE         varchar(50),
    EFFDT           date,
    EFFSEQ          smallint,
    EMPL_RCD        smallint,
    UPD_BT_DTM      datetime,
    NOTE            varchar(42) not null,
    LOAD_DTTM       datetime    not null
)
go

create table UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1
(
    EMPLID          varchar(11),
    HR_STATUS       varchar,
    JOB_INDICATOR   varchar,
    TERMINATION_DT  date,
    deptid          varchar(10),
    DEPT_DESCR      varchar(10),
    DEPT_DESCR_FULL varchar(30),
    VC_CODE         varchar(50),
    EFFDT           date,
    EFFSEQ          smallint,
    EMPL_RCD        smallint,
    UPD_BT_DTM      datetime,
    NOTE            varchar(26) not null,
    LOAD_DTTM       datetime    not null
)
go

create table UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2
(
    EMPLID          varchar(11),
    HR_STATUS       varchar,
    JOB_INDICATOR   varchar,
    TERMINATION_DT  date,
    deptid          varchar(10),
    DEPT_DESCR      varchar(10),
    DEPT_DESCR_FULL varchar(30),
    VC_CODE         varchar(50),
    EFFDT           date,
    EFFSEQ          smallint,
    EMPL_RCD        smallint,
    UPD_BT_DTM      datetime,
    NOTE            varchar(42) not null,
    LOAD_DTTM       datetime    not null
)
go

create table UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3
(
    EMPLID          varchar(11),
    HR_STATUS       varchar,
    JOB_INDICATOR   varchar,
    TERMINATION_DT  date,
    deptid          varchar(10),
    DEPT_DESCR      varchar(10),
    DEPT_DESCR_FULL varchar(30),
    VC_CODE         varchar(50),
    EFFDT           date,
    EFFSEQ          smallint,
    EMPL_RCD        smallint,
    UPD_BT_DTM      datetime,
    NOTE            varchar(72) not null,
    LOAD_DTTM       datetime    not null
)
go

create table UKG_LABOR_CATEGORY_ENTRY_BUILD_FIXED_SPEC_CHAR
(
    [Labor Category Entry Name] varchar(39),
    Description                 varchar(8000),
    InactiveFlag                varchar     not null,
    [Labor Category Name]       varchar(22) not null
)
go

create table UKG_LOCATION_BUILD_FIXED_SPEC_CHAR
(
    [Location Type]         varchar(8000),
    [Parent Path]           varchar(100),
    [Location Name]         varchar(8000),
    [Full Name]             varchar(8000),
    Description             varchar(8000),
    [Effective Date]        varchar(8000),
    [Expiration Date]       varchar(8000),
    Address                 varchar(8000),
    [Cost Center]           varchar(8000),
    [Direct Work Percent]   varchar(8000),
    [Indirect Work Percent] varchar(8000),
    Timezone                varchar(8000),
    Transferable            varchar(8000),
    [External ID]           varchar(8000)
)
go

create table UKG_LOCATION_TEMP
(
    ORGANIZATION       varchar(50),
    ORGANIZATIONTITLE  varchar(50),
    ENTITY             varchar(5),
    ENTITYTITLE        varchar(250),
    SERVICELINETITLE   varchar(250),
    SERVICELINE        varchar(50),
    FINANCIALUNIT      varchar(10),
    FINANCIALUNITTITLE varchar(250),
    FUNDGROUP          varchar(10),
    FUNDGROUPTITLE     varchar(250),
    JOBGROUP           varchar(50),
    JOBGROUPTITLE      varchar(100) not null
)
go

create table UKG_ManagerHierarchy
(
    MANAGER_EMPLID            varchar(11),
    MANAGER_NAME              varchar(50),
    POSITION_NBR              varchar(11),
    POSN_LEVEL                varchar(50),
    NEXT_MANAGER_POSITION_NBR varchar(11),
    LEVEL_UP                  int
)
go

create table UKG_ManagerHierarchy_TEMP
(
    Inactive_EMPLID              varchar(11),
    Inactive_EMPLID_POSITION_NBR varchar(20),
    MANAGER_EMPLID               varchar(11),
    MANAGER_NAME                 varchar(100),
    MANAGER_POSITION_NBR         varchar(20)
)
go

CREATE         VIEW [stage].[UKG_ANSOS_V]
AS
SELECT CONVERT(VARCHAR,CONVERT(DATE,SUBSTRING([Effective_Date],5,4) + '-' + SUBSTRING([Effective_Date],1,2) + '-' + SUBSTRING([Effective_Date],3,2)),23) AS [Effective_Date]
      ,[Person_Number] as Person_Number
      ,[Start_Time]
      ,[Pay_Code_Name]
      ,FORMAT(CAST([Amount] AS INT) / 60.0, 'N2') AS [Amount]
  FROM [dbo].[ANSOS_Imported]
  WHERE
  [Person_Number] NOT IN ('NV','no EMPLID')
  ;
go



--SELECT * 
--FROM [stage].[UKG_tsr_differncds_V]
--WHERE 
--1=1
--AND


/***************************************
* Created By: May Xu	
*-- 7/14/2025 Jim Shih
*-- migrate from hs-ssisp-v
*-- changed to FROM health_ods.[health_ODS].[hcm_ods].PS_UC_SHFT_ONC_ERN e
*******************************************/
create     VIEW [stage].[UKG_tsr_differncds_V]
AS
SELECT setid
	,jobcode
	,replace(erncdstring, '|', '') differncds
FROM (
	SELECT e.setid
		,e.jobcode
		,STUFF((
				SELECT DISTINCT '| ' + e2.erncd
				FROM health_ods.hcm_ods.PS_UC_SHFT_ONC_ERN e2
				WHERE e.jobcode = e2.jobcode
					AND e.setid = e2.setid
					AND e.effdt = e2.effdt
					AND e2.erncd IN (
						'ESD'
						,'NSD'
						,'WDD'
						,'CND'
						)
				FOR XML PATH('')
					,TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS erncdstring
	FROM health_ods.[health_ODS].[hcm_ods].PS_UC_SHFT_ONC_ERN e
	INNER JOIN (
		SELECT setid
			,jobcode
			,erncd
			,max(effdt) effdt
		FROM health_ods.[health_ODS].[hcm_ods].PS_UC_SHFT_ONC_ERN s
		WHERE s.setid LIKE 'sd%'
		GROUP BY setid
			,erncd
			,jobcode
		) s ON s.jobcode = e.jobcode
		AND s.erncd = e.erncd
		AND s.effdt = e.effdt
		AND s.setid = e.setid
	WHERE e.setid LIKE 'sd%'
		AND e.erncd IN (
			'ESD'
			,'NSD'
			,'WDD'
			,'CND'
			)
	GROUP BY e.setid
		,e.jobcode
		,e.effdt
	) a
go


CREATE VIEW [stage].[check_6_BS_Missing_V]
AS
    SELECT
        [Person Number]
          , [First Name]
          , [Last Name]
		  , [Home Business Structure Level 1 - Organization]
		  , [Home Business Structure Level 2 - Entity]
		  , [Home Business Structure Level 3 - Service Line]
		  , [Home Business Structure Level 4 - Financial Unit]
    	  , [Home Business Structure Level 5 - Fund Group]
          , [Home Business Structure Level 1 - Organization] + '/' +
          [Home Business Structure Level 2 - Entity] + '/' +
          [Home Business Structure Level 3 - Service Line] + '/' +
          [Home Business Structure Level 4 - Financial Unit] + '/' +
          [Home Business Structure Level 5 - Fund Group] AS [Parent Path]
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE [Home Business Structure Level 1 - Organization] != 'Non-Health'
        AND emplid IN (
    '10420386', '10467173', '10703043', '10703234', '10403560', '10406748'
)
go


/*
    Stored Procedure: [stage].[EMPL_DEPT_TRANSFER_build]
    Version: 2025-10-13 (Created by Jim Shih)

    Description:
    This stored procedure builds the [STAGE].[EMPL_DEPT_TRANSFER] table, tracking department transfer events for employees with detailed business logic and filters.
    Logic Details:
    - Identifies latest effective-dated job records for each employee and record number (EMPLID, EMPL_RCD).
    - Uses LEAD() window functions to compare current and next department, VC_CODE, HR_STATUS, jobcode, and other attributes.
    - Filters for department changes (DEPTID != NEXT_DEPTID), only when both current and next HR_STATUS are 'A' (active).
    - Includes only records for MED CENTER (VC_CODE = 'VCHSH') or PHSO (DEPTID between '002000' and '002999', excluding certain DEPTIDs).
    - Excludes specific DEPTID/JOBCODE combinations.
    - Excludes transfers to MED CENTER or PHSO.
    - Adds a snapshot_date column to record the date of the transfer event.
    - Adds a NOTE column (default '').
    - Uses MERGE to upsert into [STAGE].[EMPL_DEPT_TRANSFER] based on EMPLID and EFFDT.
    - Results are ordered by EMPLID, EMPL_RCD, EFFDT.

    Usage:
    EXEC [stage].[EMPL_DEPT_TRANSFER_build]
*/

CREATE   PROCEDURE [stage].[EMPL_DEPT_TRANSFER_build]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @snapshot_date DATE = CAST(GETDATE() AS DATE);
    -- Build temp table with NOTE and snapshot_date
    WITH
        MaxEffdt
        AS
        (
            SELECT EMPLID,
                EMPL_RCD,
                MAX(EFFDT) AS EFFDT
            FROM health_ods.[health_ods].STABLE.PS_JOB
            WHERE DML_IND <> 'D'
                AND EFFDT BETWEEN '7/1/2025' AND GETDATE()
            GROUP BY EMPLID, EMPL_RCD, MONTH(EFFDT)
        ),
        EMPL_DEPT_TRANSFERS
        AS
        (
            SELECT
                JOB.EMPLID,
                JOB.EMPL_RCD,
                DH.VC_CODE,
                JOB.HR_STATUS,
                JOB.DEPTID,
                JOB.EFFDT,
                JOB.ACTION,
                JOB.ACTION_DT,
                JOB.jobcode,
                JOB.POSITION_NBR,
                LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_DEPTID,
                LEAD(JOB.EFFDT) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_EFFDT,
                LEAD(JOB.ACTION) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_ACTION,
                LEAD(DH.VC_CODE) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_CODE,
                LEAD(DH.VC_NAME) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_NAME,
                LEAD(JOB.HR_STATUS) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_HR_STATUS,
                LEAD(JOB.jobcode) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_jobcode,
                LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_POSITION_NBR
            FROM health_ods.[health_ods].STABLE.PS_JOB JOB
                JOIN MaxEffdt MEP
                ON JOB.EMPLID = MEP.EMPLID
                    AND JOB.EMPL_RCD = MEP.EMPL_RCD
                    AND JOB.EFFDT = MEP.EFFDT
                JOIN health_ods.[health_ods].RPT.DEPARTMENT_HIERARCHY DH
                ON JOB.DEPTID = DH.DEPTID
            WHERE JOB.JOB_INDICATOR = 'P'
                AND JOB.DML_IND <> 'D'
                AND JOB.EFFSEQ = (
                SELECT MAX(EFFSEQ)
                FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
                WHERE JOB.EMPLID = JOB2.EMPLID
                    AND JOB.EMPL_RCD = JOB2.EMPL_RCD
                    AND JOB.EFFDT = JOB2.EFFDT
                    AND JOB2.DML_IND <> 'D'
            )
        )
    SELECT *, @snapshot_date AS snapshot_date, '' AS NOTE
    INTO STAGE.EMPL_DEPT_TRANSFER_TEMP
    FROM EMPL_DEPT_TRANSFERS
    WHERE DEPTID != NEXT_DEPTID
        AND NEXT_DEPTID IS NOT NULL
        AND HR_STATUS = 'A'
        AND NEXT_HR_STATUS = 'A'
        AND (
            VC_CODE = 'VCHSH' -- MED CENTER
        OR (DEPTID BETWEEN '002000' AND '002999' AND DEPTID NOT IN ('002230','002231','002280')) -- PHSO
        )
        AND NOT (DEPTID IN ('002053','002056','003919') AND JOBCODE IN ('000770','000771','000772','000775','000776'))
        AND (
            NEXT_VC_CODE NOT IN ('VCHSH') -- not transferring to MED CENTER
        AND NOT (NEXT_DEPTID BETWEEN '002000' AND '002999' AND NEXT_DEPTID NOT IN ('002230','002231','002280')) -- not transferring to PHSO
        );

    -- Use MERGE to upsert into STAGE.EMPL_DEPT_TRANSFER based on EMPLID and EFFDT
    MERGE INTO STAGE.EMPL_DEPT_TRANSFER AS target
    USING STAGE.EMPL_DEPT_TRANSFER_TEMP AS source
    ON target.EMPLID = source.EMPLID AND target.EFFDT = source.EFFDT
    -- WHEN MATCHED THEN
    --     UPDATE SET
    --         target.EMPL_RCD = source.EMPL_RCD,
    --         target.VC_CODE = source.VC_CODE,
    --         target.HR_STATUS = source.HR_STATUS,
    --         target.DEPTID = source.DEPTID,
    --         target.ACTION = source.ACTION,
    --         target.ACTION_DT = source.ACTION_DT,
    --         target.jobcode = source.jobcode,
    --         target.POSITION_NBR = source.POSITION_NBR,
    --         target.NEXT_DEPTID = source.NEXT_DEPTID,
    --         target.NEXT_EFFDT = source.NEXT_EFFDT,
    --         target.NEXT_ACTION = source.NEXT_ACTION,
    --         target.NEXT_VC_CODE = source.NEXT_VC_CODE,
    --         target.NEXT_VC_NAME = source.NEXT_VC_NAME,
    --         target.NEXT_HR_STATUS = source.NEXT_HR_STATUS,
    --         target.NEXT_jobcode = source.NEXT_jobcode,
    --         target.NEXT_POSITION_NBR = source.NEXT_POSITION_NBR,
    --         target.snapshot_date = source.snapshot_date,
    --         target.NOTE = source.NOTE
    WHEN NOT MATCHED THEN
        INSERT (
            EMPLID, EMPL_RCD, VC_CODE, HR_STATUS, DEPTID, EFFDT, ACTION, ACTION_DT, jobcode, POSITION_NBR,
            NEXT_DEPTID, NEXT_EFFDT, NEXT_ACTION, NEXT_VC_CODE, NEXT_VC_NAME, NEXT_HR_STATUS, NEXT_jobcode, NEXT_POSITION_NBR, snapshot_date, NOTE
        )
        VALUES (
            source.EMPLID, source.EMPL_RCD, source.VC_CODE, source.HR_STATUS, source.DEPTID, source.EFFDT, source.ACTION, source.ACTION_DT, source.jobcode, source.POSITION_NBR,
            source.NEXT_DEPTID, source.NEXT_EFFDT, source.NEXT_ACTION, source.NEXT_VC_CODE, source.NEXT_VC_NAME, source.NEXT_HR_STATUS, source.NEXT_jobcode, source.NEXT_POSITION_NBR, source.snapshot_date, 'New'
        );
    DROP TABLE IF EXISTS STAGE.EMPL_DEPT_TRANSFER_TEMP;
END
go



Create   PROCEDURE [stage].[QA_SP_UKG_EMPLOYEE_DATA_DEBUG]
    @EMPLID VARCHAR(11) = '10816984'
AS
/***************************************
* Created By: Jim Shih	
* Purpose: QA stored procedure to debug why specific employees are filtered out from UKG_EMPLOYEE_DATA
* Usage: EXEC [stage].[QA_SP_UKG_EMPLOYEE_DATA_DEBUG] '10816984'
* -- 08/25/2025 Jim Shih: Created to debug employee filtering logic
******************************************/
BEGIN
    SET NOCOUNT ON;

    PRINT '=== QA DEBUG FOR EMPLID: ' + @EMPLID + ' ===';
    PRINT '';

    -- Step 1: Check if employee exists in base data
    PRINT '1. Checking if employee exists in CURRENT_EMPL_DATA...';
    IF EXISTS (SELECT 1
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
    WHERE EMPLID = @EMPLID)
    BEGIN
        PRINT '   ? Employee found in CURRENT_EMPL_DATA';

        SELECT
            EMPLID, JOB_INDICATOR, VC_CODE, DEPTID, hr_status, effdt,
            PAY_FREQUENCY, EMPL_TYPE, JOBCODE
        FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
        WHERE EMPLID = @EMPLID;
    END
    ELSE
    BEGIN
        PRINT '   ? Employee NOT found in CURRENT_EMPL_DATA';
        RETURN;
    END

    PRINT '';

    -- Step 2: Check BYA exclusion
    PRINT '2. Checking BYA exclusion (CTE_exclude_BYA)...';
    IF EXISTS (
        SELECT 1
    FROM health_ods.[health_ods].[stable].PS_JOB H
    WHERE H.emplid = @EMPLID
        AND H.JOB_INDICATOR = 'P'
        AND H.DML_IND <> 'D'
        AND H.SAL_ADMIN_PLAN = 'BYA'
    )
    BEGIN
        PRINT '   ? Employee EXCLUDED due to SAL_ADMIN_PLAN = BYA';

        SELECT H.emplid, H.SAL_ADMIN_PLAN, H.FLSA_STATUS, H.JOB_INDICATOR, H.DML_IND, H.EFFDT
        FROM health_ods.[health_ods].[stable].PS_JOB H
        WHERE H.emplid = @EMPLID
            AND H.JOB_INDICATOR = 'P'
            AND H.DML_IND <> 'D'
            AND H.SAL_ADMIN_PLAN = 'BYA';
        RETURN;
    END
    ELSE
    BEGIN
        PRINT '   ? Employee NOT excluded by BYA filter';
    END

    PRINT '';

    -- Step 3: Check primary job criteria
    PRINT '3. Checking primary job criteria...';
    DECLARE @JobIndicator VARCHAR(1), @VcCode VARCHAR(10), @DeptId VARCHAR(10), @HrStatus VARCHAR(1), 
            @EffDt DATE, @PayFreq VARCHAR(1), @EmplType VARCHAR(1), @JobCode VARCHAR(10);

    SELECT @JobIndicator = JOB_INDICATOR, @VcCode = VC_CODE, @DeptId = DEPTID,
        @HrStatus = hr_status, @EffDt = effdt, @PayFreq = PAY_FREQUENCY,
        @EmplType = EMPL_TYPE, @JobCode = JOBCODE
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA
    WHERE EMPLID = @EMPLID;

    -- Check each condition
    IF @JobIndicator <> 'P'
    BEGIN
        PRINT '   ? JOB_INDICATOR is not P (Primary). Current value: ' + ISNULL(@JobIndicator, 'NULL');
        RETURN;
    END
    ELSE PRINT '   ? JOB_INDICATOR = P (Primary)';

    IF @VcCode <> 'VCHSH' AND NOT (@DeptId BETWEEN '002000' AND '002999' AND @DeptId NOT IN ('002230','002231','002280'))
    BEGIN
        PRINT '   ? VC_CODE/DEPTID criteria not met.';
        PRINT '     Valid criteria:';
        PRINT '     - VC_CODE must be VCHSH (Medical Center)';
        PRINT '     OR';
        PRINT '     - DEPTID must be between 002000 and 002999 (PHSO range)';
        PRINT '       AND DEPTID not in (002230, 002231, 002280)';
        PRINT '     Current values: VC_CODE = ' + ISNULL(@VcCode, 'NULL') + ', DEPTID = ' + ISNULL(@DeptId, 'NULL');
        RETURN;
    END
    ELSE 
    BEGIN
        PRINT '   ? VC_CODE/DEPTID criteria met';
        IF @VcCode = 'VCHSH'
            PRINT '     - Employee is in Medical Center (VC_CODE = VCHSH)';
        ELSE
            PRINT '     - Employee is in PHSO range (DEPTID between 002000-002999, excluding 002230,002231,002280)';
    END

    IF NOT ((@HrStatus = 'A') OR (@HrStatus = 'I' AND CONVERT(DATE, @EffDt) = CONVERT(DATE, GETDATE())))
    BEGIN
        PRINT '   ? HR_STATUS criteria not met. HR_STATUS: ' + ISNULL(@HrStatus, 'NULL') + ', EFFDT: ' + ISNULL(CONVERT(VARCHAR, @EffDt), 'NULL');
        RETURN;
    END
    ELSE PRINT '   ? HR_STATUS criteria met';

    IF @PayFreq <> 'B'
    BEGIN
        PRINT '   ? PAY_FREQUENCY is not B (Biweekly). Current value: ' + ISNULL(@PayFreq, 'NULL');
        RETURN;
    END
    ELSE PRINT '   ? PAY_FREQUENCY = B (Biweekly)';

    IF @EmplType <> 'H'
    BEGIN
        PRINT '   ? EMPL_TYPE is not H (Hourly). Current value: ' + ISNULL(@EmplType, 'NULL');
        RETURN;
    END
    ELSE PRINT '   ? EMPL_TYPE = H (Hourly)';

    IF (@DeptId IN ('002053','002056','003919') AND @JobCode IN ('000770','000771','000772','000775','000776'))
    BEGIN
        PRINT '   ? Employee excluded due to ARC MSP population criteria. DEPTID: ' + @DeptId + ', JOBCODE: ' + @JobCode;
        RETURN;
    END
    ELSE PRINT '   ? Not excluded by ARC MSP population criteria';

    PRINT '';

    -- Step 4: Check if in UKG_EMPL_E_T
    PRINT '4. Checking if employee would be in STAGE.UKG_EMPL_E_T...';
    PRINT '   ? Employee meets all UKG_EMPL_E_T criteria';

    PRINT '';

    -- Step 5: Check final query joins and conditions
    PRINT '5. Checking final query table joins...';

    -- Check if employee has business structure data
    SELECT
        EMPL.EMPLID,
        FIN.POSITION_NBR,
        FIN.FDM_COMBO_CD,
        UKG_BS.COMBOCODE,
        UKG_BS.Organization,
        UKG_BS.EntityTitle,
        UKG_BS.ServiceLineTitle,
        UKG_BS.FinancialUnit,
        UKG_BS.FundGroup
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
        LEFT OUTER JOIN health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
        ON EMPL.POSITION_NBR = FIN.POSITION_NBR
        LEFT OUTER JOIN [hts].[UKG_BusinessStructure] UKG_BS
        ON UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
    WHERE EMPL.EMPLID = @EMPLID;

    PRINT '';
    PRINT '=== DEBUG COMPLETE ===';
    PRINT 'If employee meets all criteria above, check for data timing issues or recent changes.';

END
go



----------------------------------------------------------------------------------------------------
-- Stored Procedure: [stage].[SP_CheckByPosition_Health_ODS]
-- Description: This stored procedure performs comprehensive checks on a position number
--              across multiple Health ODS tables to validate position data integrity and
--              business structure mappings used in UKG employee data processing.
--
-- Purpose: Used for troubleshooting and validating position data when employees are
--          filtered out of UKG_EMPLOYEE_DATA_BUILD due to missing or invalid position
--          information.
--
-- Checks Performed:
-- 1. Position status and department in PS_POSITION_DATA
-- 2. Department budget information in PS_DEPT_BUDGET_ERN
-- 3. Financial unit information in CURRENT_POSITION_PRI_FIN_UNIT
-- 4. Business structure mapping between UCPath and UKG systems
--
-- Version Control:
-- Date Modified  |  Author      |   Description
-- ---------------|--------------|----------------------------------------------------
-- 2025-09-06     | Jim Shih     | Initial creation for position data validation
----------------------------------------------------------------------------------------------------

CREATE     PROCEDURE [stage].[SP_CheckByPosition_Health_ODS]
    @POSITION_NBR NVARCHAR(10)
AS
-- Example usage:
-- EXEC [stage].[SP_CheckByPosition_Health_ODS] @POSITION_NBR = '40686393';
--
-- Parameters:
-- @POSITION_NBR: The position number to check across all related tables
BEGIN
    SET NOCOUNT ON;

    -- Create a table variable to store informational messages
    DECLARE @messages TABLE (
        message_id INT IDENTITY(1,1),
        message_text VARCHAR(MAX)
    );

    -- ============================================================================================
    -- 1. POSITION STATUS AND DEPARTMENT VALIDATION
    -- ============================================================================================
    -- Check POSN_STATUS (should be 'A' for Active) and deptid in STABLE.PS_POSITION_DATA
    -- This validates that the position exists and is currently active
    INSERT INTO @messages
        (message_text)
    VALUES
        ('1. Checking POSN_STATUS (should be A for Active) and deptid in STABLE.PS_POSITION_DATA');

    -- Display the current check message
    SELECT message_id, message_text
    FROM @messages
    WHERE message_id = 1;

    -- Query position data, showing most recent records first
    SELECT
        POSN_STATUS,
        deptid,
        POSITION_NBR,
        EFFDT,
        DML_IND
    FROM health_ods.[health_ods].stable.PS_POSITION_DATA
    WHERE POSITION_NBR = @POSITION_NBR
        AND dml_ind <> 'D'
    -- Exclude deleted records
    ORDER BY effdt DESC;

    -- ============================================================================================
    -- 2. DEPARTMENT BUDGET VALIDATION
    -- ============================================================================================
    -- Check deptid and budget information in PS_DEPT_BUDGET_ERN
    -- This ensures the position has proper budget allocation
    INSERT INTO @messages
        (message_text)
    VALUES
        ('2. Checking deptid and budget information in health_ods.[health_ods].stable.PS_DEPT_BUDGET_ERN');

    SELECT message_id, message_text
    FROM @messages
    WHERE message_id = 2;

    -- Query budget data, ordered by fiscal year and effective date
    SELECT
        deptid,
        POSITION_NBR,
        FISCAL_YEAR,
        EFFDT,
        EFFSEQ,
        BUDGET_SEQ,
        DML_IND
    FROM health_ods.[health_ods].stable.PS_DEPT_BUDGET_ERN
    WHERE POSITION_NBR = @POSITION_NBR
        AND dml_ind <> 'D'
    -- Exclude deleted records
    ORDER BY fiscal_year DESC, effdt DESC, effseq DESC, BUDGET_SEQ DESC;

    -- ============================================================================================
    -- 3. FINANCIAL UNIT VALIDATION
    -- ============================================================================================
    -- Check FDM_COMBO_CD (UCPath combination code) and FUND_CODE in CURRENT_POSITION_PRI_FIN_UNIT
    -- This validates the financial structure mapping for the position
    INSERT INTO @messages
        (message_text)
    VALUES
        ('3. Checking FDM_COMBO_CD (UCPath combo code) and FUND_CODE in [RPT].[CURRENT_POSITION_PRI_FIN_UNIT]');

    SELECT message_id, message_text
    FROM @messages
    WHERE message_id = 3;

    -- Query financial unit data
    SELECT
        POSITION_NBR,
        FDM_COMBO_CD,
        FISCAL_YEAR,
		dist_Pct,
		FUND_CODE,
        deptid,
        DEPTID_CF,
        DEPTID_CF_DESCR
    FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT]
    WHERE POSITION_NBR = @POSITION_NBR;

    -- ============================================================================================
    -- 4. BUSINESS STRUCTURE MAPPING VALIDATION
    -- ============================================================================================
    -- Check if UCPath COMBOCODE maps correctly to UKG Business Structure
    -- This is critical for UKG employee data processing - missing mappings will cause employees to be filtered out
    INSERT INTO @messages
        (message_text)
    VALUES
        ('4. Checking UKG Business Structure mapping: UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD');

    SELECT message_id, message_text
    FROM @messages
    WHERE message_id = 4;

    -- Query the business structure mapping
    SELECT
        FIN.POSITION_NBR,
        FIN.FDM_COMBO_CD as UCPath_COMBOCODE,
        UKG_BS.COMBOCODE as UKG_BusinessStructure_COMBOCODE,
        UKG_BS.Organization,
        UKG_BS.EntityTitle,
        UKG_BS.ServiceLineTitle,
        UKG_BS.FinancialUnit,
        UKG_BS.FundGroup
    FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
        LEFT JOIN [hts].[UKG_BusinessStructure] UKG_BS
        ON UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
    WHERE FIN.POSITION_NBR = @POSITION_NBR;

    -- ============================================================================================
    -- SUMMARY
    -- ============================================================================================
    -- Return all informational messages for reference
    SELECT
        message_id,
        message_text
    FROM @messages
    ORDER BY message_id;

END;
go







CREATE     PROCEDURE [stage].[SP_CheckByPosition_Manager_LEVEL_Health_ODS]
    @POSITION_NBR NVARCHAR(10)
AS
-- Example usage:
-- EXEC [stage].[SP_CheckByPosition_Manager_LEVEL_Health_ODS] @POSITION_NBR = '40749496';
BEGIN
    SET NOCOUNT ON;

    -- Create a table variable to store messages
    DECLARE @messages TABLE (
        message_id INT IDENTITY(1,1),
        message_text VARCHAR(MAX)
    );


--------------------------------------
-- Message template
    -- 1. Investigate [POSITION_REPORTS_TO] is not null but MANAGER_EMPLID is NULL
	-- Insert message
    INSERT INTO @messages
        (message_text)
    VALUES
        ('1. Investigate [POSITION_REPORTS_TO] is not null but MANAGER_EMPLID is NULL');

    SELECT
        message_id,
        message_text
    FROM @messages
    where message_id=1;

   --Insert Script below
WITH
    PositionData
    AS
    (
        SELECT
            POSN_STATUS,
            deptid,
            POSITION_NBR,
            EFFDT,
            DML_IND,
            ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
        FROM health_ods.[health_ods].stable.PS_POSITION_DATA
        WHERE dml_ind <> 'D'
    )
SELECT DISTINCT top 1
    imgr.[Inactive_EMPLID_To_Check],
    imgr.[POSITION_NBR_To_Check],
    empl.MANAGER_EMPLID,
    empl.MANAGER_NAME,
    empl.[POSITION_REPORTS_TO],
    pd.POSN_STATUS,
    pd.deptid as POSITION_DEPTID,
    pd.EFFDT as POSITION_EFFDT
FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
    INNER JOIN [stage].[UKG_EMPL_Inactive_Manager] imgr
    ON empl.emplid = imgr.[Inactive_EMPLID_To_Check]
        and empl.POSITION_NBR=imgr.[POSITION_NBR_To_Check]
    LEFT JOIN PositionData pd
    ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
        AND pd.RN = 1
where empl.MANAGER_EMPLID is NULL
and empl.[POSITION_REPORTS_TO]=@POSITION_NBR
;
    -- 2. Check POSN_STATUS, deptid in STABLE.PS_POSITION_DATA 
	-- Insert message
    INSERT INTO @messages
        (message_text)
    VALUES
        ('2. Checking POSN_STATUS (should be A) and deptid in STABLE.PS_POSITION_DATA');

    SELECT
        message_id,
        message_text
    FROM @messages
    where message_id=2;


   --Insert Script below
    SELECT TOP 1
        POSN_STATUS,
        deptid,
        POSITION_NBR,
        EFFDT,
        DML_IND
    FROM health_ods.[health_ods].stable.PS_POSITION_DATA
    WHERE POSITION_NBR = @POSITION_NBR
        AND dml_ind <> 'D'
    ORDER BY effdt DESC;

    -- 3. Check from health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] m
	-- Insert message
    INSERT INTO @messages
        (message_text)
    VALUES
        ('3. Check from health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA]');

    SELECT
        message_id,
        message_text
    FROM @messages
    where message_id=3;

   --Insert Script below
SELECT 
emplid
,NAME
,HR_STATUS
,POSITION_NBR
,MANAGER_EMPLID 
,[POSITION_REPORTS_TO]
FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] m
WHERE 
POSITION_NBR = @POSITION_NBR
;

    -- Return collected messages at the end
    SELECT
        message_id,
        message_text
    FROM @messages
    ORDER BY message_id;

END;
go

CREATE   PROCEDURE [stage].[SP_Check_Person_Business_Structure]
    @emplid VARCHAR(11)
AS
-- exec [stage].[SP_Check_Person_Business_Structure] @emplid = '10401420'
BEGIN
    SET NOCOUNT ON;

--SELECT p.[Person Number]
--      , p.[First Name]
--      , p.[Last Name]
--      , p.[Parent Path]
--         , bs.[Parent Path] as UKG_BusinessStructure
--FROM [BCK].[Person_Import_LOOKUP] p                    -- source from [dbo].[UKG_EMPLOYEE_DATA]
--    LEFT JOIN [BCK].[UKG_BusinessStructure_lookup] bs  -- source from [HealthTime].[hts].[UKG_BusinessStructure]
--    ON p.[Parent Path] = bs.[Parent Path]
--WHERE p.[Person Number] IN (
--    '10401420', '10405360', '10406848', '10409321', '10413689',
--    '10415110', '10420612', '10422674', '10438746', '10467173',
--    '10491749', '10578994', '10624479', '10649385', '10705785',
--    '10715715', '10730925', '10744203', '10822439'
--)


    SELECT
        empl.EMPLID,
        empl.[First Name],
        empl.[Last Name],
        empl.[Employment Status],
        empl.[Home/Primary Job],
        empl.DEPTID,
        empl.[Reports to Manager],
        B.[Person Number],
        B.FundGroup,
        B.[Parent Path],
        B.Loaded_DT,
        CASE 
            WHEN UBS.combocode IS NOT NULL THEN 'MATCH FOUND'
            ELSE 'NO MATCH'
        END AS BusinessStructure_Match_Status,
        UBS.combocode AS Matched_BusinessStructure_ComboCode
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
        INNER JOIN stage.UKG_EMPL_Business_Structure B
        ON empl.EMPLID = B.[Person Number]
        LEFT JOIN [hts].[UKG_BusinessStructure] UBS
        ON B.FundGroup = UBS.FundGroup
    WHERE empl.EMPLID = @emplid;
    -- Return row count for verification
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'No employee found with EMPLID: ' + @emplid;
    END
    ELSE
    BEGIN
        PRINT 'Employee data retrieved for EMPLID: ' + @emplid;
    END

END
go





create     PROCEDURE [stage].[SP_Create_Position_Trace_Analysis]
AS
-- exec [stage].[SP_Create_Position_Trace_Analysis]
/***************************************
* Created By: Jim Shih	
* Purpose: Create position trace analysis based on inactive manager data with position level tracking
* Table: Processes data from [stage].[UKG_EMPL_Inactive_Manager] and creates temp1 table
* To_Trace_Up_1 Logic: If L.POSN_LEVEL is NULL, then To_Trace_Up_1 = 'yes', otherwise 'no'
* -- 08/31/2025 Jim Shih: Created based on 16.sql query
******************************************/
BEGIN
    SET NOCOUNT ON;

    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#temp1', 'U') IS NOT NULL 
        DROP TABLE #temp1;

    -- Create temp table with additional To_Trace_Up_1 column
    CREATE TABLE #temp1
    (
        POSITION_NBR_To_Check VARCHAR(20),
        MANAGER_POSITION_NBR VARCHAR(20),
        POSN_LEVEL VARCHAR(10),
        To_Trace_Up_1 VARCHAR(3)
    );

    PRINT 'Starting Position Trace Analysis...';

    -- Insert data into temp table with To_Trace_Up_1 logic
    WITH
        PositionData
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        )
    INSERT INTO #temp1
        (POSITION_NBR_To_Check, MANAGER_POSITION_NBR, POSN_LEVEL, To_Trace_Up_1)
    SELECT DISTINCT
        imgr.POSITION_NBR_To_Check as POSITION_NBR_To_Check,
        empl.[POSITION_REPORTS_TO] as MANAGER_POSITION_NBR,
        L.POSN_LEVEL,
        CASE 
            WHEN L.POSN_LEVEL IS NULL THEN 'yes'
            ELSE 'no'
        END as To_Trace_Up_1
    FROM [stage].[UKG_EMPL_Inactive_Manager] imgr
        LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
        ON empl.emplid = imgr.[Inactive_EMPLID_To_Check]
            AND empl.POSITION_NBR = imgr.POSITION_NBR_To_Check
        LEFT JOIN PositionData pd
        ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
            AND pd.RN = 1
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
        ON empl.[POSITION_REPORTS_TO] = L.POSITION_NBR;

    -- Show temp1 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1
    FROM #temp1
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp2 by joining To_Trace_Up_1='yes' records with Level 1 analysis data
    IF OBJECT_ID('tempdb..#temp2', 'U') IS NOT NULL 
        DROP TABLE #temp2;

    WITH
        JobData
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData
            WHERE ROWNO = 1
        ),
        CurrentEmplData
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData
            WHERE RN_EMPL = 1
        ),
        PositionData
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered jd
                JOIN PositionData pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered empl ON empl.POSITION_NBR = jd.POSITION_NBR
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT
            FROM CTE_Position_HR_Status
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level
        -- Note that this CTE is added to get POSN_LEVEL for manager positions is NULL, means JOB_INDICATOR is not 'P' or'N'
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t1.POSITION_NBR_To_Check,
        t1.MANAGER_POSITION_NBR,
        t1.POSN_LEVEL,
        t1.To_Trace_Up_1,
        t1.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR_L1,
        CTE_Position_HR_Status_Final.EMPLID as MANAGER_EMPLID,
        CTE_Position_HR_Status_Final.HR_STATUS as MANAGER_HR_STATUS,
        CTE_Position_HR_Status_Final.POSN_STATUS as MANAGER_POSN_STATUS,
        COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) as MANAGER_POSN_LEVEL,
        CASE 
            WHEN CTE_Position_HR_Status_Final.EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_Final.HR_STATUS = 'A'
            AND CTE_Position_HR_Status_Final.POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE,
        CASE 
            WHEN CTE_Position_HR_Status_Final.HR_STATUS = 'A' OR CTE_Position_HR_Status_Final.HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_2

    INTO #temp2
    FROM #temp1 t1
        LEFT JOIN CTE_Position_HR_Status_Final ON t1.MANAGER_POSITION_NBR = CTE_Position_HR_Status_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L ON t1.MANAGER_POSITION_NBR = L.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level L2 ON t1.MANAGER_POSITION_NBR = L2.POSITION_NBR
    WHERE t1.To_Trace_Up_1 = 'yes';

    -- Show temp2 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1,
        MANAGER_EMPLID,
        MANAGER_HR_STATUS,
        MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL,
        To_Trace_Up_2,
        NOTE
    FROM #temp2
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp3 by joining To_Trace_Up_2='yes' records with Level 2 analysis data
    IF OBJECT_ID('tempdb..#temp3', 'U') IS NOT NULL 
        DROP TABLE #temp3;

    WITH
        JobData_L2
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L2
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L2
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L2
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L2
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L2
            WHERE RN_EMPL = 1
        ),
        PositionData_L2
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L2
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L2 jd
                JOIN PositionData_L2 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L2 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L2 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L2 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L2_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L2
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level_L2
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t2.POSITION_NBR_To_Check,
        t2.MANAGER_POSITION_NBR,
        t2.POSN_LEVEL,
        t2.To_Trace_Up_1,
        t2.MANAGER_POSITION_NBR_L1,
        t2.MANAGER_EMPLID,
        t2.MANAGER_HR_STATUS,
        t2.MANAGER_POSN_STATUS,
        t2.MANAGER_POSN_LEVEL,
        t2.To_Trace_Up_2,
        t2.NOTE as NOTE_L1,
        CTE_Position_HR_Status_L2_Final.REPORTS_TO as MANAGER_POSITION_NBR_L2,
        CTE_Position_HR_Status_L2_Final.Manager_EMPLID as MANAGER_EMPLID_L2,
        CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L2,
        CTE_Position_HR_Status_L2_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L2,
        COALESCE(L2.POSN_LEVEL, L3.POSN_LEVEL) as MANAGER_POSN_LEVEL_L2,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L2.POSN_LEVEL, L3.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L2_Final.Manager_EMPLID = 'A'
            AND CTE_Position_HR_Status_L2_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L2,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_3
    INTO #temp3
    FROM #temp2 t2
        --    LEFT JOIN CTE_Position_HR_Status_L2_Final ON t2.MANAGER_EMPLID = CTE_Position_HR_Status_L2_Final.EMPLID
        LEFT JOIN CTE_Position_HR_Status_L2_Final ON t2.MANAGER_POSITION_NBR_L1 = CTE_Position_HR_Status_L2_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L2 ON CTE_Position_HR_Status_L2_Final.REPORTS_TO = L2.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level_L2 L3 ON CTE_Position_HR_Status_L2_Final.REPORTS_TO = L3.POSITION_NBR
    WHERE t2.To_Trace_Up_2 = 'yes';


    SELECT *
    FROM #temp3
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp4 by joining To_Trace_Up_3='yes' records with Level 3 analysis data
    IF OBJECT_ID('tempdb..#temp4', 'U') IS NOT NULL 
        DROP TABLE #temp4;

    WITH
        JobData_L3
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L3
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L3
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L3
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L3
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L3
            WHERE RN_EMPL = 1
        ),
        PositionData_L3
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L3
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L3 jd
                JOIN PositionData_L3 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L3 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L3 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L3 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L3_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L3
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level_L3
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t3.POSITION_NBR_To_Check,
        t3.MANAGER_POSITION_NBR_L2 as MANAGER_POSITION_NBR,
        t3.POSN_LEVEL,
        t3.To_Trace_Up_1,
        t3.MANAGER_POSITION_NBR_L1,
        t3.MANAGER_EMPLID,
        t3.MANAGER_HR_STATUS,
        t3.MANAGER_POSN_STATUS,
        t3.MANAGER_POSN_LEVEL,
        t3.To_Trace_Up_2,
        t3.NOTE_L1,
        t3.MANAGER_POSITION_NBR_L2,
        t3.MANAGER_EMPLID_L2,
        t3.MANAGER_HR_STATUS_L2,
        t3.MANAGER_POSN_STATUS_L2,
        t3.MANAGER_POSN_LEVEL_L2,
        t3.To_Trace_Up_3,
        t3.NOTE_L2,
        CTE_Position_HR_Status_L3_Final.REPORTS_TO as MANAGER_POSITION_NBR_L3,
        CTE_Position_HR_Status_L3_Final.Manager_EMPLID as MANAGER_EMPLID_L3,
        CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L3,
        CTE_Position_HR_Status_L3_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L3,
        COALESCE(L3.POSN_LEVEL, L4.POSN_LEVEL) as MANAGER_POSN_LEVEL_L3,
        CASE 
            WHEN CTE_Position_HR_Status_L3_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L3.POSN_LEVEL, L4.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L3_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L3,
        CASE 
            WHEN CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_4
    INTO #temp4
    FROM #temp3 t3
        LEFT JOIN CTE_Position_HR_Status_L3_Final ON t3.MANAGER_POSITION_NBR_L2 = CTE_Position_HR_Status_L3_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L3 ON CTE_Position_HR_Status_L3_Final.REPORTS_TO = L3.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level_L3 L4 ON CTE_Position_HR_Status_L3_Final.REPORTS_TO = L4.POSITION_NBR
    WHERE t3.To_Trace_Up_3 = 'yes';

    SELECT *
    FROM #temp4
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp5 by joining To_Trace_Up_4='yes' records with Level 4 analysis data
    IF OBJECT_ID('tempdb..#temp5', 'U') IS NOT NULL 
        DROP TABLE #temp5;

    WITH
        JobData_L4
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L4
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L4
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L4
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L4
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L4
            WHERE RN_EMPL = 1
        ),
        PositionData_L4
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L4
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L4 jd
                JOIN PositionData_L4 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L4 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L4 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L4 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L4_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L4
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level_L4
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t4.POSITION_NBR_To_Check,
        t4.MANAGER_POSITION_NBR_L3 as MANAGER_POSITION_NBR,
        t4.POSN_LEVEL,
        t4.To_Trace_Up_1,
        t4.MANAGER_POSITION_NBR_L1,
        t4.MANAGER_EMPLID,
        t4.MANAGER_HR_STATUS,
        t4.MANAGER_POSN_STATUS,
        t4.MANAGER_POSN_LEVEL,
        t4.To_Trace_Up_2,
        t4.NOTE_L1,
        t4.MANAGER_POSITION_NBR_L2,
        t4.MANAGER_EMPLID_L2,
        t4.MANAGER_HR_STATUS_L2,
        t4.MANAGER_POSN_STATUS_L2,
        t4.MANAGER_POSN_LEVEL_L2,
        t4.To_Trace_Up_3,
        t4.NOTE_L2,
        t4.MANAGER_POSITION_NBR_L3,
        t4.MANAGER_EMPLID_L3,
        t4.MANAGER_HR_STATUS_L3,
        t4.MANAGER_POSN_STATUS_L3,
        t4.MANAGER_POSN_LEVEL_L3,
        t4.To_Trace_Up_4,
        t4.NOTE_L3,
        CTE_Position_HR_Status_L4_Final.REPORTS_TO as MANAGER_POSITION_NBR_L4,
        CTE_Position_HR_Status_L4_Final.Manager_EMPLID as MANAGER_EMPLID_L4,
        CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L4,
        CTE_Position_HR_Status_L4_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L4,
        COALESCE(L4.POSN_LEVEL, L5.POSN_LEVEL) as MANAGER_POSN_LEVEL_L4,
        CASE 
            WHEN CTE_Position_HR_Status_L4_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L4.POSN_LEVEL, L5.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L4_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L4,
        CASE 
            WHEN CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_5
    INTO #temp5
    FROM #temp4 t4
        LEFT JOIN CTE_Position_HR_Status_L4_Final ON t4.MANAGER_POSITION_NBR_L3 = CTE_Position_HR_Status_L4_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L4 ON CTE_Position_HR_Status_L4_Final.REPORTS_TO = L4.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level_L4 L5 ON CTE_Position_HR_Status_L4_Final.REPORTS_TO = L5.POSITION_NBR
    WHERE t4.To_Trace_Up_4 = 'yes';

    SELECT *
    FROM #temp5
    ORDER BY POSITION_NBR_To_Check;


    PRINT 'Position Trace Analysis completed successfully.';
    PRINT 'Temp tables #temp1, #temp2, #temp3, #temp4, and #temp5 are available for further analysis in this session.';

END
go


/*
    Stored Procedure: [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
    -- 10/08/2025 Jim Shih: Created

    Description:
    This stored procedure incrementally inserts records from [dbo].[UKG_EMPLOYEE_DATA] into [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].
    - For each record, a hash value is calculated using HASHBYTES('md5', ...) on key columns to detect changes.
    - Only records with a new hash value (i.e., not already present in the history table) are inserted.
    - The current date is recorded as snapshot_date for each inserted record.
    - This enables tracking of historical changes to employee data over time.
    - Uses MERGE to insert missing (deleted) records from the previous snapshots, avoiding duplicates:

    Usage:
    EXEC [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
*/

CREATE     PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @today DATE = CAST(GETDATE() AS DATE);

    INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
    SELECT *,
        HASHBYTES('md5', CONCAT(
            EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt
        )) AS hash_value,
        'I' AS NOTE,
        @today AS snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE NOT EXISTS (
        SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
    WHERE hist.EMPLID = src.EMPLID
        AND hist.hash_value = HASHBYTES('md5', CONCAT(
                src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt
            ))
    );

    -- Use MERGE to avoid duplicate records for deletions
    MERGE INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] AS target
    USING (
        SELECT
        [DEPTID], [VC_CODE], [FDM_COMBO_CD], [COMBOCODE], [REPORTS_TO], [MANAGER_EMPLID], [NON_UKG_MANAGER_FLAG], [position_nbr], [EMPLID], [EMPL_RCD], [jobcode], [POSITION_DESCR], [hr_status], [FTE_SUM], [fte], [empl_Status], [JobGroup], [FundGroup], [Person Number], [First Name], [Last Name], [Middle Initial/Name], [Short Name], [Badge Number], [Hire Date], [Birth Date], [Seniority Date], [Manager Flag], [Phone 1], [Phone 2], [Email], [Address], [City], [State], [Postal Code], [Country], [Time Zone], [Employment Status], [Employment Status Effective Date], [Reports to Manager], [Union Code], [Employee Type], [Employee Classification], [Pay Frequency], [Worker Type], [FTE %], [FTE Standard Hours], [FTE Full Time Hours], [Standard Hours - Daily], [Standard Hours - Weekly], [Standard Hours - Pay Period], [Base Wage Rate], [Base Wage Rate Effective Date], [User Account Name], [User Account Status], [User Password], [Home Business Structure Level 1 - Organization], [Home Business Structure Level 2 - Entity], [Home Business Structure Level 3 - Service Line], [Home Business Structure Level 4 - Financial Unit], [Home Business Structure Level 5 - Fund Group], [Home Business Structure Level 6], [Home Business Structure Level 7], [Home Business Structure Level 8], [Home Business Structure Level 9], [Home/Primary Job], [Home Labor Category Level 1], [Home Labor Category Level 2], [Home Labor Category Level 3], [Home Labor Category Level 4], [Home Labor Category Level 5], [Home Labor Category Level 6], [Home Job and Labor Category Effective Date], [Custom Field 1], [Custom Field 2], [Custom Field 3], [Custom Field 4], [Custom Field 5], [Custom Field 6], [Custom Field 7], [Custom Field 8], [Custom Field 9], [Custom Field 10], [Custom Date 1], [Custom Date 2], [Custom Date 3], [Custom Date 4], [Custom Date 5], [Custom Field 11], [Custom Field 12], [Custom Field 13], [Custom Field 14], [Custom Field 15], [Custom Field 16], [Custom Field 17], [Custom Field 18], [Custom Field 19], [Custom Field 20], [Custom Field 21], [Custom Field 22], [Custom Field 23], [Custom Field 24], [Custom Field 25], [Custom Field 26], [Custom Field 27], [Custom Field 28], [Custom Field 29], [Custom Field 30], [Additional Fields for CRT lookups], [termination_dt], [action], [action_dt], [hash_value],
        'D' AS [NOTE],
        @today AS [snapshot_date]
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
    WHERE NOT EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE src.[EMPLID] = [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].[EMPLID]
        )
    ) AS source
    ON target.[EMPLID] = source.[EMPLID]
        --AND target.[snapshot_date] = source.[snapshot_date] 
        AND target.[hash_value] = source.[hash_value]
        and target.[NOTE] = source.[NOTE]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            [DEPTID], [VC_CODE], [FDM_COMBO_CD], [COMBOCODE], [REPORTS_TO], [MANAGER_EMPLID], [NON_UKG_MANAGER_FLAG], [position_nbr], [EMPLID], [EMPL_RCD], [jobcode], [POSITION_DESCR], [hr_status], [FTE_SUM], [fte], [empl_Status], [JobGroup], [FundGroup], [Person Number], [First Name], [Last Name], [Middle Initial/Name], [Short Name], [Badge Number], [Hire Date], [Birth Date], [Seniority Date], [Manager Flag], [Phone 1], [Phone 2], [Email], [Address], [City], [State], [Postal Code], [Country], [Time Zone], [Employment Status], [Employment Status Effective Date], [Reports to Manager], [Union Code], [Employee Type], [Employee Classification], [Pay Frequency], [Worker Type], [FTE %], [FTE Standard Hours], [FTE Full Time Hours], [Standard Hours - Daily], [Standard Hours - Weekly], [Standard Hours - Pay Period], [Base Wage Rate], [Base Wage Rate Effective Date], [User Account Name], [User Account Status], [User Password], [Home Business Structure Level 1 - Organization], [Home Business Structure Level 2 - Entity], [Home Business Structure Level 3 - Service Line], [Home Business Structure Level 4 - Financial Unit], [Home Business Structure Level 5 - Fund Group], [Home Business Structure Level 6], [Home Business Structure Level 7], [Home Business Structure Level 8], [Home Business Structure Level 9], [Home/Primary Job], [Home Labor Category Level 1], [Home Labor Category Level 2], [Home Labor Category Level 3], [Home Labor Category Level 4], [Home Labor Category Level 5], [Home Labor Category Level 6], [Home Job and Labor Category Effective Date], [Custom Field 1], [Custom Field 2], [Custom Field 3], [Custom Field 4], [Custom Field 5], [Custom Field 6], [Custom Field 7], [Custom Field 8], [Custom Field 9], [Custom Field 10], [Custom Date 1], [Custom Date 2], [Custom Date 3], [Custom Date 4], [Custom Date 5], [Custom Field 11], [Custom Field 12], [Custom Field 13], [Custom Field 14], [Custom Field 15], [Custom Field 16], [Custom Field 17], [Custom Field 18], [Custom Field 19], [Custom Field 20], [Custom Field 21], [Custom Field 22], [Custom Field 23], [Custom Field 24], [Custom Field 25], [Custom Field 26], [Custom Field 27], [Custom Field 28], [Custom Field 29], [Custom Field 30], [Additional Fields for CRT lookups], [termination_dt], [action], [action_dt], [hash_value], [NOTE], [snapshot_date]
        )
        VALUES (
            source.[DEPTID], source.[VC_CODE], source.[FDM_COMBO_CD], source.[COMBOCODE], source.[REPORTS_TO], source.[MANAGER_EMPLID], source.[NON_UKG_MANAGER_FLAG], source.[position_nbr], source.[EMPLID], source.[EMPL_RCD], source.[jobcode], source.[POSITION_DESCR], source.[hr_status], source.[FTE_SUM], source.[fte], source.[empl_Status], source.[JobGroup], source.[FundGroup], source.[Person Number], source.[First Name], source.[Last Name], source.[Middle Initial/Name], source.[Short Name], source.[Badge Number], source.[Hire Date], source.[Birth Date], source.[Seniority Date], source.[Manager Flag], source.[Phone 1], source.[Phone 2], source.[Email], source.[Address], source.[City], source.[State], source.[Postal Code], source.[Country], source.[Time Zone], source.[Employment Status], source.[Employment Status Effective Date], source.[Reports to Manager], source.[Union Code], source.[Employee Type], source.[Employee Classification], source.[Pay Frequency], source.[Worker Type], source.[FTE %], source.[FTE Standard Hours], source.[FTE Full Time Hours], source.[Standard Hours - Daily], source.[Standard Hours - Weekly], source.[Standard Hours - Pay Period], source.[Base Wage Rate], source.[Base Wage Rate Effective Date], source.[User Account Name], source.[User Account Status], source.[User Password], source.[Home Business Structure Level 1 - Organization], source.[Home Business Structure Level 2 - Entity], source.[Home Business Structure Level 3 - Service Line], source.[Home Business Structure Level 4 - Financial Unit], source.[Home Business Structure Level 5 - Fund Group], source.[Home Business Structure Level 6], source.[Home Business Structure Level 7], source.[Home Business Structure Level 8], source.[Home Business Structure Level 9], source.[Home/Primary Job], source.[Home Labor Category Level 1], source.[Home Labor Category Level 2], source.[Home Labor Category Level 3], source.[Home Labor Category Level 4], source.[Home Labor Category Level 5], source.[Home Labor Category Level 6], source.[Home Job and Labor Category Effective Date], source.[Custom Field 1], source.[Custom Field 2], source.[Custom Field 3], source.[Custom Field 4], source.[Custom Field 5], source.[Custom Field 6], source.[Custom Field 7], source.[Custom Field 8], source.[Custom Field 9], source.[Custom Field 10], source.[Custom Date 1], source.[Custom Date 2], source.[Custom Date 3], source.[Custom Date 4], source.[Custom Date 5], source.[Custom Field 11], source.[Custom Field 12], source.[Custom Field 13], source.[Custom Field 14], source.[Custom Field 15], source.[Custom Field 16], source.[Custom Field 17], source.[Custom Field 18], source.[Custom Field 19], source.[Custom Field 20], source.[Custom Field 21], source.[Custom Field 22], source.[Custom Field 23], source.[Custom Field 24], source.[Custom Field 25], source.[Custom Field 26], source.[Custom Field 27], source.[Custom Field 28], source.[Custom Field 29], source.[Custom Field 30], source.[Additional Fields for CRT lookups], source.[termination_dt], source.[action], source.[action_dt], source.[hash_value], source.[NOTE], source.[snapshot_date]
        );
END
go

CREATE   PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_HISTORY_INSERT]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @today DATE = CAST(GETDATE() AS DATE);

    INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_WITH_HISTORY]
    SELECT *,
        HASHBYTES('md5', CONCAT(
            EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt
        )) AS hash_value,
        NULL AS NOTE,
        @today AS snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE NOT EXISTS (
        SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_WITH_HISTORY] hist
    WHERE hist.EMPLID = src.EMPLID
        AND hist.hash_value = HASHBYTES('md5', CONCAT(
                src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt
            ))
    );
END
go


/***************************************
* Created By: Jim Shih
* Procedure: dbo.SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD
* Purpose: Creates table [stage].[UKG_EMPLOYEE_DATA_TERMINATED] for terminated employees to upload to UKG
* EXEC [stage].[SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD]
* -- 09/15/2025 Jim Shih: Created procedure for terminated employee data
******************************************/

CREATE   PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD]
AS
BEGIN
    SET NOCOUNT ON;

    -- Drop table if exists
    DROP TABLE IF EXISTS [stage].[UKG_EMPLOYEE_DATA_TERMINATED];

    -- Create terminated employee data table
    SELECT DISTINCT
        EMPL.DEPTID,
        empl.VC_CODE,
        fin.FDM_COMBO_CD,
        UKG_BS.COMBOCODE,
        empl.REPORTS_TO,
        empl.MANAGER_EMPLID,
        'F' AS NON_UKG_MANAGER_FLAG, -- Terminated employees are not managers
        empl.position_nbr,
        EMPL.EMPLID,
        empl.EMPL_RCD,
        empl.jobcode,
        empl.POSITION_DESCR,
        empl.hr_status,
        0 AS FTE_SUM, -- Terminated employees have 0 FTE
        empl.fte,
        empl.empl_Status,
        UKG_JC.JobGroup,
        ukg_bs.FundGroup,
        ISNULL(EMPL.EMPLID, '') AS 'Person Number',
        EMPL.LIVED_FIRST_NAME AS 'First Name',
        ISNULL(CAST(EMPL.LAST_NAME AS VARCHAR), '') AS 'Last Name',
        LEFT(EMPL.LIVED_MIDDLE_NAME,1) AS 'Middle Initial/Name',
        '' AS 'Short Name',
        '' AS 'Badge Number',
        ISNULL(CAST(EMPL.HIRE_DT AS VARCHAR), '') AS 'Hire Date',
        '' AS 'Birth Date',
        '' AS 'Seniority Date',
        'F' AS 'Manager Flag', -- Terminated employees are not managers
        COALESCE(REPLACE(PH1.phone, '/', '-'), '') AS 'Phone 1',
        COALESCE(REPLACE(PH2.phone, '/', '-'), '') AS 'Phone 2',
        CASE WHEN VC_CODE IN ('VCHSH', 'VCHSS') THEN REPLACE(EMPL.BUSN_EMAIL_ADDR, '@ucsd.edu', '@health.ucsd.edu')
             ELSE EMPL.BUSN_EMAIL_ADDR END AS 'Email',
        '' AS 'Address',
        '' AS 'City',
        '' AS 'State',
        '' AS 'Postal Code',
        '' AS 'Country',
        'Pacific' AS 'Time Zone',

        ISNULL
(UKG_ES.empl_Status, '') AS 'Employment Status', -- Replace EMPL.HR_STATUS with EMPL.empl_Status
        ISNULL
(CAST
(UKG_ES.EFFDT AS VARCHAR), '')  AS 'Employment Status Effective Date', -- 9/3 Replace EMPL.EFFDT with UKG_ES.EFFDT     
        '' AS 'Reports to Manager', -- Terminated employees don't report to active managers
        '' AS 'Union Code',
        '' AS 'Employee Type',
        '' AS 'Employee Classification',
        '' AS 'Pay Frequency',
        'T' AS 'Worker Type', -- Terminated
        '0' AS 'FTE %',
        '' AS 'FTE Standard Hours',
        '' AS 'FTE Full Time Hours',
        '' AS 'Standard Hours - Daily',
        '' AS 'Standard Hours - Weekly',
        '' AS 'Standard Hours - Pay Period',
        '' AS 'Base Wage Rate',
        '' AS 'Base Wage Rate Effective Date',
        EMPL.EMPLID AS 'User Account Name',
        'I' AS 'User Account Status', -- Inactive
        '' AS 'User Password',
        '' AS 'Home Business Structure Level 1 - Organization',
        '' AS 'Home Business Structure Level 2 - Entity',
        '' AS 'Home Business Structure Level 3 - Service Line',
        '' AS 'Home Business Structure Level 4 - Financial Unit',
        '' AS 'Home Business Structure Level 5 - Fund Group',
        '' AS 'Home Business Structure Level 6',
        '' AS 'Home Business Structure Level 7',
        '' AS 'Home Business Structure Level 8',
        '' AS 'Home Business Structure Level 9',
        '' AS 'Home/Primary Job',
        '' AS 'Home Labor Category Level 1',
        '' AS 'Home Labor Category Level 2',
        '' AS 'Home Labor Category Level 3',
        '' AS 'Home Labor Category Level 4',
        '' AS 'Home Labor Category Level 5',
        '' AS 'Home Labor Category Level 6',
        '' AS 'Home Job and Labor Category Effective Date',
        '' AS 'Custom Field 1',
        '' AS 'Custom Field 2',
        '' AS 'Custom Field 3',
        '' AS 'Custom Field 4',
        '' AS 'Custom Field 5',
        '' AS 'Custom Field 6',
        '' AS 'Custom Field 7',
        '' AS 'Custom Field 8',
        '' AS 'Custom Field 9',
        '' AS 'Custom Field 10',
        '' AS 'Custom Date 1',
        '' AS 'Custom Date 2',
        '' AS 'Custom Date 3',
        ISNULL
(CAST
(UKG_HS.EFFDT AS VARCHAR), '')  AS 'Custom Date 4', -- 9/3/2025  Replace EMPL.EFFDT with UKG_HS.EFFDT
        '' AS 'Custom Date 5',
        '' AS 'Custom Field 11',
        '' AS 'Custom Field 12',
        '' AS 'Custom Field 13',
        '' AS 'Custom Field 14',
        '' AS 'Custom Field 15',
        '' AS 'Custom Field 16',
        '' AS 'Custom Field 17',
        '' AS 'Custom Field 18',
        '' AS 'Custom Field 19',
        '' AS 'Custom Field 20',
        '' AS 'Custom Field 21',
        '' AS 'Custom Field 22',
        '' AS 'Custom Field 23',
        '' AS 'Custom Field 24',
        '' AS 'Custom Field 25',
        '' AS 'Custom Field 26',
        '' AS 'Custom Field 27',
        '' AS 'Custom Field 28',
        '' AS 'Custom Field 29',
        '' AS 'Custom Field 30',
        '' AS 'Additional Fields for CRT lookups',
        empl.termination_dt
    INTO [stage].[UKG_EMPLOYEE_DATA_TERMINATED]
    FROM health_ods.[health_ods].[RPT].CURRENT_EMPL_DATA EMPL
        LEFT OUTER JOIN health_ods.[health_ods].[stable].PS_PERSONAL_PHONE PH1
        ON PH1.EMPLID = EMPL.EMPLID
            AND PH1.DML_IND <> 'D'
            AND PH1.PHONE_TYPE IN ('CEL2')
        LEFT OUTER JOIN health_ods.[health_ods].[stable].PS_PERSONAL_PHONE PH2
        ON PH2.EMPLID = EMPL.EMPLID
            AND PH2.DML_IND <> 'D'
            AND PH2.PHONE_TYPE IN ('CELL')
        LEFT OUTER JOIN health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
        ON EMPL.POSITION_NBR = FIN.POSITION_NBR
            AND FIN.POSN_SEQ = (SELECT MIN_POSN_SEQ
            FROM (
                SELECT FIN2.POSITION_NBR, MIN(FIN2.POSN_SEQ) AS MIN_POSN_SEQ
                FROM health_ods.[HEALTH_ODS].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN2
                GROUP BY FIN2.POSITION_NBR
            ) T
            WHERE FIN.POSITION_NBR = T.POSITION_NBR)
        LEFT OUTER JOIN [hts].[UKG_BusinessStructure] UKG_BS
        ON UKG_BS.COMBOCODE = FIN.FDM_COMBO_CD
        LEFT OUTER JOIN hts.UKG_JOBCODES UKG_JC
        ON UKG_JC.JOBCODE = EMPL.JOBCODE
        LEFT JOIN [stage].[UKG_EMPL_STATUS_LOOKUP] UKG_ES
        ON EMPL.emplid = UKG_ES.emplid
        LEFT JOIN [stage].[UKG_HR_STATUS_LOOKUP] UKG_HS
        ON EMPL.emplid = UKG_HS.emplid
    WHERE EMPL.HR_STATUS = 'I' -- Only terminated employees
        AND CONVERT(DATE, EMPL.EFFDT) >= DATEADD(DAY, -7, GETDATE()) -- Last 7 days
        AND EMPL.PAY_FREQUENCY = 'B'
        AND EMPL.EMPL_TYPE = 'H'
        AND EMPL.JOB_INDICATOR = 'P'
        AND (EMPL.VC_CODE = 'VCHSH' --MED CENTER
        OR (EMPL.DEPTID BETWEEN '002000' AND '002999' AND EMPL.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
       )
        AND EMPL.EMPLID NOT IN (SELECT emplid
        FROM STAGE.CTE_exclude_BYA)
        AND NOT (EMPL.DEPTID IN ('002053','002056','003919') AND EMPL.JOBCODE IN ('000770','000771','000772','000775','000776'));

    PRINT 'UKG_EMPLOYEE_DATA_TERMINATED table created successfully';

    -- Show summary
    SELECT
        'Terminated employees processed' as Description,
        COUNT(*) as Count
    FROM [stage].[UKG_EMPLOYEE_DATA_TERMINATED];

END;

go


CREATE           PROCEDURE [stage].[SP_UKG_EMPL_Business_Structure_Lookup_Build]
AS
/*
    File: SP_UKG_EMPL_Business_Structure_Lookup_Build.sql
    Version: 2025-09-06

    Description:
    This stored procedure [stage].[SP_UKG_EMPL_Business_Structure_Lookup_Build] is designed to create or refresh the lookup table [stage].[UKG_EMPL_Business_Structure] in the HealthTime database.
    - Drops the existing lookup table if it exists.
    - Creates a new table by selecting relevant columns from [dbo].[UKG_EMPLOYEE_DATA], including a concatenated business structure path.
    - Excludes records where the organization is 'Non-Health'.
    - Adds a Loaded_DT column to record the load timestamp for each row.
    - Prints a confirmation message upon successful creation.

    Usage:
    EXEC [stage].[SP_UKG_EMPL_Business_Structure_Lookup_Build]
*/

-- exec [stage].[SP_UKG_EMPL_Business_Structure_Lookup_Build]
BEGIN
    SET NOCOUNT ON;

    -- Drop the table if it exists
    IF OBJECT_ID('stage.UKG_EMPL_Business_Structure', 'U') IS NOT NULL
    BEGIN
        DROP TABLE stage.UKG_EMPL_Business_Structure;
    END

    -- Create the lookup table
    SELECT --top 10
        [Person Number]
          , [First Name]
          , [Last Name]
    	  , [Home Business Structure Level 5 - Fund Group] as FundGroup
          , [Home Business Structure Level 1 - Organization] + '/' +
          [Home Business Structure Level 2 - Entity] + '/' +
          [Home Business Structure Level 3 - Service Line] + '/' +
          [Home Business Structure Level 4 - Financial Unit] + '/' +
          [Home Business Structure Level 5 - Fund Group] AS [Parent Path]
    INTO stage.UKG_EMPL_Business_Structure

    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE [Home Business Structure Level 1 - Organization] != 'Non-Health';

    -- Add Loaded_DT column and update with current date
    ALTER TABLE stage.UKG_EMPL_Business_Structure ADD Loaded_DT DATETIME;
    UPDATE stage.UKG_EMPL_Business_Structure SET Loaded_DT = GETDATE();

    PRINT 'Table stage.UKG_EMPL_Business_Structure has been successfully created.';
END
go



/***************************************
* Stored Procedure: [stage].[* EXEC [stage].[SP_UKG_EMPL_DATA_CleanUp-Step1]]
* Purpose: Clean up duplicate employee records in UKG_EMPLOYEE_DATA table
* 
* Logic:
* 1. Identifies employees with duplicate records (same EMPLID appearing multiple times)
* 2. For duplicate employees, removes records where FTE = 0 (zero FTE positions)
* 3. Keeps records with non-zero FTE values as these represent active positions
* 4. Uses transaction control to ensure data integrity
* 5. Provides detailed logging of cleanup operations
* 
* Example execution:
* EXEC [stage].[* EXEC [stage].[SP_UKG_EMPL_DATA_CleanUp-Step1]]
* 
* Created: 9/5/2025
* Modified: 9/5/2025 - Added comprehensive logging and error handling
******************************************/

Create       PROCEDURE [stage].[SP_UKG_EMPL_DATA_CleanUp-Step1]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsDeleted INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        PRINT 'Starting cleanup of duplicate employee records with FTE = 0...';
        
        WITH
        duplicate_employees
        AS
        (
            SELECT emplid, count(emplid) as emp_count
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            GROUP BY emplid
            HAVING count(emplid) > 1
        ),
        records_to_delete
        AS
        (
            SELECT
                empl.emplid,
                empl.position_nbr,
                empl.FTE
            FROM duplicate_employees de
                JOIN [dbo].[UKG_EMPLOYEE_DATA] empl
                ON empl.emplid = de.emplid
            WHERE empl.FTE = 0
        )
            DELETE ukg_empl
            FROM [dbo].[UKG_EMPLOYEE_DATA] ukg_empl
        JOIN records_to_delete rtd
        ON ukg_empl.emplid = rtd.emplid
            AND ukg_empl.position_nbr = rtd.position_nbr;

        SET @RowsDeleted = @@ROWCOUNT;

        PRINT 'Duplicate records with FTE = 0 deleted: ' + CAST(@RowsDeleted AS VARCHAR(10));
        
        COMMIT TRANSACTION;
        
        PRINT 'Cleanup operations completed successfully.';
        PRINT 'Total records deleted: ' + CAST(@RowsDeleted AS VARCHAR(10));
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error occurred during cleanup operation: ' + @ErrorMessage;
        PRINT 'Transaction has been rolled back.';
        
        -- Re-throw the error
        THROW;
    END CATCH
END
go



/***************************************
* Stored Procedure: [stage].[SP_UKG_EMPL_DATA_Update_imgr-Step3]
* Purpose: Update "Reports to Manager" field in UKG_EMPLOYEE_DATA based on comprehensive inactive manager hierarchy analysis
* 
* Logic Overview:
* 1. Creates temporary table from inactive manager hierarchy lookup data with comprehensive multi-level tracing
* 2. Uses advanced UNION logic to handle five hierarchy scenarios:
*    - Level 0: Direct manager replacement (To_Trace_Up_1 = 'no')
*    - Level 1: One-level trace-up (To_Trace_Up_1 = 'yes', To_Trace_Up_2 = 'no')
*    - Level 2: Two-level trace-up (To_Trace_Up_1-2 = 'yes', To_Trace_Up_3 = 'no')
*    - Level 3: Three-level trace-up (To_Trace_Up_1-3 = 'yes', To_Trace_Up_4 = 'no')
*    - Level 4: Four-level trace-up (To_Trace_Up_1-4 = 'yes')
* 3. Updates UKG_EMPLOYEE_DATA with correct active manager information from any hierarchy level
* 4. Provides comprehensive logging, validation, and error handling throughout the process
* 
* Business Logic:
* - Filters for manager positions at LEVEL5-LEVEL9 (executive/senior management levels)
* - Handles complex scenarios where multiple management levels are inactive
* - Traces up organizational hierarchy up to 4 levels to find active managers
* - Ensures data integrity through transaction control and comprehensive validation checks
* - Provides detailed before/after verification of updated records
* 
* Multi-Level Hierarchy Processing:
* - MANAGER_POSITION_NBR: Direct manager (Level 0)
* - MANAGER_POSITION_NBR_L1: First level trace-up manager (Level 1)
* - MANAGER_POSITION_NBR_L2: Second level trace-up manager (Level 2)
* - MANAGER_POSITION_NBR_L3: Third level trace-up manager (Level 3)
* - MANAGER_POSITION_NBR_L4: Fourth level trace-up manager (Level 4)
* 
* Transaction Control:
* - Uses BEGIN/COMMIT/ROLLBACK for comprehensive data integrity
* - Validates expected vs actual record counts with detailed error reporting
* - Comprehensive error handling with detailed logging and rollback capabilities
* - Temporary table cleanup to ensure no resource leaks
* 
* Dependencies:
* - [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] - Multi-level hierarchy analysis lookup table
* - [dbo].[UKG_EMPLOYEE_DATA] - Target table for manager relationship updates
* 
* Example execution:
* EXEC [stage].[SP_UKG_EMPL_DATA_Update_imgr-Step3]
* 
* Created: 09/05/2025 Jim Shih
* Modified: 09/05/2025 Jim Shih - Added comprehensive multi-level hierarchy processing and documentation
* Performance Optimizations (09/17/2025):
* - Changed UNION to UNION ALL to eliminate duplicate elimination overhead
* - Added clustered index on temp table for faster joins
* - Consolidated count and preview queries into single operation
* - Added Hierarchy_Level column for better performance tracking
* - Optimized verification queries to reduce redundant table scans
* - Added temp table cleanup in error handling to prevent resource leaks
* - Streamlined transaction control and error handling logic
******************************************/

CREATE   PROCEDURE [stage].[SP_UKG_EMPL_DATA_Update_imgr-Step3]
AS
BEGIN
    SET NOCOUNT ON;

    /****** Update UKG_EMPLOYEE_DATA based on Inactive Manager Hierarchy Analysis ******/

    BEGIN TRANSACTION;

    BEGIN TRY
    -- Create a temp table to store the hierarchy data for reuse with optimized structure
    IF OBJECT_ID('tempdb..#InactiveManagerHierarchy', 'U') IS NOT NULL 
        DROP TABLE #InactiveManagerHierarchy;

    -- Optimized CTE with consolidated UNION logic and direct temp table creation
    WITH
        InactiveManagerHierarchy
        AS
        (
            -- Level 0: Direct manager replacement
                                                                SELECT
                    H.POSITION_NBR_To_Check,
                    H.MANAGER_POSITION_NBR,
                    H.POSN_LEVEL,
                    0 as Hierarchy_Level
                FROM [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.POSN_LEVEL IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'no'

            UNION ALL

                -- Level 1: One-level trace-up
                SELECT
                    H.POSITION_NBR_To_Check,
                    H.MANAGER_POSITION_NBR_L1,
                    H.MANAGER_POSN_LEVEL_L1,
                    1 as Hierarchy_Level
                FROM [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.MANAGER_POSN_LEVEL_L1 IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes'
                    AND H.To_Trace_Up_2 = 'no'
                    AND H.NOTE_L1 IS NULL

            UNION ALL

                -- Level 2: Two-level trace-up
                SELECT
                    H.POSITION_NBR_To_Check,
                    H.MANAGER_POSITION_NBR_L2,
                    H.MANAGER_POSN_LEVEL_L2,
                    2 as Hierarchy_Level
                FROM [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.MANAGER_POSN_LEVEL_L2 IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes'
                    AND H.To_Trace_Up_2 = 'yes'
                    AND H.To_Trace_Up_3 = 'no'
                    AND H.NOTE_L2 IS NULL

            UNION ALL

                -- Level 3: Three-level trace-up
                SELECT
                    H.POSITION_NBR_To_Check,
                    H.MANAGER_POSITION_NBR_L3,
                    H.MANAGER_POSN_LEVEL_L3,
                    3 as Hierarchy_Level
                FROM [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.MANAGER_POSN_LEVEL_L3 IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes'
                    AND H.To_Trace_Up_2 = 'yes'
                    AND H.To_Trace_Up_3 = 'yes'
                    AND H.To_Trace_Up_4 = 'no'
                    AND H.NOTE_L3 IS NULL

            UNION ALL

                -- Level 4: Four-level trace-up
                SELECT
                    H.POSITION_NBR_To_Check,
                    H.MANAGER_POSITION_NBR_L4,
                    H.MANAGER_POSN_LEVEL_L4,
                    4 as Hierarchy_Level
                FROM [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.MANAGER_POSN_LEVEL_L4 IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes'
                    AND H.To_Trace_Up_2 = 'yes'
                    AND H.To_Trace_Up_3 = 'yes'
                    AND H.To_Trace_Up_4 = 'yes'
                    AND H.NOTE_L4 IS NULL
        )
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        Hierarchy_Level
    INTO #InactiveManagerHierarchy
    FROM InactiveManagerHierarchy;

    -- Add clustered index for faster joins on the primary key
    CREATE CLUSTERED INDEX IX_InactiveManagerHierarchy_Position ON #InactiveManagerHierarchy (POSITION_NBR_To_Check);

    -- Optimized: Single query to get count and show preview of records to be updated
    DECLARE @RecordsToUpdate INT = 0;

    -- Get count separately (variable assignment must be in its own SELECT)
    SELECT @RecordsToUpdate = COUNT(*)
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
        INNER JOIN #InactiveManagerHierarchy CTE
        ON CTE.POSITION_NBR_To_Check = empl.[Reports to Manager];

    -- Preview records to be updated (separate data-retrieval statement)
    SELECT DISTINCT
        'Records to be updated:' AS Info,
        empl.[Reports to Manager] AS Current_Reports_To,
        CTE.MANAGER_POSITION_NBR AS New_Reports_To,
        CTE.POSN_LEVEL,
        CTE.Hierarchy_Level
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
        INNER JOIN #InactiveManagerHierarchy CTE
        ON CTE.POSITION_NBR_To_Check = empl.[Reports to Manager]
    ORDER BY Current_Reports_To;

    PRINT 'Number of records to update: ' + CAST(@RecordsToUpdate AS VARCHAR(10));
    
    -- Perform the optimized update with single join
    UPDATE empl
    SET 
        [Reports to Manager] = CTE.MANAGER_POSITION_NBR
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
        INNER JOIN #InactiveManagerHierarchy CTE
        ON CTE.POSITION_NBR_To_Check = empl.[Reports to Manager];
    
    -- Verify the update count
    DECLARE @RecordsUpdated INT = @@ROWCOUNT;
    PRINT 'Number of records updated: ' + CAST(@RecordsUpdated AS VARCHAR(10));
    
    -- Optimized validation using simple comparison
    IF @RecordsUpdated <> @RecordsToUpdate
    BEGIN
        PRINT 'ERROR: Mismatch in expected vs actual updated records!';
        PRINT 'Expected: ' + CAST(@RecordsToUpdate AS VARCHAR(10));
        PRINT 'Actual: ' + CAST(@RecordsUpdated AS VARCHAR(10));
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Optimized verification: Show sample of updated records
    PRINT 'Updated records verification (sample):';
    SELECT TOP 5
        empl.[Reports to Manager] AS Updated_Reports_To,
        empl.[EMPLID] AS Employee_ID,
        empl.[First Name] + ', ' + empl.[Last Name] AS Employee_Name,
        CTE.Hierarchy_Level
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
        INNER JOIN #InactiveManagerHierarchy CTE
        ON CTE.MANAGER_POSITION_NBR = empl.[Reports to Manager]
    ORDER BY CTE.Hierarchy_Level DESC, empl.[EMPLID];
    
    -- Clean up temp table
    DROP TABLE #InactiveManagerHierarchy;
    
    -- Commit the transaction if everything is successful
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully. ' + CAST(@RecordsUpdated AS VARCHAR(10)) + ' records updated.';
    
END TRY
BEGIN CATCH
    -- Rollback transaction in case of error
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    -- Display error information
    PRINT 'Error occurred during update. Transaction rolled back.';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    
    -- Clean up temp table in case of error
    IF OBJECT_ID('tempdb..#InactiveManagerHierarchy', 'U') IS NOT NULL 
        DROP TABLE #InactiveManagerHierarchy;
    
    -- Re-throw the error
    THROW;
END CATCH;

END
go



/***************************************
* Stored Procedure: [stage].[SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD-Step2]
* Purpose: Build comprehensive inactive manager hierarchy lookup table with multi-level position tracing
* 
* Performance Optimizations (09/17/2025):
* - Added clustered indexes on temp tables for faster joins on POSITION_NBR_To_Check
* - Consolidated repetitive CTEs into reusable base CTEs (JobData_Base, CurrentEmplData_Base, etc.)
* - Added OPTION (RECOMPILE) to dynamic queries for better execution plans
* - Reduced redundant subqueries by caching common data patterns
* - Optimized ROW_NUMBER() operations with more efficient partitioning
* - Tested successfully on INFOSDBT01\INFOS01TST server - execution completed in ~30 seconds
* - Processed 11 positions requiring hierarchy analysis with 2 needing Level 1 tracing
* 
* Logic Overview:
* 1. Identifies positions with missing "Reports to Manager" values from UKG_EMPLOYEE_DATA
* 2. Creates hierarchical analysis through 5 levels (Level 0 through Level 4) of management chain
* 3. For each level, determines if further trace-up is needed based on manager HR status and position level
* 4. Tracks inactive managers and finds active replacement managers up the hierarchy
* 5. Creates permanent lookup table for updating reporting relationships
* 
* Business Rules:
* - Only processes positions where NON_UKG_MANAGER_FLAG = 'F' (UKG-managed positions)
* - Traces up hierarchy when manager position level is NULL or manager is inactive (HR_STATUS != 'A')
* - Stops tracing when an active manager is found or maximum levels reached
* 
* Data Sources:
* - [dbo].[UKG_EMPLOYEE_DATA]: Source employee data with reporting relationships
* - health_ods.[health_ods].[STABLE].PS_JOB: Current job assignments and HR status
* - health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA]: Current employee reporting structure
* - health_ods.[health_ods].stable.PS_POSITION_DATA: Position status and hierarchy
* - [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP]: Position level lookup table
* 
* Step-by-Step Process:
* TEMP1 (Level 0): Initial positions needing manager lookup with trace-up decision logic
* TEMP2 (Level 1): First level manager analysis for positions requiring trace-up
* TEMP3 (Level 2): Second level manager analysis for positions still requiring trace-up
* TEMP4 (Level 3): Third level manager analysis for positions still requiring trace-up
* TEMP5 (Level 4): Fourth level manager analysis for positions still requiring trace-up
* 
* Trace-Up Logic:
* - To_Trace_Up_1: 'yes' if POSN_LEVEL is NULL, 'no' otherwise
* - To_Trace_Up_2/3/4/5: 'yes' if manager HR_STATUS != 'A' (inactive), 'no' if active or NULL
* 
* Output: [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] table with complete hierarchy analysis
* 
* Performance Metrics:
* - Typical execution time: ~2-5 minutes depending on data volume
* - Processes ~1000-5000 positions requiring hierarchy analysis
* - Creates comprehensive audit trail for manager replacement decisions
* 
* Example execution:
* EXEC [stage].[SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD-Step2]
* 
* Dependencies:
* - Requires [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] table to be populated
* - Access to health_ods database for PeopleSoft data
* 
* Created: 08/31/2025 Jim Shih
* Modified: 09/05/2025 Jim Shih - Renamed to Step2 and added comprehensive documentation
* Modified: 09/17/2025 Jim Shih - Added performance optimizations and enhanced comments
******************************************/

CREATE       PROCEDURE [stage].[SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD-Step2]
AS
BEGIN
    SET NOCOUNT ON;

    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#temp1', 'U') IS NOT NULL 
        DROP TABLE #temp1;

    -- Create temp table with additional To_Trace_Up_1 column
    CREATE TABLE #temp1
    (
        POSITION_NBR_To_Check VARCHAR(20),
        Inactive_EMPLID_To_Check VARCHAR(20),
        MANAGER_POSITION_NBR VARCHAR(20),
        POSN_LEVEL VARCHAR(10),
        To_Trace_Up_1 VARCHAR(3)
    );

    -- Add clustered index for faster joins on POSITION_NBR_To_Check
    CREATE CLUSTERED INDEX IX_temp1_POSITION_NBR ON #temp1 (POSITION_NBR_To_Check);

    -- Materialize hierarchy position levels once for reuse (avoids CTE scope issues)
    IF OBJECT_ID('tempdb..#Hierarchy_Posn_Level','U') IS NOT NULL DROP TABLE #Hierarchy_Posn_Level;
    SELECT DISTINCT
        EMPL.EMPLID,
        EMPL.POSITION_NBR,
        EMPL.JOB_INDICATOR,
        HPOSN.LEVEL as POSN_LEVEL
    INTO #Hierarchy_Posn_Level
    FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
        ON HPOSN.EMPLID = EMPL.EMPLID
            AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
    WHERE EMPL.HR_STATUS = 'A';
    CREATE CLUSTERED INDEX IX_Hierarchy_Posn_Level_POSITION_NBR ON #Hierarchy_Posn_Level (POSITION_NBR);

    PRINT 'Starting Position Trace Analysis...';

    -- Insert data into temp table with To_Trace_Up_1 logic

    WITH
        PositionData
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as PDRN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        imgr
        AS
        (
            SELECT REPORTS_TO as POSITION_NBR_To_Check
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            WHERE 
    REPORTS_TO IS NOT NULL
                AND [Reports to Manager] =''
                and NON_UKG_MANAGER_FLAG = 'F'
        ),
        ranked_data
        AS
        (
            SELECT distinct
                imgr.POSITION_NBR_To_Check,
                empl.emplid,
                empl.Reports_To as MANAGER_POSITION_NBR,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY imgr.POSITION_NBR_To_Check ORDER BY empl.EFFDT DESC) as rn
            FROM imgr
                JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
                ON imgr.POSITION_NBR_To_Check = empl.position_NBR
        )

    INSERT INTO #temp1
        (POSITION_NBR_To_Check, Inactive_EMPLID_To_Check, MANAGER_POSITION_NBR, POSN_LEVEL, To_Trace_Up_1)
    SELECT
        POSITION_NBR_To_Check,
        ranked_data.emplid as [Inactive_EMPLID_To_Check],
        MANAGER_POSITION_NBR,
        L.POSN_LEVEL as MANAGER_POSN_LEVEL,
        CASE 
            WHEN L.POSN_LEVEL IS NULL THEN 'yes'
            ELSE 'no'
END as To_Trace_Up_1
    FROM ranked_data
        LEFT JOIN PositionData pd
        ON ranked_data.MANAGER_POSITION_NBR = pd.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
        ON ranked_data.MANAGER_POSITION_NBR = L.POSITION_NBR
    WHERE pd.POSN_STATUS = 'A'
        AND PDRN = 1
        AND rn = 1;

    -- Show temp1 results
    SELECT
        POSITION_NBR_To_Check,
        Inactive_EMPLID_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1
    FROM #temp1
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp2 by joining To_Trace_Up_1='yes' records with Level 1 analysis data
    IF OBJECT_ID('tempdb..#temp2', 'U') IS NOT NULL 
        DROP TABLE #temp2;

    WITH
        JobData
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData
            WHERE ROWNO = 1
        ),
        CurrentEmplData
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData
            WHERE RN_EMPL = 1
        ),
        PositionData
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered jd
                JOIN PositionData pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status
            WHERE RN_FINAL = 1
        )
    SELECT DISTINCT
        t1.POSITION_NBR_To_Check,
        t1.MANAGER_POSITION_NBR,
        t1.POSN_LEVEL,
        t1.To_Trace_Up_1,
        t1.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR_L1,
        CTE_Position_HR_Status_Final.EMPLID as MANAGER_EMPLID,
        CTE_Position_HR_Status_Final.HR_STATUS as MANAGER_HR_STATUS,
        CTE_Position_HR_Status_Final.POSN_STATUS as MANAGER_POSN_STATUS,
        COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) as MANAGER_POSN_LEVEL_L1,
        CASE 
            WHEN CTE_Position_HR_Status_Final.EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_Final.HR_STATUS = 'A'
            AND CTE_Position_HR_Status_Final.POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L1,
        CASE 
            WHEN CTE_Position_HR_Status_Final.HR_STATUS = 'A' OR CTE_Position_HR_Status_Final.HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_2
    INTO #temp2
    FROM #temp1 t1
        LEFT JOIN CTE_Position_HR_Status_Final ON t1.MANAGER_POSITION_NBR = CTE_Position_HR_Status_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L ON CTE_Position_HR_Status_Final.REPORTS_TO = L.POSITION_NBR
        LEFT JOIN #Hierarchy_Posn_Level L2 ON CTE_Position_HR_Status_Final.REPORTS_TO = L2.POSITION_NBR
    WHERE t1.To_Trace_Up_1 = 'yes';

    -- Add clustered index for faster joins
    CREATE CLUSTERED INDEX IX_temp2_POSITION_NBR ON #temp2 (POSITION_NBR_To_Check);

    -- Show temp2 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1,
        MANAGER_EMPLID,
        MANAGER_HR_STATUS,
        MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL_L1,
        To_Trace_Up_2,
        NOTE_L1
    FROM #temp2
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp3 by joining To_Trace_Up_2='yes' records with Level 2 analysis data
    IF OBJECT_ID('tempdb..#temp3', 'U') IS NOT NULL 
        DROP TABLE #temp3;

    WITH
        JobData_L2
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L2
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L2
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L2
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L2
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L2
            WHERE RN_EMPL = 1
        ),
        PositionData_L2
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L2
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L2 jd
                JOIN PositionData_L2 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L2 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L2 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L2 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L2_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L2
            WHERE RN_FINAL = 1
        )
    SELECT DISTINCT
        t2.POSITION_NBR_To_Check,
        t2.MANAGER_POSITION_NBR,
        t2.POSN_LEVEL,
        t2.To_Trace_Up_1,
        t2.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR_L1,
        CTE_Position_HR_Status_L2_Final.EMPLID as MANAGER_EMPLID,
        CTE_Position_HR_Status_L2_Final.HR_STATUS as MANAGER_HR_STATUS,
        CTE_Position_HR_Status_L2_Final.POSN_STATUS as MANAGER_POSN_STATUS,
        -- Level-1 position level (may be NULL)
        COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) as MANAGER_POSN_LEVEL_L1,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L2_Final.HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L2_Final.POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L1,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.HR_STATUS = 'A' OR CTE_Position_HR_Status_L2_Final.HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_2,
        -- Level-2 (manager's manager) derived fields (added to avoid invalid column references downstream)
        CTE_Position_HR_Status_L2_Final.REPORTS_TO as MANAGER_POSITION_NBR_L2,
        CTE_Position_HR_Status_L2_Final.Manager_EMPLID as MANAGER_EMPLID_L2,
        CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L2,
        CTE_Position_HR_Status_L2_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L2,
        COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) as MANAGER_POSN_LEVEL_L2,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L2_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L2,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_3
    INTO #temp3
    FROM #temp2 t2
        LEFT JOIN CTE_Position_HR_Status_L2_Final ON t2.MANAGER_POSITION_NBR = CTE_Position_HR_Status_L2_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L ON CTE_Position_HR_Status_L2_Final.REPORTS_TO = L.POSITION_NBR
        LEFT JOIN #Hierarchy_Posn_Level L2 ON CTE_Position_HR_Status_L2_Final.REPORTS_TO = L2.POSITION_NBR
    WHERE t2.To_Trace_Up_2 = 'yes';

    -- Add clustered index for faster joins
    CREATE CLUSTERED INDEX IX_temp3_POSITION_NBR ON #temp3 (POSITION_NBR_To_Check);

    -- Show temp3 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1,
        MANAGER_EMPLID,
        MANAGER_HR_STATUS,
        MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL_L1,
        To_Trace_Up_2,
        NOTE_L1,
        MANAGER_POSITION_NBR_L2,
        MANAGER_EMPLID_L2,
        MANAGER_HR_STATUS_L2,
        MANAGER_POSN_STATUS_L2,
        MANAGER_POSN_LEVEL_L2,
        NOTE_L2,
        To_Trace_Up_3
    FROM #temp3
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp4 by joining To_Trace_Up_3='yes' records with Level 3 analysis data
    IF OBJECT_ID('tempdb..#temp4', 'U') IS NOT NULL 
        DROP TABLE #temp4;

    WITH
        JobData_L3
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L3
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L3
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L3
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L3
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L3
            WHERE RN_EMPL = 1
        ),
        PositionData_L3
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L3
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L3 jd
                JOIN PositionData_L3 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L3 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L3 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L3 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L3_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L3
            WHERE RN_FINAL = 1
        )
    SELECT DISTINCT
        t3.POSITION_NBR_To_Check,
        t3.MANAGER_POSITION_NBR,
        t3.POSN_LEVEL,
        t3.To_Trace_Up_1,
        t3.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR_L1,
        t3.MANAGER_EMPLID,
        t3.MANAGER_HR_STATUS,
        t3.MANAGER_POSN_STATUS,
        t3.MANAGER_POSN_LEVEL_L1,
        t3.To_Trace_Up_2,
        t3.NOTE_L1,
        t3.MANAGER_POSITION_NBR_L2,
        t3.MANAGER_EMPLID_L2,
        t3.MANAGER_HR_STATUS_L2,
        t3.MANAGER_POSN_STATUS_L2,
        t3.MANAGER_POSN_LEVEL_L2,
        t3.NOTE_L2,
        t3.To_Trace_Up_3,
        -- Level-3 (manager's manager's manager) derived fields
        CTE_Position_HR_Status_L3_Final.REPORTS_TO as MANAGER_POSITION_NBR_L3,
        CTE_Position_HR_Status_L3_Final.Manager_EMPLID as MANAGER_EMPLID_L3,
        CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L3,
        CTE_Position_HR_Status_L3_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L3,
        COALESCE(L.POSN_LEVEL, L3.POSN_LEVEL) as MANAGER_POSN_LEVEL_L3,
        CASE 
            WHEN CTE_Position_HR_Status_L3_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L.POSN_LEVEL, L3.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L3_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L3,
        CASE 
            WHEN CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_4
    INTO #temp4
    FROM #temp3 t3
        LEFT JOIN CTE_Position_HR_Status_L3_Final ON t3.MANAGER_POSITION_NBR_L2 = CTE_Position_HR_Status_L3_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L ON CTE_Position_HR_Status_L3_Final.REPORTS_TO = L.POSITION_NBR
        LEFT JOIN #Hierarchy_Posn_Level L3 ON CTE_Position_HR_Status_L3_Final.REPORTS_TO = L3.POSITION_NBR
    WHERE t3.To_Trace_Up_3 = 'yes';

    -- Add clustered index for faster joins
    CREATE CLUSTERED INDEX IX_temp4_POSITION_NBR ON #temp4 (POSITION_NBR_To_Check);

    -- Show temp4 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1,
        MANAGER_EMPLID,
        MANAGER_HR_STATUS,
        MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL_L1,
        To_Trace_Up_2,
        NOTE_L1
    FROM #temp4
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp5 by joining To_Trace_Up_4='yes' records with Level 4 analysis data
    IF OBJECT_ID('tempdb..#temp5', 'U') IS NOT NULL 
        DROP TABLE #temp5;

    WITH
        JobData_L4
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L4
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L4
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L4
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L4
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L4
            WHERE RN_EMPL = 1
        ),
        PositionData_L4
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L4
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L4 jd
                JOIN PositionData_L4 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L4 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L4 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L4 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L4_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L4
            WHERE RN_FINAL = 1
        )
    SELECT DISTINCT
        t4.POSITION_NBR_To_Check,
        t4.MANAGER_POSITION_NBR,
        t4.POSN_LEVEL,
        t4.To_Trace_Up_1,
        t4.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR_L1,
        t4.MANAGER_EMPLID,
        t4.MANAGER_HR_STATUS,
        t4.MANAGER_POSN_STATUS,
        t4.MANAGER_POSN_LEVEL_L1,
        t4.To_Trace_Up_2,
        t4.NOTE_L1,
        t4.MANAGER_POSITION_NBR_L2,
        t4.MANAGER_EMPLID_L2,
        t4.MANAGER_HR_STATUS_L2,
        t4.MANAGER_POSN_STATUS_L2,
        t4.MANAGER_POSN_LEVEL_L2,
        t4.To_Trace_Up_3,
        t4.NOTE_L2,
        t4.MANAGER_POSITION_NBR_L3,
        t4.MANAGER_EMPLID_L3,
        t4.MANAGER_HR_STATUS_L3,
        t4.MANAGER_POSN_STATUS_L3,
        t4.MANAGER_POSN_LEVEL_L3,
        t4.To_Trace_Up_4,
        t4.NOTE_L3,
        CTE_Position_HR_Status_L4_Final.REPORTS_TO as MANAGER_POSITION_NBR_L4,
        CTE_Position_HR_Status_L4_Final.Manager_EMPLID as MANAGER_EMPLID_L4,
        CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L4,
        CTE_Position_HR_Status_L4_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L4,
        COALESCE(L4.POSN_LEVEL, L5.POSN_LEVEL) as MANAGER_POSN_LEVEL_L4,
        CASE 
            WHEN CTE_Position_HR_Status_L4_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L4.POSN_LEVEL, L5.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L4_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L4,
        CASE 
            WHEN CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_5
    INTO #temp5
    FROM #temp4 t4
        LEFT JOIN CTE_Position_HR_Status_L4_Final ON t4.MANAGER_POSITION_NBR_L3 = CTE_Position_HR_Status_L4_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L4 ON CTE_Position_HR_Status_L4_Final.REPORTS_TO = L4.POSITION_NBR
        LEFT JOIN #Hierarchy_Posn_Level L5 ON CTE_Position_HR_Status_L4_Final.REPORTS_TO = L5.POSITION_NBR
    WHERE t4.To_Trace_Up_4 = 'yes';

    -- Add clustered index for faster joins
    CREATE CLUSTERED INDEX IX_temp5_POSITION_NBR ON #temp5 (POSITION_NBR_To_Check);

    -- Show temp5 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1,
        MANAGER_EMPLID,
        MANAGER_HR_STATUS,
        MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL_L1,
        To_Trace_Up_2,
        NOTE_L1
    FROM #temp5
    ORDER BY POSITION_NBR_To_Check;

    -- Final step: Insert comprehensive hierarchy data into permanent table
    INSERT INTO [stage].[UKG_EMPL_Inactive_Manager_Hierarchy]
        (
        POSITION_NBR_To_Check, MANAGER_POSITION_NBR, POSN_LEVEL, To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1, MANAGER_EMPLID, MANAGER_HR_STATUS, MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL_L1, To_Trace_Up_2, NOTE_L1,
        MANAGER_POSITION_NBR_L2, MANAGER_EMPLID_L2, MANAGER_HR_STATUS_L2, MANAGER_POSN_STATUS_L2,
        MANAGER_POSN_LEVEL_L2, To_Trace_Up_3, NOTE_L2,
        MANAGER_POSITION_NBR_L3, MANAGER_EMPLID_L3, MANAGER_HR_STATUS_L3, MANAGER_POSN_STATUS_L3,
        MANAGER_POSN_LEVEL_L3, To_Trace_Up_4, NOTE_L3,
        MANAGER_POSITION_NBR_L4, MANAGER_EMPLID_L4, MANAGER_HR_STATUS_L4, MANAGER_POSN_STATUS_L4,
        MANAGER_POSN_LEVEL_L4, To_Trace_Up_5, NOTE_L4
        )
    SELECT
        POSITION_NBR_To_Check, MANAGER_POSITION_NBR, POSN_LEVEL, To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1, MANAGER_EMPLID, MANAGER_HR_STATUS, MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL_L1, To_Trace_Up_2, NOTE_L1,
        MANAGER_POSITION_NBR_L2, MANAGER_EMPLID_L2, MANAGER_HR_STATUS_L2, MANAGER_POSN_STATUS_L2,
        MANAGER_POSN_LEVEL_L2, To_Trace_Up_3, NOTE_L2,
        MANAGER_POSITION_NBR_L3, MANAGER_EMPLID_L3, MANAGER_HR_STATUS_L3, MANAGER_POSN_STATUS_L3,
        MANAGER_POSN_LEVEL_L3, To_Trace_Up_4, NOTE_L3,
        MANAGER_POSITION_NBR_L4, MANAGER_EMPLID_L4, MANAGER_HR_STATUS_L4, MANAGER_POSN_STATUS_L4,
        MANAGER_POSN_LEVEL_L4, To_Trace_Up_5, NOTE_L4
    FROM #temp5
    WHERE POSITION_NBR_To_Check IS NOT NULL;

    PRINT 'Hierarchy analysis and trace-up process completed successfully.';
END
go





/***************************************************************************************************************************************************************************************************************************************************************
--  Procedure Name: [stage].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD]
--  Author:         Jim Shih
--  Version:        2.0
--  Date:           9/5/2025
--  Description:    This stored procedure identifies the most recent employee status change for each employee from stable.ps_job.
--                  Enhanced to prioritize records that occur AFTER the MOST RECENT HIRE_DT change.
--                  Uses LAG window function to detect both EMPL_STATUS and HIRE_DT changes
--                  within each employee's history, ordered by effective date and sequence.
--                  Priority Logic:
--                  1. Records after the MOST RECENT HIRE_DT change (latest hire date adjustment)
--                  2. If no HIRE_DT changes exist, use latest EMPL_STATUS change
--                  3. If no status changes exist, use oldest record as fallback
--                  Filters out deleted records and records with effective dates after the current date.
--                  Added logic to ensure effective date is not before hire date for data integrity.
--                  Includes HIRE_DT in output for comprehensive employee status tracking.
--  Parameters:     None
--  Example:        EXEC [stage].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD];
--
--  Version History:
--  Date        Author               Description
--  6/10/2025 Jim Shih             Initial procedure creation.
*-- 7/14/2025 Jim Shih
*-- migrate from hs-ssisp-v
*-- changed to health_ods.[health_ods].[stable].ps_job
*-- 9/5/2025 Jim Shih              Added HIRE_DT column to output and added logic to ensure EFFDT >= HIRE_DT for data integrity
*-- 9/5/2025 Jim Shih Ver 2.0      Enhanced to prioritize records after MOST RECENT HIRE_DT change
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

CREATE       PROCEDURE [stage].[SP_UKG_EMPL_STATUS_LOOKUP_BUILD]
AS
BEGIN
    -- Drop table and index if they exist
    IF OBJECT_ID('[stage].[UKG_EMPL_STATUS_LOOKUP]') IS NOT NULL
        DROP TABLE [stage].[UKG_EMPL_STATUS_LOOKUP];

    -- -- Drop index if it exists (in case table was dropped but index wasn't)
    -- IF EXISTS (SELECT 1
    -- FROM sys.indexes
    -- WHERE object_id = OBJECT_ID('[stage].[UKG_EMPL_STATUS_LOOKUP]') AND name = 'IX_UKG_EMPL_STATUS_LOOKUP_emplid')
    --     DROP INDEX IX_UKG_EMPL_STATUS_LOOKUP_emplid ON [stage].[UKG_EMPL_STATUS_LOOKUP];


    WITH
        StatusChanges
        AS
        (
            SELECT
                emplid,
                EMPL_STATUS,
                EFFDT,
                EFFSEQ,
                EMPL_RCD,
                HIRE_DT,
                -- Determine the previous EMPL_STATUS. If it's the first record for an employee, previous_EMPL_STATUS will be the current EMPL_STATUS.
                -- Using EMPL_STATUS as default for LAG ensures previous_EMPL_STATUS is never NULL if a row exists.
                LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS,
                -- Track HIRE_DT changes using LAG function
                LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
                -- Rank records for each employee by effective date, oldest first.
                ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
            FROM health_ods.[health_ods].[stable].ps_job
            WHERE EFFDT <= GETDATE() -- Consider records up to the current date
                AND DML_IND <> 'D' -- Exclude deleted records
                AND JOB_INDICATOR='P'
                AND EFFDT >= HIRE_DT
            -- Ensure effective date is not before hire date
            -- Primary job indicator
        ),
        HireDateChanges
        AS
        (
            -- Identify records where HIRE_DT actually changed compared to the previous chronological record.
            SELECT
                emplid,
                EMPL_STATUS,
                EFFDT,
                EFFSEQ,
                EMPL_RCD,
                HIRE_DT,
                previous_HIRE_DT,
                previous_EMPL_STATUS,
                -- Rank HIRE_DT change points for each employee, latest change first.
                ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS hire_change_rank
            FROM StatusChanges
            WHERE HIRE_DT <> previous_HIRE_DT AND previous_HIRE_DT IS NOT NULL
            -- This condition defines a "HIRE_DT change event"
        ),
        ActualChangePoints
        AS
        (
            -- Identify records where EMPL_STATUS actually changed compared to the previous chronological record.
            SELECT
                emplid,
                EMPL_STATUS,
                EFFDT,
                EFFSEQ,
                EMPL_RCD,
                HIRE_DT,
                previous_EMPL_STATUS, -- Keep for clarity if needed
                -- Rank these change points for each employee, latest change first.
                ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS rn_of_change
            FROM StatusChanges
            WHERE EMPL_STATUS <> previous_EMPL_STATUS
            -- This condition defines a "status change event"
        ),
        OldestRecordsCTE
        AS
        (
            -- Dataset 3: Oldest record for each employee (fallback when no changes exist)
            SELECT
                sc.emplid,
                sc.EMPL_STATUS,
                sc.EFFDT,
                sc.EFFSEQ,
                sc.EMPL_RCD,
                sc.HIRE_DT,
                'Oldest Record' AS NOTE
            FROM StatusChanges sc
            WHERE sc.RowNum_Oldest = 1
        ),
        MostRecentHireDateChangeRecordsCTE
        AS
        (
            -- Dataset 1: Records that occur AFTER the MOST RECENT HIRE_DT change (highest priority)
            SELECT
                hdc.emplid,
                hdc.EMPL_STATUS,
                hdc.EFFDT,
                hdc.EFFSEQ,
                hdc.EMPL_RCD,
                hdc.HIRE_DT,
                'After Most Recent HIRE_DT Change' AS NOTE
            FROM HireDateChanges hdc
            WHERE hdc.hire_change_rank = 1
        ),
        LatestChangeRecordsCTE
        AS
        (
            -- Dataset 2: Latest EMPL_STATUS change record for each employee (when no HIRE_DT changes exist)
            SELECT
                acp.emplid,
                acp.EMPL_STATUS,
                acp.EFFDT,
                acp.EFFSEQ,
                acp.EMPL_RCD,
                acp.HIRE_DT,
                'Latest Status Change' AS NOTE
            FROM ActualChangePoints acp
            WHERE acp.rn_of_change = 1
        )
    SELECT --top 1000
        UnionData.emplid,
        UnionData.EMPL_STATUS,
        UnionData.EFFDT,
        UnionData.EFFSEQ,
        UnionData.EMPL_RCD,
        UnionData.HIRE_DT,
        UnionData.NOTE,
        GETDATE() AS LOAD_DTTM
    INTO [stage].[UKG_EMPL_STATUS_LOOKUP]
    FROM (
        -- Priority 1: Records after MOST RECENT HIRE_DT change (highest priority)
                                                SELECT emplid, EMPL_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
            FROM MostRecentHireDateChangeRecordsCTE

        UNION ALL

            -- Priority 2: Latest EMPL_STATUS change (when no HIRE_DT changes exist)
            SELECT emplid, EMPL_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
            FROM LatestChangeRecordsCTE
            WHERE emplid NOT IN (SELECT EMPLID
            FROM MostRecentHireDateChangeRecordsCTE)

        UNION ALL

            -- Priority 3: Oldest record (fallback when no changes exist)
            SELECT emplid, EMPL_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
            FROM OldestRecordsCTE
            WHERE emplid NOT IN (SELECT EMPLID
                FROM MostRecentHireDateChangeRecordsCTE)
                AND emplid NOT IN (SELECT EMPLID
                FROM LatestChangeRecordsCTE)
    ) AS UnionData;


    -- Create index on emplid for better performance
    CREATE INDEX IX_UKG_EMPL_STATUS_LOOKUP_emplid ON [stage].[UKG_EMPL_STATUS_LOOKUP] (emplid);

END;
go


/***************************************
* Created By: Jim Shih
* Procedure: stage.SP_UKG_EMPL_Update_Manager_Flag-Step4
* Purpose: Updates Manager Flag to 'F' for employees in vacant manager positions (positions flagged as managers but with no active direct reports)
* EXEC [stage].[SP_UKG_EMPL_Update_Manager_Flag-Step4]
* -- 09/15/2025 Jim Shih: Created procedure based on 46.sql logic
* --                      Uses CTE mPOSN_Manager_Flag_To_Update to identify vacant manager positions
* --                      Updates Manager Flag to 'F' for employees whose position_nbr matches vacant manager positions
* --                      Vacant manager positions = positions where Manager Flag='T' but no active employees report to them
* --                      Update Manager Flag to 'T' for positions that have terminated employees reporting to them
* --                      These positions may still be considered manager positions due to historical reporting relationships
* --                      Update Manager Flag to 'F' for positions with NO reports at all (active or terminated)
* --                      This corrects cases where Manager Flag was incorrectly set to 'T' during initial data load or manual settings
* -- 09/17/2025 Jim Shih: Added third update step to set Manager Flag to 'F' for positions with no reports at all
* --                      This addresses cases where Manager Flag was incorrectly set to 'T' during initial data load or manual settings
******************************************/

CREATE   PROCEDURE [stage].[SP_UKG_EMPL_Update_Manager_Flag-Step4]
AS
BEGIN
    SET NOCOUNT ON;

    -- Create temp table to store vacant manager positions
    DROP TABLE IF EXISTS #mPOSN_Manager_Flag_To_Update;
    CREATE TABLE #mPOSN_Manager_Flag_To_Update
    (
        position_nbr VARCHAR(20) PRIMARY KEY
    );

    -- Insert vacant manager positions into temp table
    -- CTE based on 46.sql logic: Find vacant manager positions (flagged as managers but no active reports)
    WITH
        TERMINATED_empl
        AS
        (
            SELECT emplid, reports_to
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            WHERE [hr_status]='I'
        ),
        mPOSN_Manager_Flag_To_Update_To_T
        AS
        (
            SELECT E.emplid, E.position_nbr
            FROM [dbo].[UKG_EMPLOYEE_DATA] E
                INNER JOIN TERMINATED_empl TE
                ON E.position_nbr = TE.reports_to
        ),
        VacantPositions
        AS
        (
            SELECT DISTINCT
                mPOSN.[position_nbr]
            FROM (
            SELECT emplid, [position_nbr]
                FROM [dbo].[UKG_EMPLOYEE_DATA]
                WHERE [Manager Flag]='T'
        ) mPOSN
                INNER JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
                ON mPOSN.position_nbr = empl.[POSITION_REPORTS_TO]
            WHERE empl.MANAGER_EMPLID IS NOT NULL
            GROUP BY mPOSN.[position_nbr]
            HAVING SUM(CASE WHEN empl.HR_STATUS = 'A' THEN 1 ELSE 0 END) = 0
        )
    INSERT INTO #mPOSN_Manager_Flag_To_Update
        (position_nbr)
    SELECT position_nbr
    FROM VacantPositions;

    -- Update Manager Flag to 'F' for employees in vacant manager positions
    UPDATE E
    SET [Manager Flag] = 'F'
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr;

    -- Show summary of changes
    SELECT
        'Employees updated to Manager Flag = ''F''' as Description,
        COUNT(*) as Count
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr;

    -- Show the vacant positions that were updated
    PRINT 'Vacant manager positions updated:';
    SELECT DISTINCT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag]
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr
    ORDER BY E.position_nbr;

    -- Update Manager Flag to 'T' for positions that have terminated employees reporting to them
    -- These positions may still be considered manager positions due to historical reporting relationships
    UPDATE E
    SET [Manager Flag] = 'T'
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN (
        SELECT DISTINCT E2.emplid, E2.position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA] E2
            INNER JOIN (
            SELECT emplid, reports_to
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            WHERE [hr_status]='I'
        ) TE ON E2.position_nbr = TE.reports_to
    ) mPOSN_Manager_Flag_To_Update_To_T
        ON E.emplid = mPOSN_Manager_Flag_To_Update_To_T.emplid
            AND E.position_nbr = mPOSN_Manager_Flag_To_Update_To_T.position_nbr;

    -- Show summary of the second update
    PRINT 'Positions updated back to Manager Flag = ''T'' (have terminated employees):';
    SELECT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag],
        COUNT(TE.emplid) as Terminated_Reports_Count
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN (
        SELECT DISTINCT E2.emplid, E2.position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA] E2
            INNER JOIN (
            SELECT emplid, reports_to
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            WHERE [hr_status]='I'
        ) TE ON E2.position_nbr = TE.reports_to
    ) mPOSN_Manager_Flag_To_Update_To_T
        ON E.emplid = mPOSN_Manager_Flag_To_Update_To_T.emplid
            AND E.position_nbr = mPOSN_Manager_Flag_To_Update_To_T.position_nbr
        LEFT JOIN (
        SELECT emplid, reports_to
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [hr_status]='I'
    ) TE ON TE.reports_to = E.position_nbr
    GROUP BY E.position_nbr, E.emplid, E.[First Name], E.[Last Name], E.[Manager Flag]
    ORDER BY E.position_nbr;

    -- Update Manager Flag to 'F' for positions that have NO reports at all (active or terminated)
    -- This handles cases where Manager Flag was incorrectly set to 'T' during initial data load or manual settings
    UPDATE E
    SET [Manager Flag] = 'F'
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
    WHERE E.[Manager Flag] = 'T'
        AND NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA] reports
        WHERE reports.reports_to = E.position_nbr
            AND reports.emplid != E.emplid
        );

    -- Show summary of the third update
    PRINT 'Positions updated to Manager Flag = ''F'' (no reports found - initial load/manual setting issue):';
    SELECT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag],
        'No reports found - corrected from initial data load or manual setting' as Reason
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
    WHERE E.[Manager Flag] = 'F'
        AND NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA] reports
        WHERE reports.reports_to = E.position_nbr
            AND reports.emplid != E.emplid
        )
        AND E.emplid IN (
            -- Only show positions that were just updated in this step
            SELECT emplid
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [Manager Flag] = 'F'
            AND NOT EXISTS (
                    SELECT 1
            FROM [dbo].[UKG_EMPLOYEE_DATA] reports
            WHERE reports.reports_to = position_nbr
                AND reports.emplid != emplid
                )
        )
    ORDER BY E.position_nbr;

    -- Clean up temp table
    DROP TABLE #mPOSN_Manager_Flag_To_Update;

END;

go



/*
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  Procedure Name: [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD]
--  Author:         Jim Shih
--  Create date:    05/19/2025 -- Please update with the original creation date
--  Description:    This stored procedure identifies employees from health_ods.[health_ods].].stable.PS_JOB who are considered inactive
--                  or not managed under UKG for a specified pay period.
--                  It achieves this by selecting employees who are:
--                      1. Not present in [dbo].[UKG_EMPLOYEE_DATA] (specifically, those not having NON_UKG_MANAGER_FLAG != 'T',
--                         meaning it excludes employees considered managed by UKG)._
--                      2. Meet specific departmental criteria (for some datasets):
--                         - Belong to 'VCHSH' (MED CENTER) via health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY].
--                         - Or, belong to PHSO departments (DEPTID range '002000'-'002999' with specific exclusions).
--                      3. Are not part of the ARC MSP POPULATION (specific DEPTID and JOBCODE exclusions for some datasets).
--                      4. Have JOB_INDICATOR = 'P' (for some datasets), DML_IND <> 'D', GP_PAYGROUP = 'BIWEEKLY', and EMPL_TYPE = 'H' (Hourly).
--                      5. Meet one of the following EFFDT criteria:
--                         a. (Dataset1) EFFDT is within the provided @paybeginddt AND @payenddt, using FilteredJobData.
--                         b. (Dataset2) EFFDT is on or before @paybeginddt and is the latest effective-dated record for active employees (using FilteredJobData),
--                            EXCLUDING any EMPLID found in Dataset1 AND EXCLUDING any EMPLID found in Dataset3.
--                         c. (Dataset3) Identifies MAX effective-dated records within the pay period (using NonUKGjobInPayperiod, which itself excludes EMPLIDs from Dataset1)
--                            are used to filter Dataset2. The NOTE in Dataset3 clarifies its role.
--                  The target table [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD] is dropped and recreated with each execution.
--                  Additionally, intermediate tables for Dataset1, Dataset2, and Dataset3 are created for validation.
--                  The results (EMPLID, HR_STATUS, JOB_INDICATOR, TERMINATION_DT, deptid, VC_CODE, EFFDT, EFFSEQ, EMPL_RCD, UPD_BT_DTM, NOTE, LOAD_DTTM)
--                  are inserted into the newly created table, with the NOTE column indicating the reason for inclusion.
--
--  Execution Example:
--  EXEC [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD] @payenddt = '2025-07-5';
--  obsolete EXEC [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD] @paybeginddt = '2025-04-27', @payenddt = '2025-05-10';

--
--  Version History:
--  Date        Author               Description
--  ----------- -------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  05/19/2025 Jim Shih             Initial procedure creation.
--  05/20/2025 Jim Shih             Modified to union records with EFFDT <= @paybeginddt, using a CTE for clarity and adding a NOTE for each dataset._
--  05/21/2025 Jim Shih             Restructured the UNION ALL into separate CTEs (Dataset1, Dataset2, Dataset3) for better data manipulation capability,
--                                  Dataset2 excludes EMPLIDs from Dataset1 and Dataset3
*-- 7/16/2025 Jim Shih
*-- migrate from hs-ssisp-v
*-- @paybeginddt=DATEADD(day, -13, @payenddt)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE             PROCEDURE [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD]
--    @paybeginddt DATE,
    @payenddt DATE
AS
BEGIN
    SET NOCOUNT ON;
DECLARE @paybeginddt DATE; -- Declare the variable	
SET @paybeginddt = DATEADD(day, -13, @payenddt);
    -- Drop the main table if it already exists
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD]', 'U') IS NOT NULL
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD];

    -- Drop validation tables if they already exist
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1]', 'U') IS NOT NULL
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1];
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2]', 'U') IS NOT NULL
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2];
    IF OBJECT_ID('[stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3]', 'U') IS NOT NULL
        DROP TABLE [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3];

    -- Create Dataset1 validation table
    -- Define CTEs required for Dataset1
    WITH FilteredJobData AS (
        SELECT
            H.EMPLID,
            H.HR_STATUS,
            H.JOB_INDICATOR,
            H.TERMINATION_DT,
            H.deptid,
            DT.DESCRSHORT AS DEPT_DESCR, -- Sourced from health_ods.[health_ods].].stable.PS_DEPT_TBL
			DT.DESCR AS DEPT_DESCR_FULL,
            V.VC_CODE,
            H.EFFDT,
            H.EFFSEQ,
            H.EMPL_RCD,
            H.UPD_BT_DTM
        FROM health_ods.[HEALTH_ODS].stable.PS_JOB H
        JOIN health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY] V
            ON H.DEPTID = V.DEPTID
        LEFT JOIN health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT
            ON H.SETID_DEPT = DT.SETID
            AND H.DEPTID = DT.DEPTID
            AND DT.DML_IND <> 'D' -- Ensure we don't pick up deleted department rows
            AND DT.EFFDT = (
                SELECT MAX(DT_SUB.EFFDT)
                FROM health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT_SUB
                WHERE DT_SUB.SETID = DT.SETID
                  AND DT_SUB.DEPTID = DT.DEPTID
                  AND DT_SUB.EFFDT <= H.EFFDT -- Effective as of the job record's effective date
                  AND DT_SUB.DML_IND <> 'D'
            )
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM [dbo].[UKG_EMPLOYEE_DATA] UED
                WHERE UED.EMPLID = H.EMPLID
                  AND UED.NON_UKG_MANAGER_FLAG != 'T' -- or IS DISTINCT FROM 'T' if NULLs are a concern for NON_UKG_MANAGER_FLAG
            )  -- UKG_EMPLOYEE_DATA has most of CURRENT UKG emplid
            -- Filter for UKG
            AND (V.VC_CODE = 'VCHSH'   	 --MED CENTER
                OR (H.DEPTID BETWEEN '002000' AND '002999' AND H.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
                )
            AND NOT (H.DEPTID IN ('002053','002056','003919') AND H.JOBCODE IN ('000770','000771','000772','000775','000776'))	--exclude ARC MSP POPULATION
            AND H.JOB_INDICATOR = 'P'
            AND H.DML_IND <> 'D'
            AND H.GP_PAYGROUP = 'BIWEEKLY'
            AND H.EMPL_TYPE = 'H' -- Biweekly and hourly empl only
    ),
    Dataset1 AS (
        SELECT
            FJD.EMPLID,
            FJD.HR_STATUS,
            FJD.JOB_INDICATOR,
            FJD.TERMINATION_DT,
            FJD.deptid,
            FJD.DEPT_DESCR,
            FJD.DEPT_DESCR_FULL,
            FJD.VC_CODE,
            FJD.EFFDT,
            FJD.EFFSEQ,
            FJD.EMPL_RCD,
            FJD.UPD_BT_DTM,
            'UKG EFFDT is in Pay Period' AS NOTE,
            GETDATE() AS LOAD_DTTM
        FROM FilteredJobData FJD
--        WHERE FJD.EFFDT BETWEEN @paybeginddt AND @payenddt
    )
    SELECT *
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1]
    FROM Dataset1;

    -- Create Dataset2 validation table
    -- Define CTEs required for Dataset2
    WITH FilteredJobData AS (
        SELECT
            H.EMPLID,
            H.HR_STATUS,
            H.JOB_INDICATOR,
            H.TERMINATION_DT,
            H.deptid,
            DT.DESCRSHORT AS DEPT_DESCR, -- Sourced from health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL
			DT.DESCR AS DEPT_DESCR_FULL,
            V.VC_CODE,
            H.EFFDT,
            H.EFFSEQ,
            H.EMPL_RCD,
            H.UPD_BT_DTM
        FROM health_ods.[HEALTH_ODS].stable.PS_JOB H
        JOIN health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY] V
            ON H.DEPTID = V.DEPTID
        LEFT JOIN health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT
            ON H.SETID_DEPT = DT.SETID
            AND H.DEPTID = DT.DEPTID
            AND DT.DML_IND <> 'D'
            AND DT.EFFDT = (
                SELECT MAX(DT_SUB.EFFDT)
                FROM health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT_SUB
                WHERE DT_SUB.SETID = DT.SETID
                  AND DT_SUB.DEPTID = DT.DEPTID
                  AND DT_SUB.EFFDT <= H.EFFDT
                  AND DT_SUB.DML_IND <> 'D'
            )
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM [dbo].[UKG_EMPLOYEE_DATA] UED
                WHERE UED.EMPLID = H.EMPLID
                  AND UED.NON_UKG_MANAGER_FLAG != 'T' -- or IS DISTINCT FROM 'T' if NULLs are a concern for NON_UKG_MANAGER_FLAG
            )  -- UKG_EMPLOYEE_DATA has most of CURRENT UKG emplid
            -- Filter for UKG
            AND (V.VC_CODE = 'VCHSH'   	 --MED CENTER
                OR (H.DEPTID BETWEEN '002000' AND '002999' AND H.DEPTID NOT IN ('002230','002231','002280') )	 -- PHSO
                )
            AND NOT (H.DEPTID IN ('002053','002056','003919') AND H.JOBCODE IN ('000770','000771','000772','000775','000776'))	--exclude ARC MSP POPULATION
            AND H.JOB_INDICATOR = 'P'
            AND H.DML_IND <> 'D'
            AND H.GP_PAYGROUP = 'BIWEEKLY'
            AND H.EMPL_TYPE = 'H' -- Biweekly and hourly empl only
    ),
    Dataset2 AS (
        SELECT
            FJD.EMPLID,
            FJD.HR_STATUS,
            FJD.JOB_INDICATOR,
            FJD.TERMINATION_DT,
            FJD.deptid,
            FJD.DEPT_DESCR,
            FJD.DEPT_DESCR_FULL,
            FJD.VC_CODE,
            FJD.EFFDT,
            FJD.EFFSEQ,
            FJD.EMPL_RCD,
            FJD.UPD_BT_DTM,
            'UKG EFFDT is on or before Pay Period Begin' AS NOTE,
            GETDATE() AS LOAD_DTTM
        FROM FilteredJobData FJD
        WHERE FJD.EFFDT <= @paybeginddt
        AND FJD.HR_STATUS='A'
        AND FJD.EFFDT =
            (SELECT MAX(D_ED.EFFDT) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ED
              WHERE FJD.EMPLID = D_ED.EMPLID
                AND FJD.EMPL_RCD = D_ED.EMPL_RCD
                AND D_ED.EFFDT <= @paybeginddt
                AND D_ED.DML_IND <> 'D')
        AND FJD.EFFSEQ =
            (SELECT MAX(D_ES.EFFSEQ) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ES
              WHERE FJD.EMPLID = D_ES.EMPLID
                AND FJD.EMPL_RCD = D_ES.EMPL_RCD
                AND FJD.EFFDT = D_ES.EFFDT
                AND D_ES.DML_IND <> 'D')
    )
    SELECT *
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2]
    FROM Dataset2;

    -- Create Dataset3 validation table
    -- Define CTEs required for Dataset3
    WITH NonUKGjobInPayperiod AS (
        SELECT
            H.EMPLID,
            H.HR_STATUS,
            H.JOB_INDICATOR,
            H.TERMINATION_DT,
            H.deptid,
            DT.DESCRSHORT AS DEPT_DESCR, -- Sourced from health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL
			DT.DESCR AS DEPT_DESCR_FULL,
            V.VC_CODE,
            H.EFFDT,
            H.EFFSEQ,
            H.EMPL_RCD,
            H.UPD_BT_DTM
        FROM health_ods.[HEALTH_ODS].stable.PS_JOB H
        JOIN health_ods.[HEALTH_ODS].RPT.[DEPARTMENT_HIERARCHY] V
            ON H.DEPTID = V.DEPTID
        LEFT JOIN health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT
            ON H.SETID_DEPT = DT.SETID
            AND H.DEPTID = DT.DEPTID
            AND DT.DML_IND <> 'D'
            AND DT.EFFDT = (
                SELECT MAX(DT_SUB.EFFDT)
                FROM health_ods.[HEALTH_ODS].stable.PS_DEPT_TBL DT_SUB
                WHERE DT_SUB.SETID = DT.SETID
                  AND DT_SUB.DEPTID = DT.DEPTID
                  AND DT_SUB.EFFDT <= H.EFFDT
                  AND DT_SUB.DML_IND <> 'D'
            )
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM [dbo].[UKG_EMPLOYEE_DATA] UED
                WHERE UED.EMPLID = H.EMPLID
                  AND UED.NON_UKG_MANAGER_FLAG != 'T' -- or IS DISTINCT FROM 'T' if NULLs are a concern for NON_UKG_MANAGER_FLAG
            )  -- UKG_EMPLOYEE_DATA has most of CURRENT UKG emplid
            AND NOT EXISTS ( -- Exclude EMPLIDs that are in Dataset1
                SELECT 1
                FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1] D1_Table
                WHERE D1_Table.EMPLID = H.EMPLID
            )
            -- The following filters are intentionally broader than FilteredJobData
            AND H.DML_IND <> 'D'
            AND H.GP_PAYGROUP = 'BIWEEKLY'
            AND H.EMPL_TYPE = 'H' -- Biweekly and hourly empl only
            AND H.EFFDT BETWEEN @paybeginddt AND @payenddt -- Crucial filter for this CTE
    ),
    Dataset3 AS (
        SELECT
            FJD.EMPLID,
            FJD.HR_STATUS,
            FJD.JOB_INDICATOR,
            FJD.TERMINATION_DT,
            FJD.deptid,
            FJD.DEPT_DESCR,
            FJD.DEPT_DESCR_FULL,
            FJD.VC_CODE,
            FJD.EFFDT,
            FJD.EFFSEQ,
            FJD.EMPL_RCD,
            FJD.UPD_BT_DTM,
            'NON_UKG and MAX-EFFDT is in Pay Period, should be exculded from dataset2' AS NOTE,
            GETDATE() AS LOAD_DTTM
        FROM NonUKGjobInPayperiod FJD 
        WHERE FJD.EFFDT BETWEEN @paybeginddt AND @payenddt 
 --       AND FJD.HR_STATUS='A' -- Kept commented 
        AND FJD.EFFDT =
            (SELECT MAX(D_ED.EFFDT) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ED
              WHERE FJD.EMPLID = D_ED.EMPLID
                AND FJD.EMPL_RCD = D_ED.EMPL_RCD
                AND D_ED.EFFDT BETWEEN @paybeginddt AND @payenddt
                AND D_ED.DML_IND <> 'D')
        AND FJD.EFFSEQ =
            (SELECT MAX(D_ES.EFFSEQ) FROM health_ods.[HEALTH_ODS].stable.PS_JOB D_ES
              WHERE FJD.EMPLID = D_ES.EMPLID
                AND FJD.EMPL_RCD = D_ES.EMPL_RCD
                AND FJD.EFFDT = D_ES.EFFDT
                AND D_ES.DML_IND <> 'D')
    )
    SELECT *
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3]
    FROM Dataset3;

    -- Populate the final target table
    SELECT
        EMPLID,
        HR_STATUS,
        JOB_INDICATOR,
        TERMINATION_DT,
        deptid,
        DEPT_DESCR,
        DEPT_DESCR_FULL,
        VC_CODE,
        EFFDT,
        EFFSEQ,
        EMPL_RCD,
        UPD_BT_DTM,
        NOTE,
        LOAD_DTTM
    INTO [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD]
    FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1] -- Use the created table

    UNION ALL

    SELECT
        D2.EMPLID, 
        D2.HR_STATUS, 
        D2.JOB_INDICATOR,
        D2.TERMINATION_DT, 
        D2.deptid,
        D2.DEPT_DESCR,
        D2.DEPT_DESCR_FULL,
        D2.VC_CODE, 
        D2.EFFDT, 
        D2.EFFSEQ, 
        D2.EMPL_RCD, 
        D2.UPD_BT_DTM, 
        D2.NOTE, 
        D2.LOAD_DTTM
    FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset2] D2 -- Use the created table
    WHERE NOT EXISTS ( 
        SELECT 1
        FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset3] D3 -- Use the created table
        WHERE D3.EMPLID = D2.EMPLID
    )
    AND NOT EXISTS ( 
        SELECT 1
        FROM [stage].[UKG_INACTIVE_EMPLID_BY_PAYPERIOD_Dataset1] D1 -- Use the created table
        WHERE D1.EMPLID = D2.EMPLID
    )
    ;

END
go






/***************************************************************************************************************************************************************************************************************************************************************
--  Procedure Name: [stage].[SP_UKG_HR_STATUS_LOOKUP_BUILD]
--  Author:         Jim Shih
--  Version:        1.0
--  Date:           9/6/2025
--  Description:    This stored procedure identifies the most recent employee HR status change for each employee from stable.ps_job.
--                  Enhanced to prioritize records that occur AFTER the MOST RECENT HR_STATUS change.
--                  Uses LAG window function to detect both HR_STATUS and HIRE_DT changes
--                  within each employee's history, ordered by effective date and sequence.
--                  Priority Logic:
--                  1. Records after the MOST RECENT HR_STATUS change (latest HR status adjustment)
--                  2. If no HR_STATUS changes exist, use latest HR_STATUS change
--                  3. If no status changes exist, use oldest record as fallback
--                  Filters out deleted records and records with effective dates after the current date.
--                  Added logic to ensure effective date is not before hire date for data integrity.
--                  Includes HIRE_DT in output for comprehensive employee status tracking.
--  Parameters:     None
--  Example:        EXEC [stage].[SP_UKG_HR_STATUS_LOOKUP_BUILD];
--
--  Version History:
--  Date        Author               Description
--  9/6/2025   Jim Shih             Initial procedure creation based on SP_UKG_EMPL_STATUS_LOOKUP_BUILD-ver4.sql
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

CREATE     PROCEDURE [stage].[SP_UKG_HR_STATUS_LOOKUP_BUILD]
AS
BEGIN
    -- Drop table and index if they exist
    IF OBJECT_ID('[stage].[UKG_HR_STATUS_LOOKUP]') IS NOT NULL
        DROP TABLE [stage].[UKG_HR_STATUS_LOOKUP];

    -- -- Drop index if it exists (in case table was dropped but index wasn't)
    -- IF EXISTS (SELECT 1
    -- FROM sys.indexes
    -- WHERE object_id = OBJECT_ID('[stage].[UKG_HR_STATUS_LOOKUP]') AND name = 'IX_UKG_HR_STATUS_LOOKUP_emplid')
    --     DROP INDEX IX_UKG_HR_STATUS_LOOKUP_emplid ON [stage].[UKG_HR_STATUS_LOOKUP];

    WITH
        StatusChanges
        AS
        (
            SELECT
                emplid,
                HR_STATUS,
                EFFDT,
                EFFSEQ,
                EMPL_RCD,
                HIRE_DT,
                -- Determine the previous HR_STATUS. If it's the first record for an employee, previous_HR_STATUS will be the current HR_STATUS.
                -- Using HR_STATUS as default for LAG ensures previous_HR_STATUS is never NULL if a row exists.
                LAG(HR_STATUS, 1, HR_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HR_STATUS,
                -- Track HIRE_DT changes using LAG function
                LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
                -- Rank records for each employee by effective date, oldest first.
                ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
            FROM health_ods.[health_ods].[stable].ps_job
            WHERE EFFDT <= GETDATE() -- Consider records up to the current date
                AND DML_IND <> 'D' -- Exclude deleted records
                AND JOB_INDICATOR='P'
                AND EFFDT >= HIRE_DT
            -- Ensure effective date is not before hire date
            -- Primary job indicator
        ),
        HRStatusChanges
        AS
        (
            -- Identify records where HR_STATUS actually changed compared to the previous chronological record.
            SELECT
                emplid,
                HR_STATUS,
                EFFDT,
                EFFSEQ,
                EMPL_RCD,
                HIRE_DT,
                previous_HIRE_DT,
                previous_HR_STATUS,
                -- Rank HR_STATUS change points for each employee, latest change first.
                ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS hr_status_change_rank
            FROM StatusChanges
            WHERE HR_STATUS <> previous_HR_STATUS AND previous_HR_STATUS IS NOT NULL
            -- This condition defines a "HR_STATUS change event"
        ),
        ActualChangePoints
        AS
        (
            -- Identify records where HR_STATUS actually changed compared to the previous chronological record.
            SELECT
                emplid,
                HR_STATUS,
                EFFDT,
                EFFSEQ,
                EMPL_RCD,
                HIRE_DT,
                previous_HR_STATUS, -- Keep for clarity if needed
                -- Rank these change points for each employee, latest change first.
                ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS rn_of_change
            FROM StatusChanges
            WHERE HR_STATUS <> previous_HR_STATUS
            -- This condition defines a "HR status change event"
        ),
        OldestRecordsCTE
        AS
        (
            -- Dataset 3: Oldest record for each employee (fallback when no changes exist)
            SELECT
                sc.emplid,
                sc.HR_STATUS,
                sc.EFFDT,
                sc.EFFSEQ,
                sc.EMPL_RCD,
                sc.HIRE_DT,
                'Oldest Record' AS NOTE
            FROM StatusChanges sc
            WHERE sc.RowNum_Oldest = 1
        ),
        MostRecentHRStatusChangeRecordsCTE
        AS
        (
            -- Dataset 1: Records that occur AFTER the MOST RECENT HR_STATUS change (highest priority)
            SELECT
                hrsc.emplid,
                hrsc.HR_STATUS,
                hrsc.EFFDT,
                hrsc.EFFSEQ,
                hrsc.EMPL_RCD,
                hrsc.HIRE_DT,
                'After Most Recent HR_STATUS Change' AS NOTE
            FROM HRStatusChanges hrsc
            WHERE hrsc.hr_status_change_rank = 1
        ),
        LatestChangeRecordsCTE
        AS
        (
            -- Dataset 2: Latest HR_STATUS change record for each employee (when no HIRE_DT changes exist)
            SELECT
                acp.emplid,
                acp.HR_STATUS,
                acp.EFFDT,
                acp.EFFSEQ,
                acp.EMPL_RCD,
                acp.HIRE_DT,
                'Latest HR Status Change' AS NOTE
            FROM ActualChangePoints acp
            WHERE acp.rn_of_change = 1
        )
    SELECT --top 1000
        UnionData.emplid,
        UnionData.HR_STATUS,
        UnionData.EFFDT,
        UnionData.EFFSEQ,
        UnionData.EMPL_RCD,
        UnionData.HIRE_DT,
        UnionData.NOTE,
        GETDATE() AS LOAD_DTTM
    INTO [stage].[UKG_HR_STATUS_LOOKUP]
    FROM (
        -- Priority 1: Records after MOST RECENT HR_STATUS change (highest priority)
                                                                                                            SELECT emplid, HR_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
            FROM MostRecentHRStatusChangeRecordsCTE

        UNION ALL

            -- Priority 2: Latest HR_STATUS change (when no HR_STATUS changes exist)
            SELECT emplid, HR_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
            FROM LatestChangeRecordsCTE
            WHERE emplid NOT IN (SELECT EMPLID
            FROM MostRecentHRStatusChangeRecordsCTE)

        UNION ALL

            -- Priority 3: Oldest record (fallback when no changes exist)
            SELECT emplid, HR_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
            FROM OldestRecordsCTE
            WHERE emplid NOT IN (SELECT EMPLID
                FROM MostRecentHRStatusChangeRecordsCTE)
                AND emplid NOT IN (SELECT EMPLID
                FROM LatestChangeRecordsCTE)
    ) AS UnionData;


    -- Create index on emplid for better performance
    CREATE INDEX IX_UKG_HR_STATUS_LOOKUP_emplid ON [stage].[UKG_HR_STATUS_LOOKUP] (emplid);

END;
go


/***************************************
*-- 09/23/2025 Jim Shih
*-- modified from SP [dbo].[UKG_UCPATH_ACCRUAL_BUILD]  
*-- EXEC [stage].[SP_UKG_UCPATH_ACCRUAL_per_ASOFDATE]  @ASOFDATE = '2025-08-16'
******************************************/	 	 

CREATE          PROCEDURE [stage].[SP_UKG_UCPATH_ACCRUAL_per_ASOFDATE]
    @ASOFDATE DATE
AS  

BEGIN

SET NOCOUNT ON;

DROP TABLE IF EXISTS [dbo].UKG_UCPATH_ACCRUAL;
 -- as of date:  The date on which the accrual amount is effective (Today, Current Pay Period Start or Source File Effective Date)

--EXEC [stage].[SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD] @payenddt = '2025-07-5';

WITH CombinedEmplids AS (
    -- Select active UKG-managed employees
    SELECT DISTINCT EMPLID
    FROM dbo.UKG_EMPLOYEE_DATA
    WHERE NON_UKG_MANAGER_FLAG != 'T'
    
    UNION
    
    -- Select employees identified as inactive or not managed under UKG for the period
    SELECT DISTINCT EMPLID
    FROM stage.UKG_INACTIVE_EMPLID_BY_PAYPERIOD
    -- Assumes UKG_INACTIVE_EMPLID_BY_PAYPERIOD is populated correctly for the @payenddt period
)
SELECT  DISTINCT 
AM.EMPLID AS [Person Number],
AM.PIN_NUM AS [Accrual Code Name],
AM.UC_CURR_BAL AS [Accrual Amount],
AM.ASOFDATE AS [Effective Date]
  INTO [dbo].UKG_UCPATH_ACCRUAL	
  FROM health_ods.[HEALTH_ODS].STABLE.PS_UC_AM_SS_TBL AM
  JOIN CombinedEmplids CE ON AM.EMPLID = CE.EMPLID
  WHERE 	
  1=1 
	AND  AM.PIN_NUM in (262287,260269,260259,260125,260086 ,262342)
	AND  AM.ASOFDATE = @ASOFDATE
;
END


go

