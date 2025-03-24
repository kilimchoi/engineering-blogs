import csv 

markdown = "# Engineering Blogs\n\n"

with open("blog_info.csv", "r") as infile:
    csv_reader = csv.reader(infile)
    i = 0
    for row in csv_reader:
        if i == 1:
            markdown_table = "|"
            for col in range(len(row)):
                markdown_table += "--------|"
            markdown += f"{markdown_table}\n"
            i += 1
        markdown_table = "|" + "|".join(row) + "|"
        markdown += f"{markdown_table}\n"
        i += 1

with open("README.md", "w") as outfile:
    outfile.write(markdown)
        