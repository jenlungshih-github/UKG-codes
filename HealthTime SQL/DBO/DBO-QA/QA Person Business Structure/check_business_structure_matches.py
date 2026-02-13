import pyodbc

# Database connection parameters
server = 'INFOSDBT01\\INFOS01TST'
database = 'HealthTime'
driver = '{ODBC Driver 17 for SQL Server}'

# List of employee IDs to check
employee_list = [
    ('10401420', 'Mayra', 'Rodriguez Rodriguez'),
    ('10405360', 'Farrah', 'Petrizzo'),
    ('10406848', 'Maria', 'Aragon'),
    ('10409321', 'Rosa', 'Ramirez'),
    ('10413689', 'Natalie', 'Jenkins'),
    ('10415110', 'Emily', 'St Germain'),
    ('10420612', 'Marcela', 'Carrera'),
    ('10422674', 'David', 'Rojas'),
    ('10438746', 'Juliana', 'Silvernail-Gaspar'),
    ('10467173', 'Laura', 'Kinney'),
    ('10491749', 'Victor', 'Archibeque'),
    ('10578994', 'Joanna', 'Sabilano'),
    ('10624479', 'Andrea', 'Cota'),
    ('10649385', 'Korinne', 'Hickman'),
    ('10705785', 'Maura', 'Lynch'),
    ('10715715', 'Connor', 'Osato'),
    ('10730925', 'Ronald', 'Schwartz'),
    ('10744203', 'Lucia', 'Ramirez'),
    ('10822439', 'Dejennae', 'Palacio')
]

def check_business_structure_matches():
    """Check business structure matches for all employees in the list"""
    
    # Establish connection
    connection_string = f"DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes;"
    
    try:
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        
        print("=" * 80)
        print("BUSINESS STRUCTURE MATCH CHECK RESULTS")
        print("=" * 80)
        
        matched_employees = []
        unmatched_employees = []
        not_found_employees = []
        
        for emplid, first_name, last_name in employee_list:
            try:
                # Execute the stored procedure
                cursor.execute("EXEC [stage].[SP_Check_Person_Business_Structure] @emplid = ?", emplid)
                
                # Fetch results
                results = cursor.fetchall()
                
                if results:
                    row = results[0]
                    match_status = row[11]  # BusinessStructure_Match_Status column
                    
                    if match_status == 'MATCH FOUND':
                        matched_employees.append({
                            'EMPLID': emplid,
                            'First_Name': first_name,
                            'Last_Name': last_name,
                            'Status': 'MATCHED'
                        })
                    else:
                        unmatched_employees.append({
                            'EMPLID': emplid,
                            'First_Name': first_name,
                            'Last_Name': last_name,
                            'Status': 'NO MATCH',
                            'FundGroup': row[8],  # FundGroup column
                            'DEPTID': row[5]      # DEPTID column
                        })
                else:
                    not_found_employees.append({
                        'EMPLID': emplid,
                        'First_Name': first_name,
                        'Last_Name': last_name,
                        'Status': 'NOT FOUND IN SYSTEM'
                    })
                    
            except Exception as e:
                print(f"Error checking employee {emplid} ({first_name} {last_name}): {str(e)}")
                not_found_employees.append({
                    'EMPLID': emplid,
                    'First_Name': first_name,
                    'Last_Name': last_name,
                    'Status': f'ERROR: {str(e)}'
                })
        
        # Display results
        print(f"\nSUMMARY:")
        print(f"Total Employees Checked: {len(employee_list)}")
        print(f"Matched: {len(matched_employees)}")
        print(f"Unmatched: {len(unmatched_employees)}")
        print(f"Not Found/Error: {len(not_found_employees)}")
        
        # Show unmatched employees in detail
        if unmatched_employees:
            print(f"\n{'='*60}")
            print("UNMATCHED EMPLOYEES (NO BUSINESS STRUCTURE MATCH):")
            print(f"{'='*60}")
            for emp in unmatched_employees:
                print(f"Employee ID: {emp['EMPLID']}")
                print(f"Name: {emp['First_Name']} {emp['Last_Name']}")
                print(f"FundGroup: {emp['FundGroup']}")
                print(f"DEPTID: {emp['DEPTID']}")
                print(f"Status: {emp['Status']}")
                print("-" * 40)
        
        # Show not found employees
        if not_found_employees:
            print(f"\n{'='*60}")
            print("EMPLOYEES NOT FOUND IN SYSTEM:")
            print(f"{'='*60}")
            for emp in not_found_employees:
                print(f"Employee ID: {emp['EMPLID']}")
                print(f"Name: {emp['First_Name']} {emp['Last_Name']}")
                print(f"Status: {emp['Status']}")
                print("-" * 40)
        
        # Show matched employees summary
        if matched_employees:
            print(f"\n{'='*60}")
            print("MATCHED EMPLOYEES:")
            print(f"{'='*60}")
            for emp in matched_employees:
                print(f"{emp['EMPLID']} - {emp['First_Name']} {emp['Last_Name']} - {emp['Status']}")
        
        print(f"\n{'='*80}")
        print("CHECK COMPLETED")
        print(f"{'='*80}")
        
    except Exception as e:
        print(f"Database connection error: {str(e)}")
    
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    check_business_structure_matches()
