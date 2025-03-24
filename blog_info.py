import csv
import requests
import os

with open("blog_info.csv", "r", newline = "", encoding = "utf-8") as infile, \
     open("blog_info_tmp.csv", 'w', newline='', encoding='utf-8') as outfile:
    csv_reader = csv.reader(infile)
    csv_writer = csv.writer(outfile)
    csv_writer.writerow(["Name","URL","Status"])
    i = 0
    for row in csv_reader:
        if i != 0:
            i += 1
            new_row = ''
            up_check = requests.head(row[1], timeout=3).status_code
            if up_check == 200:
                new_row = [row[0], row[1], ":white_check_mark:"]
            else:
                new_row = [row[0], row[1], ":x:"]
            csv_writer.writerow(new_row)
        else:
            i += 1
os.remove("blog_info.csv")
os.rename("blog_info_tmp.csv", "blog_info.csv")