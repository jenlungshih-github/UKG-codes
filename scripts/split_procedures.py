import re
import os

# Path to the concatenated file
input_file = 'docs/stored_procedures/all_procedures.sql'
output_dir = 'docs/stored_procedures/sql'

# Create output directory if not exists
os.makedirs(output_dir, exist_ok=True)

with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Split on the separator pattern
sections = re.split(r'-- =====================================================-- ([a-zA-Z_]+\.[a-zA-Z_]+)', content)

# sections[0] is before first separator
# sections[1] is first proc_name
# sections[2] is first content
# etc.

for i in range(1, len(sections), 2):
    proc_name = sections[i]
    proc_content = sections[i+1]
    # Remove trailing end marker if present
    proc_content = re.sub(r'-- End of concatenated stored procedures.*', '', proc_content, flags=re.DOTALL)
    output_file = os.path.join(output_dir, f'{proc_name}.sql')
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(proc_content.strip())
    print(f'Saved {proc_name} to {output_file}')