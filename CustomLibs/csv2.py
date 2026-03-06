import csv
import pandas as pd
# Previous function to go to nth row and nth column
def go_to_nth_row_nth_column(File, row_no, col_no):
    inputFile = File
    row_no = int(row_no)
    col_no = int(col_no)
    with open(inputFile) as ip:
        reader = csv.reader(ip)
        for i, row in enumerate(reader):
            if i == row_no:  # here's the row
                # print row[col_no] # here's the column
                i +=1
                print(row[col_no])
            row_no += 1



# Function to find the string values, in case of duplicate occurrence as well
def search_cell(File, search_string):
    inputFile = File
    search_position = []  # empty list which will later store row,column occurences
    with open(inputFile) as ip:
        reader = csv.reader(ip)
        for i, row in enumerate(reader):
            for j, column in enumerate(row):
                if search_string in column:  # here's the row
                    # print((i,j))
                    search_position.append(
                        (i, j))  # this will create list of list i.e. list of row,columns in case of multi occurences
                    # return (i,j)
    return search_position



def get_column_value(File,col_name):
    csv = pd.read_csv(File, delimiter=',', skipinitialspace=True)
    return (csv[col_name].values.tolist())

def get_txt_file(File_txt,File_csv):
    with open(str(File_txt), 'r') as in_file:
        stripped = (line.strip() for line in in_file)
        lines = (line.split(",") for line in stripped if line)
        with open(str(File_csv), 'w') as out_file:
            writer = csv.writer(out_file)
            writer.writerows(lines)




