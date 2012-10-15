require "open-uri"
require "nokogiri"
class PagesController < ApplicationController
  def home
    if params[:q]
      @query = params[:q]
      @answer = search @query
    end
  end

  def about
  end

  private
    def search query
      "answer"
      html = search_engine query
      text = html2text html
      names = name_filter html
      name = who_optimizer query, names
      name
    end

    def search_engine query
      enc_uri = URI.escape "http://www.baidu.com/s?wd=#{query}"
      uri = URI.parse enc_uri
      uri.read
    end

    def html2text html
      doc = Nokogiri::HTML.parse html
      doc.css('script, link').each { |node| node.remove }
      doc.css('body').text.squeeze(" ").squeeze("\n")
    end

    def name_filter text
      File.open('text', 'w') {|f| f.write(text)}
      names_str = `name-selector/selector.sh < name-selector/text`
      puts names_str
      names = names_str.split
      count = {}
      names.each do |name|
        if count[name]
          count[name] += 1
        else
          count[name] = 1
        end
      end
      sorted = count.sort_by { |name, number| number }
      sorted_names = []
      sorted.each do |pair|
        sorted_names.push pair[0]
      end
      sorted_names.reverse
    end

    def who_optimizer query, names
      names.each do |name|
        if not query.include? name
          return name
        end
      end
      "not found"
    end
end
