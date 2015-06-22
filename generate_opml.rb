#!/usr/bin/env ruby

require 'builder'
require 'json'
require 'net/http'
require 'nokogiri'
require 'uri'
require 'feedbag'

OUTPUT_FILENAME = 'engineering_blogs.opml'
LIMIT = 10
TITLE = 'Engineering Blogs'

# grab name/url pairings from README.md
readme = File.open('README.md', 'r')
contents = readme.read
matches = contents.scan(/\* (.*) (http.*)/)

Struct.new('Blog', :name, :web_url, :rss_url)
blogs = []

# for each blog URL, check if rss URL exists
matches.each_with_index do |match, _|
  # for testing purposes
  # if index > LIMIT
  #   break
  # end

  name = match[0]
  web_url = match[1]

  # if rss_url already in existing opml file, use that; otherwise, do a lookup
  rss_url = nil
  if File.exist?(OUTPUT_FILENAME)
    xml = Nokogiri::XML(File.open(OUTPUT_FILENAME))
    existing_blog = xml.xpath("//outline[@htmlUrl='#{web_url}']").first
    unless existing_blog.nil?
      rss_url = existing_blog.attr('xmlUrl')
      puts "#{name}: ALREADY HAVE"
    end
  end

  if rss_url.nil?
    puts "#{name}: GETTING"
    rss_check_url = "http://ajax.googleapis.com/ajax/services/feed/lookup?v=1.0&q=#{web_url}"
    uri = URI.parse(rss_check_url)
    response = JSON.parse(Net::HTTP.get(uri))
    rss_url = response['responseData']['url'] if response['responseData'] && response['responseData'].has_key?('url')
    unless rss_url
      rss_url = Feedbag.find web_url
      if rss_url.length == 0
        %w(rss feed feeds).each do |e|
          web_url << '/' if web_url[-1] != '/'
          if Feedbag.feed? (web_url + e)
            rss_url = web_url + e
            break
          end
        end
      else
        rss_url = rss_url.first if rss_url.first.length > 0
      end
    end
  end

  blogs.push(Struct::Blog.new(name, web_url, rss_url)) if !rss_url.nil? && rss_url.length > 0
end

blogs.sort_by { |b| b.name.capitalize }

# write opml
xml = Builder::XmlMarkup.new(indent: 2)
xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.tag!('opml', version: '1.0') do
  # head
  xml.tag!('head') do
    xml.title TITLE
  end

  # body
  xml.tag!('body') do
    xml.tag!('outline', text: TITLE, title: TITLE) do
      blogs.each do |blog|
        xml.tag!('outline', type: 'rss', text: blog.name, title: blog.name,
          xmlUrl: blog.rss_url, htmlUrl: blog.web_url)
      end
    end
  end
end

output = File.new(OUTPUT_FILENAME, 'wb')
output.write(xml.target!)
output.close

puts "DONE: #{blogs.count} written to #{OUTPUT_FILENAME}"
