#!/usr/bin/python

import csv
import sys

if len(sys.argv) != 2:
    print("Usage: python script.py <input_csv_file>")
    sys.exit(1)

input_file_path = sys.argv[1]
output_file_path = 'scopes.txt'

true_rows = []
false_rows = []
columns_to_keep = ["identifier", "asset_type", "instruction"]

try:
    with open(input_file_path, mode='r') as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            # Normalize the eligible_for_submission value
            submission_status = row['eligible_for_submission'].strip().lower()
            if submission_status == 'true':
                true_rows.append(row)
            elif submission_status == 'false':
                false_rows.append(row)

    with open(output_file_path, mode='w') as output_file:
        output_file.write("=== Eligible for Submission: TRUE ===\n")
        for row in true_rows:
            output_file.write(', '.join(row[key] for key in columns_to_keep if key in row) + "\n")
        output_file.write("\n=== Eligible for Submission: FALSE ===\n")
        for row in false_rows:
            output_file.write(', '.join(row[key] for key in columns_to_keep if key in row) + "\n")

    print(f"Separation completed. Results saved to '{output_file_path}'.")

except FileNotFoundError:
    print(f"Error: File '{input_file_path}' not found.")
    sys.exit(1)
except Exception as e:
    print(f"An error occurred: {e}")
    sys.exit(1)
