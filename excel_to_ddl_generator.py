import pandas as pd
import re
import argparse
import logging

class ExcelToDDLConverter:
    def __init__(self, input_file, table_name):
        self.input_file = input_file
        self.table_name = table_name

    def accept_excel_input(self):
        try:
            return pd.read_excel(self.input_file)
        except FileNotFoundError:
            logging.error("File not found. Please provide a valid file path.")
            exit(1)

    def clean_column_name(self, column_name):
        column_name = column_name.replace(" ", "_")
        column_name = re.sub(r'[^a-zA-Z0-9_]', '', column_name)
        reserved_keywords = ['select', 'from', 'where', 'insert', 'update', 'delete', 'table', 'column']
        if column_name.lower() in reserved_keywords:
            column_name += '_column'
        return column_name.lower()

    def determine_data_type(self, column_data, sample_size=10):
        if column_data.dtype == 'O' and column_data.str.match(r'^[01]$').all():
            return "BOOLEAN"
        elif column_data.dtype == 'O':
            max_length = column_data.str.len().max() + 30
            return f"VARCHAR({max_length})"
        elif column_data.str.isnumeric().all():
            return "INT"
        elif column_data.str.replace(".", "").str.isnumeric().all():
            return "FLOAT"
        else:
            return "VARCHAR(255)"

    def generate_ddl_script(self):
        df = self.accept_excel_input()
        df.columns = [self.clean_column_name(column) for column in df.columns]
        column_data_types = {column: self.determine_data_type(df[column]) for column in df.columns}
        ddl_script = f"CREATE TABLE {self.table_name} (\n"
        for column, data_type in column_data_types.items():
            ddl_script += f"  {column} {data_type},\n"
        ddl_script = ddl_script.rstrip(",\n") + "\n);"
        return ddl_script

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate DDL Script from Excel')
    parser.add_argument('input_file', help='Path to the input Excel file')
    parser.add_argument('table_name', help='Name of the database table')
    args = parser.parse_args()

    logging.basicConfig(filename='script.log', level=logging.INFO, format='%(asctime)s - %(message)s')

    try:
        converter = ExcelToDDLConverter(args.input_file, args.table_name)
        ddl_script = converter.generate_ddl_script()

        print("Cleaned Column Names:")
        print(converter.accept_excel_input().columns)
        print("\nDDL Script:")
        print(ddl_script)

        logging.info('DDL script generated successfully.')

    except Exception as e:
        logging.error(f'An error occurred: {str(e)}')
        print(f'An error occurred. See "script.log" for details.')
