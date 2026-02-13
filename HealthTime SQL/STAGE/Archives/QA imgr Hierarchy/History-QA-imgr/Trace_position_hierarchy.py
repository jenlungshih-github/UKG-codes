import pyodbc
import pandas as pd

def trace_position_hierarchy(position_nbr):
    """
    Trace a position through all hierarchy levels in UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL table
    """
    try:
        # Connect to database
        conn = get_database_connection()
        
        # SQL query to get hierarchy trace for specific position
        query = """
        SELECT 
            [LEVEL UP],
            [Inactive_EMPLID_POSITION_NBR],
            [POSITION_REPORTS_TO],
            [POSN_STATUS],
            [PS_JOB_EMPLID],
            [PS_JOB_HR_STATUS],
            [NOTE],
            [PROCESSED_DT]
        FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
        WHERE [Inactive_EMPLID_POSITION_NBR] = ?
        ORDER BY [LEVEL UP], [PROCESSED_DT]
        """
        
        # Execute query
        df = pd.read_sql(query, conn, params=[position_nbr])
        
        # Close connection
        conn.close()
        
        # Display results
        if df.empty:
            print(f"No records found for Inactive_EMPLID_POSITION_NBR = '{position_nbr}'")
            return
        
        print(f"Position Hierarchy Trace for: {position_nbr}")
        print("=" * 80)
        
        for index, row in df.iterrows():
            level = row['LEVEL UP']
            position_reports_to = row['POSITION_REPORTS_TO'] if pd.notna(row['POSITION_REPORTS_TO']) else 'NULL'
            posn_status = row['POSN_STATUS'] if pd.notna(row['POSN_STATUS']) else 'NULL'
            ps_job_emplid = row['PS_JOB_EMPLID'] if pd.notna(row['PS_JOB_EMPLID']) else 'NULL'
            ps_job_hr_status = row['PS_JOB_HR_STATUS'] if pd.notna(row['PS_JOB_HR_STATUS']) else 'NULL'
            note = row['NOTE'] if pd.notna(row['NOTE']) else 'NULL'
            processed_dt = row['PROCESSED_DT']
            
            print(f"\nLEVEL UP {level}:")
            print(f"  Position Reports To: {position_reports_to}")
            print(f"  Position Status:     {posn_status}")
            print(f"  PS_JOB_EMPLID:      {ps_job_emplid}")
            print(f"  PS_JOB_HR_STATUS:   {ps_job_hr_status}")
            print(f"  Note:               {note}")
            print(f"  Processed Date:     {processed_dt}")
        
        print("\n" + "=" * 80)
        print(f"Total levels found: {len(df)}")
        
        # Return dataframe for further analysis if needed
        return df
        
    except Exception as e:
        print(f"Error: {e}")
        return None

def get_database_connection():
    """
    Get database connection with fallback driver options
    """
    server = 'INFOSDBT01\\INFOS01TST'
    database = 'HealthTime'
    
    # Try multiple ODBC drivers in order of preference
    drivers = [
        'ODBC Driver 17 for SQL Server',
        'ODBC Driver 13 for SQL Server', 
        'ODBC Driver 11 for SQL Server',
        'SQL Server Native Client 11.0',
        'SQL Server Native Client 10.0',
        'SQL Server'
    ]
    
    for driver in drivers:
        try:
            conn_str = f'DRIVER={{{driver}}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'
            conn = pyodbc.connect(conn_str)
            print(f"Connected successfully using driver: {driver}")
            return conn
        except pyodbc.Error as e:
            print(f"Failed to connect with {driver}: {e}")
            continue
    
    raise Exception("Could not connect with any available ODBC driver")

def trace_manager_hierarchy_chain(position_nbr):
    """
    Trace the complete manager hierarchy chain by following PS_JOB_EMPLID through all levels
    """
    try:
        conn = get_database_connection()
        
        print(f"\nManager Hierarchy Chain Analysis for Position: {position_nbr}")
        print("=" * 80)
        
        # Get all records for the initial position across all levels
        query = """
        SELECT 
            [LEVEL UP],
            [Inactive_EMPLID_POSITION_NBR],
            [Inactive_EMPLID],
            [POSITION_REPORTS_TO],
            [POSN_STATUS],
            [PS_JOB_EMPLID],
            [PS_JOB_HR_STATUS],
            [NOTE]
        FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
        WHERE [Inactive_EMPLID_POSITION_NBR] = ?
        ORDER BY [LEVEL UP]
        """
        
        df = pd.read_sql(query, conn, params=[position_nbr])
        
        if df.empty:
            print(f"No hierarchy data found for position {position_nbr}")
            conn.close()
            return
        
        print(f"\nDirect Records for Position {position_nbr}:")
        print("-" * 60)
        
        manager_chain = []
        
        for index, row in df.iterrows():
            level = row['LEVEL UP']
            inactive_emplid = row['Inactive_EMPLID'] if pd.notna(row['Inactive_EMPLID']) else 'NULL'
            position_reports_to = row['POSITION_REPORTS_TO'] if pd.notna(row['POSITION_REPORTS_TO']) else 'NULL'
            posn_status = row['POSN_STATUS'] if pd.notna(row['POSN_STATUS']) else 'NULL'
            ps_job_emplid = row['PS_JOB_EMPLID'] if pd.notna(row['PS_JOB_EMPLID']) else 'NULL'
            ps_job_hr_status = row['PS_JOB_HR_STATUS'] if pd.notna(row['PS_JOB_HR_STATUS']) else 'NULL'
            note = row['NOTE'] if pd.notna(row['NOTE']) else 'NULL'
            
            print(f"\nLevel {level}:")
            print(f"  Position:           {position_nbr}")
            print(f"  Inactive EMPLID:    {inactive_emplid}")
            print(f"  Reports To:         {position_reports_to}")
            print(f"  Position Status:    {posn_status}")
            print(f"  Manager EMPLID:     {ps_job_emplid}")
            print(f"  Manager HR Status:  {ps_job_hr_status}")
            print(f"  Note:              {note}")
            
            # Add manager to chain for further tracing
            if ps_job_emplid != 'NULL' and ps_job_emplid not in manager_chain:
                manager_chain.append(ps_job_emplid)
        
        # Now trace each manager up the hierarchy
        for manager_emplid in manager_chain:
            print(f"\n" + "=" * 80)
            print(f"Tracing Manager Chain for EMPLID: {manager_emplid}")
            print("=" * 80)
            
            # Find where this manager appears as Inactive_EMPLID in higher levels
            manager_query = """
            SELECT 
                [LEVEL UP],
                [Inactive_EMPLID],
                [POSITION_REPORTS_TO],
                [POSN_STATUS],
                [PS_JOB_EMPLID],
                [PS_JOB_HR_STATUS],
                [NOTE]
            FROM [HealthTime].[stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
            WHERE [Inactive_EMPLID] = ?
            ORDER BY [LEVEL UP]
            """
            
            manager_df = pd.read_sql(manager_query, conn, params=[manager_emplid])
            
            if manager_df.empty:
                print(f"  Manager {manager_emplid} - TOP OF HIERARCHY (no higher level records)")
            else:
                for idx, mgr_row in manager_df.iterrows():
                    mgr_level = mgr_row['LEVEL UP']
                    mgr_position_reports_to = mgr_row['POSITION_REPORTS_TO'] if pd.notna(mgr_row['POSITION_REPORTS_TO']) else 'NULL'
                    mgr_posn_status = mgr_row['POSN_STATUS'] if pd.notna(mgr_row['POSN_STATUS']) else 'NULL'
                    mgr_ps_job_emplid = mgr_row['PS_JOB_EMPLID'] if pd.notna(mgr_row['PS_JOB_EMPLID']) else 'NULL'
                    mgr_ps_job_hr_status = mgr_row['PS_JOB_HR_STATUS'] if pd.notna(mgr_row['PS_JOB_HR_STATUS']) else 'NULL'
                    mgr_note = mgr_row['NOTE'] if pd.notna(mgr_row['NOTE']) else 'NULL'
                    
                    print(f"\n  Level {mgr_level}:")
                    print(f"    Manager EMPLID:     {manager_emplid}")
                    print(f"    Reports To:         {mgr_position_reports_to}")
                    print(f"    Position Status:    {mgr_posn_status}")
                    print(f"    Their Manager:      {mgr_ps_job_emplid}")
                    print(f"    Manager HR Status:  {mgr_ps_job_hr_status}")
                    print(f"    Note:              {mgr_note}")
        
        conn.close()
        
    except Exception as e:
        print(f"Error in manager hierarchy chain analysis: {e}")

if __name__ == "__main__":
    # Trace specific position
    target_position = '40700570'
    
    print("POSITION HIERARCHY TRACE ANALYSIS")
    print("=" * 50)
    
    # Method 1: Direct trace from LEVEL_BY_LEVEL table
    result_df = trace_position_hierarchy(target_position)
    
    # Method 2: Complete manager hierarchy chain analysis
    trace_manager_hierarchy_chain(target_position)