#!/usr/bin/env ruby

require 'builder'
require 'json'
require 'net/http'
require 'uri'

# limit = 10

# grab name/url pairings from README
readme = File.open("README.md", "r")
contents = readme.read
matches = contents.scan(/\* (.*) (http.*)/)

Struct.new("Blog", :name, :webURL, :rssURL)
blogs = Array.new

# for each blog URL, check if rss URL exists
matches.each_with_index { |match, index|
  # for testing purposes
  # if index > 10
  #   break
  # end

  rssCheckURL = "http://ajax.googleapis.com/ajax/services/feed/lookup?v=1.0&q=#{match[1]}"
  uri = URI.parse(rssCheckURL)
  STDOUT.write '.'
  response = JSON.parse(Net::HTTP.get(uri))
  if response["responseData"] && response["responseData"].has_key?("url")
    rssURL = response["responseData"]["url"]
    blogs.push(Struct::Blog.new(match[0], match[1], rssURL))
  end
}

puts "done (#{blogs.count} blogs)"

# write opml
xml = Builder::XmlMarkup.new( :indent => 2 )
xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.tag!("opml", {version: "1.0"}) do
  # head
  xml.tag!("head") do
    xml.title "Engineering Blogs"
  end

  # body
  xml.tag!("body") do
    blogs.each { |blog|
      xml.tag!("outline", {type: "rss", text: blog.name, title: blog.name, xmlUrl: blog.rssURL, htmlUrl: blog.webURL})
    }
  end
end

output = File.new("engineering_blogs.opml", "wb")
output.write(xml.target!)
output.close
