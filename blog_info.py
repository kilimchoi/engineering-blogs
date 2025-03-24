import feedfinder2
import csv
import requests
import os

with open("blog_info.csv", "r", newline = "", encoding = "utf-8") as infile, \
     open("blog_info_tmp.csv", 'w', newline='', encoding='utf-8') as outfile:
    csv_reader = csv.reader(infile)
    csv_writer = csv.writer(outfile)
    csv_writer.writerow(["Name","URL","Feed","Status"])
    i = 0
    for row in csv_reader:
        if i != 0:
            i += 1
            rss_feed = feedfinder2.find_feeds(row[-1])
            new_row = ''
            if rss_feed:
                up_check = requests.head(rss_feed[0], timeout=3).status_code
                if up_check == 200:
                    new_row = row + [rss_feed[0], ":white_check_mark:"]
                else:
                    new_row = row + [rss_feed[0], ":x:"]
            else:
                new_row = row + [":grey_question:", ":grey_question:"]
            print(new_row)
            csv_writer.writerow(new_row)
        else:
            i += 1
os.remove("blog_info.csv")
os.rename("blog_info_tmp.csv", "blog_info.csv")