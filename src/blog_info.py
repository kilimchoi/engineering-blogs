import feedfinder2
import csv
import requests

with open("src/blog_info.csv", "r", newline = "", encoding = "utf-8") as infile, \
     open("src/blog_info_tmp.csv", 'w', newline='', encoding='utf-8') as outfile:
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
                new_row = row + ["N/A", "N/A"]
            csv_writer.writerow(new_row)
        else:
            i += 1