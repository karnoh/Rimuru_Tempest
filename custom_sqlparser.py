import sqlparse

# Custom SQL Parser
class MyUniqueSQLParser:
    def __init__(self):
        # Store parsed SQL elements
        self.tables = set()
        self.columns = set()
        self.where_conditions = set()
        self.joins = set()

    def extract_table_column_where(self, statement):
        for item in statement.tokens:
            if item.is_group():
                # Extract table names from 'FROM' clause
                if item.get_real_name() == 'FROM':
                    for table_item in item.tokens:
                        if table_item.ttype is None:
                            self.tables.add(table_item.get_real_name())
                # Extract join conditions
                elif item.get_real_name() == 'JOIN':
                    join_condition = ''
                    for join_item in item.tokens:
                        if join_item.ttype is None:
                            join_condition += join_item.get_real_name() + ' '
                    self.joins.add(join_condition.strip())
            # Extract WHERE conditions
            elif item.get_real_name() == 'WHERE':
                where_clause = ''
                for where_item in item.tokens:
                    if where_item.ttype is None:
                        where_clause += where_item.get_real_name() + ' '
                self.where_conditions.add(where_clause.strip())
            # Extract selected columns
            elif item.get_real_name() == 'SELECT':
                for select_item in item.tokens:
                    if select_item.ttype is None:
                        if '.' in select_item.get_real_name():
                            self.columns.add(select_item.get_real_name())

    def parse_sql(self, sql_query):
        parsed = sqlparse.parse(sql_query)
        for statement in parsed:
            self.extract_table_column_where(statement)

if __name__ == "__main__":
    print("Welcome to MyUniqueSQLParser!")
    sql_parser = MyUniqueSQLParser()
    file_path = input("Enter the path to the file containing your SQL query: ")

    try:
        with open(file_path, 'r') as file:
            sql_query = file.read()
            sql_parser.parse_sql(sql_query)

            print("\nTables:")
            for table in sql_parser.tables:
                print(table)

            print("\nColumns:")
            for column in sql_parser.columns:
                print(column)

            print("\nJoin Conditions:")
            for join in sql_parser.joins:
                print(join)

            print("\nWhere Conditions:")
            for where_condition in sql_parser.where_conditions:
                print(where_condition)
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
