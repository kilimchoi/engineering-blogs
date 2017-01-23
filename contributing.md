# Contribution Guidelines

Please ensure your pull request adheres to the following guidelines:

- One pull request per add.
- The pull request and commit message should include what was added/removed. It should also include one sentence summary of why you think this blog deserves recognition.
- Please squash related commits for each pull request you submit.
- Use the following format: `Name link summary` e.g. Airbnb http://nerds.airbnb.com/
- For company blogs, make sure that 80% of content is technical (posts about interesting technical challenges, lessons they've learned, etc). No PR, self-promoting posts.
- For individual blogs, as long as posts are mostly technical (80% technical as well), and has a decent number of followers, I'm happy to add them.
- After making changes to the README, run `bundle install` to install the dependencies and then the opml generation script (`./generate_opml.rb`) to update the opml file.

## Running the OPML Generation Script with Docker
If you do not have Ruby readily available the following steps can be used to run the OPML generation script with Docker:

```
docker run -it -e LANG=C.UTF-8 --name=blogs ruby:2.2 /bin/bash
git clone https://github.com/<username>/engineering-blogs.git
cd engineering-blogs
bundle install
ruby generate_opml.rb
docker cp blogs:/engineering-blogs/engineering_blogs.opml .
```
