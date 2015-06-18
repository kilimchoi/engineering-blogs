#!/usr/bin/env ruby

require 'builder'
require 'json'
require 'net/http'
require 'nokogiri'
require 'uri'

OUTPUT_FILENAME = "engineering_blogs.opml"
LIMIT = 10

# grab name/url pairings from README
readme = File.open("README.md", "r")
contents = readme.read
matches = contents.scan(/\* (.*) (http.*)/)

Struct.new("Blog", :name, :webURL, :rssURL)
blogs = Array.new

# for each blog URL, check if rss URL exists
matches.each_with_index { |match, index|
  # for testing purposes
  # if index > LIMIT
  #   break
  # end

  name = match[0]
  webURL = match[1]

  # if rssURL already in existing opml file, use that; otherwise, do a lookup
  if File.exist?(OUTPUT_FILENAME)
    xml = Nokogiri::XML(File.open(OUTPUT_FILENAME))
    existingBlog = xml.xpath("//outline[@htmlUrl='#{webURL}']").first
    if existingBlog != nil
      rssURL = existingBlog.attr('xmlUrl')
      puts "#{name}: ALREADY HAVE"
    end
  end

  if rssURL.nil?
    puts "#{name}: GETTING"
    rssCheckURL = "http://ajax.googleapis.com/ajax/services/feed/lookup?v=1.0&q=#{match[1]}"
    uri = URI.parse(rssCheckURL)
    response = JSON.parse(Net::HTTP.get(uri))
    if response["responseData"] && response["responseData"].has_key?("url")
      rssURL = response["responseData"]["url"]
    end
  end

  if rssURL != nil
    blogs.push(Struct::Blog.new(name, webURL, rssURL))
  end
}

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

output = File.new(OUTPUT_FILENAME, "wb")
output.write(xml.target!)
output.close

puts "DONE: #{blogs.count} written to #{OUTPUT_FILENAME}"
