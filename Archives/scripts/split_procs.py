#!/usr/bin/env python3
"""
Small-batch stored-procedure extractor.
Queries the database directly for the concatenated procedures, then processes line-by-line.
Detects CREATE PROCEDURE blocks, writes each procedure to its own SQL file as soon as the block is complete.
Safe default: do not overwrite existing per-proc files.

Run: py -3 scripts\split_procs.py
"""
from pathlib import Path
import re
import sys
import pyodbc

root = Path(__file__).resolve().parent
out_sql_dir = (root / '..' / 'docs' / 'stored_procedures' / 'sql').resolve()
out_md_dir = (root / '..' / 'docs' / 'stored_procedures').resolve()
site_file = (root / '..' / 'docs' / 'site' / 'procs.html').resolve()

out_sql_dir.mkdir(parents=True, exist_ok=True)
out_md_dir.mkdir(parents=True, exist_ok=True)

# Safe defaults
OVERWRITE = False  # set to True to overwrite existing per-proc files

create_re = re.compile(r'(?i)^\s*CREATE\s+PROCEDURE\b')
name_re = re.compile(r'(?i)CREATE\s+PROCEDURE\s+(.+?)\s+AS', re.IGNORECASE | re.DOTALL)

links = []
proc_count = 0
buffer_lines = []
collecting = False
preamble = []

# Query the database for the concatenated procedures
conn_str = 'DRIVER={SQL Server};SERVER=INFOSDBP06\\INFOS06PRD;DATABASE=HealthTime;Trusted_Connection=yes;'
try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    query = """
    SELECT STRING_AGG(CAST(definition AS NVARCHAR(MAX)), '-- ====================================================') AS all_defs 
    FROM sys.sql_modules m 
    INNER JOIN sys.objects o ON m.object_id = o.object_id 
    WHERE o.type = 'P'
    """
    cursor.execute(query)
    row = cursor.fetchone()
    all_defs = row[0] if row else ''
    conn.close()
except Exception as e:
    print(f'Error connecting to database: {e}')
    sys.exit(1)

# Split the concatenated string into lines
lines = all_defs.split('\r\n')

for raw_line in lines:
        line = raw_line
        # If not currently collecting and this line is not CREATE PROCEDURE, accumulate into preamble
        if not collecting:
            if create_re.search(line):
                # start collecting and include preamble (comments, separators) if present
                collecting = True
                buffer_lines = preamble[:]  # copy
                buffer_lines.append(line)
                preamble = []
            else:
                preamble.append(line)
        else:
            # collecting a procedure block
            # detect separator or GO as terminator
            if '-- ====================================================' in line or re.match(r'(?i)^\s*GO\s*($|--)', line):
                # finalize current buffer
                full_block = ''.join(buffer_lines).rstrip() + '\n'
                # process if it contains CREATE PROCEDURE
                if re.search(r'(?i)CREATE\s+PROCEDURE', full_block):
                    proc_count += 1
                    # extract name
                    m = name_re.search(full_block)
                    if m:
                        raw_name = m.group(1).strip()
                    else:
                        raw_name = f'proc_{proc_count}'

                    # sanitize raw_name for filename
                    san = raw_name.replace('\t', ' ').replace('"', '').replace("'", '')
                    san = san.replace('[', '').replace(']', '')
                    san = re.sub(r'[^a-zA-Z0-9._-]', '_', san)
                    san = re.sub(r'\s+', '_', san).strip('_')
                    san = san.replace('..', '.')
                    if '.' not in san:
                        filename_base = f'unknown.{san}'
                    else:
                        filename_base = san

                    sql_path = out_sql_dir / (filename_base + '.sql')
                    md_path = out_md_dir / (filename_base + '.md')

                    wrote_sql = False
                    if OVERWRITE or not sql_path.exists():
                        sql_path.write_text(full_block + '\n', encoding='utf-8')
                        wrote_sql = True

                    upper = full_block.upper()
                    flags = {
                        'uses_hashbytes': 'HASHBYTES' in upper,
                        'uses_merge': re.search(r'\bMERGE\b', upper) is not None,
                        'uses_select_into': 'SELECT' in upper and 'INTO' in upper,
                        'uses_temp_tables': ('DROP TABLE IF EXISTS' in upper) or ('INTO #' in upper) or (re.search(r'\b#\w+', upper) is not None),
                        'uses_dynamic_sql': ('SP_EXECUTESQL' in upper) or ('EXEC(' in upper) or (re.search(r'EXEC\s+@', upper) is not None),
                        'uses_transactions': any(t in upper for t in ('BEGIN TRAN', 'COMMIT TRAN', 'ROLLBACK TRAN', 'BEGIN TRANSACTION', 'COMMIT TRANSACTION', 'ROLLBACK TRANSACTION')),
                        'uses_drop_table_if_exists': 'DROP TABLE IF EXISTS' in upper,
                    }

                    md_lines = []
                    md_lines.append(f'# {filename_base}')
                    md_lines.append('')
                    md_lines.append('Source: docs/stored_procedures/all_procedures.sql')
                    md_lines.append('')
                    md_lines.append(f'Link to SQL: sql/{filename_base}.sql')
                    md_lines.append('')
                    md_lines.append('Detected features:')
                    for k, v in flags.items():
                        md_lines.append(f'- {k}: {v}')
                    md_lines.append('')
                    md_lines.append('---')
                    md_lines.append('')
                    md_lines.append('```sql')
                    preview_lines = full_block.splitlines()
                    preview = '\n'.join(preview_lines[:300])
                    md_lines.append(preview)
                    md_lines.append('```')

                    wrote_md = False
                    if OVERWRITE or not md_path.exists():
                        md_path.write_text('\n'.join(md_lines) + '\n', encoding='utf-8')
                        wrote_md = True

                    extra = []
                    if flags['uses_hashbytes']:
                        extra.append('HASHBYTES')
                    if flags['uses_merge']:
                        extra.append('MERGE')
                    extras = ' '.join(extra)

                    note = ''
                    if not wrote_sql:
                        note = ' (sql exists)'
                    if not wrote_md:
                        note += ' (md exists)'

                    links.append(f"<li><a href='../stored_procedures/sql/{filename_base}.sql'>{filename_base}</a> - {extras}{note}</li>")

                # reset
                collecting = False
                buffer_lines = []
            else:
                buffer_lines.append(line)

# End of file: if still collecting, finalize
if collecting and buffer_lines:
    full_block = ''.join(buffer_lines).rstrip() + '\n'
    if re.search(r'(?i)CREATE\s+PROCEDURE', full_block):
        proc_count += 1
        m = name_re.search(full_block)
        if m:
            raw_name = m.group(1).strip()
        else:
            raw_name = f'proc_{proc_count}'

        san = raw_name.replace('\t', ' ').replace('"', '').replace("'", '')
        san = san.replace('[', '').replace(']', '')
        san = re.sub(r'[^a-zA-Z0-9._-]', '_', san)
        san = re.sub(r'\s+', '_', san).strip('_')
        san = san.replace('..', '.')
        if '.' not in san:
            filename_base = f'unknown.{san}'
        else:
            filename_base = san

        sql_path = out_sql_dir / (filename_base + '.sql')
        if OVERWRITE or not sql_path.exists():
            sql_path.write_text(full_block + '\n', encoding='utf-8')

        upper = full_block.upper()
        flags = {
            'uses_hashbytes': 'HASHBYTES' in upper,
            'uses_merge': re.search(r'\bMERGE\b', upper) is not None,
            'uses_select_into': 'SELECT' in upper and 'INTO' in upper,
            'uses_temp_tables': ('DROP TABLE IF EXISTS' in upper) or ('INTO #' in upper) or (re.search(r'\b#\w+', upper) is not None),
            'uses_dynamic_sql': ('SP_EXECUTESQL' in upper) or ('EXEC(' in upper) or (re.search(r'EXEC\s+@', upper) is not None),
            'uses_transactions': any(t in upper for t in ('BEGIN TRAN', 'COMMIT TRAN', 'ROLLBACK TRAN', 'BEGIN TRANSACTION', 'COMMIT TRANSACTION', 'ROLLBACK TRANSACTION')),
            'uses_drop_table_if_exists': 'DROP TABLE IF EXISTS' in upper,
        }

        md_path = out_md_dir / (filename_base + '.md')
        md_lines = []
        md_lines.append(f'# {filename_base}')
        md_lines.append('')
        md_lines.append('Source: docs/stored_procedures/all_procedures.sql')
        md_lines.append('')
        md_lines.append(f'Link to SQL: sql/{filename_base}.sql')
        md_lines.append('')
        md_lines.append('Detected features:')
        for k, v in flags.items():
            md_lines.append(f'- {k}: {v}')
        md_lines.append('')
        md_lines.append('---')
        md_lines.append('')
        md_lines.append('```sql')
        preview_lines = full_block.splitlines()
        preview = '\n'.join(preview_lines[:300])
        md_lines.append(preview)
        md_lines.append('```')

        if OVERWRITE or not md_path.exists():
            md_path.write_text('\n'.join(md_lines) + '\n', encoding='utf-8')

        extra = []
        if flags['uses_hashbytes']:
            extra.append('HASHBYTES')
        if flags['uses_merge']:
            extra.append('MERGE')
        extras = ' '.join(extra)

        note = ''
        links.append(f"<li><a href='../stored_procedures/sql/{filename_base}.sql'>{filename_base}</a> - {extras}{note}</li>")

# Update site file if exists
if site_file.exists():
    site_text = site_file.read_text(encoding='utf-8')
    start = '<!-- PROC_LIST_START -->'
    end = '<!-- PROC_LIST_END -->'
    if start in site_text and end in site_text:
        before, rest = site_text.split(start, 1)
        _mid, after = rest.split(end, 1)
        new_mid = '\n<ul>\n' + '\n'.join(links) + '\n</ul>\n'
        site_file.write_text(before + start + new_mid + end + after, encoding='utf-8')
        print('Updated site file:', site_file)
    else:
        print('Site file does not contain markers; skipping update:', site_file)
else:
    print('Site file not found, skipping site update:', site_file)

print(f'Processed {proc_count} procedures. SQL files in: {out_sql_dir}, Markdown in: {out_md_dir}')
