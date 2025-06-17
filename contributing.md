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

If you do not have Ruby readily available, you can use Docker to run the OPML generation script. Follow these steps:

```bash
# 1. Pull and run the Ruby 3.3.7 container
docker run -it -e LANG=C.UTF-8 --name=blogs ruby:3.3.7 /bin/bash

# 2. Inside the container, update RubyGems and install bundler
gem update --system
gem install bundler

# 3. Clone the repository
git clone https://github.com/<username>/engineering-blogs.git
cd engineering-blogs

# 4. Remove existing Gemfile.lock to ensure fresh installation
rm -f Gemfile.lock

# 5. Install dependencies
bundle install

# 6. Generate the OPML file
ruby generate_opml.rb

# 7. Exit the Docker container (type 'exit' or press Ctrl+D)
exit

# 8. Now in your host machine terminal, copy the generated file
# Make sure to include the dot (.) at the end of the command
docker cp blogs:/engineering-blogs/engineering_blogs.opml .

# 9. Clean up the Docker container
docker rm blogs
```

### Important Notes:

1. **Dependencies**: If you encounter any issues with dependencies, make sure you're using the latest versions specified in the Gemfile. The instructions above include removing the Gemfile.lock to ensure all dependencies are properly resolved for Ruby 3.3.7.

2. **Docker Commands**:
   - Make sure to exit the Docker container before running the `docker cp` command, as this command needs to be run from your host machine's terminal, not from inside the container.
   - The `docker cp` command requires two arguments: the source path and the destination path. The dot (.) at the end of the command is important as it specifies the current directory as the destination.

3. **Troubleshooting**:
   - If you encounter any issues with the Docker container, you can remove it using `docker rm -f blogs` and start fresh.
   - Make sure you have sufficient disk space and Docker is running properly on your system.
