#!/usr/bin/env ruby

require 'builder'
require 'feedbag'
require 'json'
require 'net/http'
require 'nokogiri'
require 'uri'

OUTPUT_FILENAME = 'engineering_blogs.opml'
TITLE = 'Engineering Blogs'

# grab name/url pairings from README.md
readme = File.open('README.md', 'r')
contents = readme.read
matches = contents.scan(/\* (.*) (http.*)/)
# All blogs that do not respond
unavailable = []
temp_ignores = [
  'AdRoll',
  'Buzzfeed',
  'Opendoor',
  'SourceClear',
  'TaskRabbit',
  'theScore',
  'Trivago',
  'Xmartlabs',
  'WyeWorks',
  'Zoosk',
  'Rudolf Olah'
]

Struct.new('Blog', :name, :web_url, :rss_url)
blogs = []

# for each blog URL, check if rss URL exists
matches.each_with_index do |match, index|
  name = match[0]
  web_url = match[1]

  if temp_ignores.include?(name)
      puts "#{name}: IGNORE [TEMPORARILY]"
      next
  end

  # if rss_url already in existing opml file, use that; otherwise, do a lookup
  rss_url = nil
  if File.exist?(OUTPUT_FILENAME)
    xml = Nokogiri::XML(File.open(OUTPUT_FILENAME))
    existing_blog = xml.xpath("//outline[@htmlUrl='#{web_url}']").first
    if existing_blog
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

    # use Feedbag as a backup to Google Feeds Api
    if rss_url.nil?
      rss_url = Feedbag.find(web_url).first
      if rss_url.nil?
        suggested_paths = ['/rss', '/feed', '/feeds', '/atom.xml', '/feed.xml', '/rss.xml', '.atom']
        suggested_paths.each do |suggested_path|
          rss_url = Feedbag.find("#{web_url.chomp('/')}#{suggested_path}").first
          break if rss_url
        end
      end
    end
  end

  if rss_url && rss_url.length > 0
    blogs.push(Struct::Blog.new(name, web_url, rss_url))
  else
    unavailable.push(Struct::Blog.new(name, web_url, rss_url))
  end

end

blogs.sort_by { |b| b.name.capitalize }
unavailable.sort_by { |b| b.name.capitalize }

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

puts "\nUnable to find an RSS feed for the following blogs:"
puts "==================================================="
unavailable.each do |b|
  puts "#{b.name} | #{b.web_url}"
end
puts "==================================================="
