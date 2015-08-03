# Contribution Guidelines

Please ensure your pull request adheres to the following guidelines:

- For company blogs, make sure that 80% of content is technical (posts about interesting technical challenges, lessons they've learned, etc). No PR, self-promoting posts.
- For individual blogs, as long as posts are mostly technical (Not as strict with the ratio as the company one), I am happy to add them.
- For both companies and individuals, use the following format: `Name link` e.g. Airbnb http://nerds.airbnb.com/
- The pull request and commit should include what you added/removed.
- If your pull request contains two or more commits, please squash all your commits into one commit using `git rebase` for each pull request you submit.
- After making changes to the README, run `bundle install` to install the dependencies and then the opml generation script (`./generate_opml.rb`) to update the opml file.
