#!/usr/bin/env ruby
# encoding: utf-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
$stdout.set_encoding('UTF-8')

require 'cgi'
require 'nokogiri'

FAVORITES_FILE = 'favorites.txt'
XML_FILE = 'data0421.xml'
DEFAULT_XSLT_FILE = 'style.xsl'
DETAIL_XSLT_FILE = 'detail_style.xsl'

def get_favorites
  return [] unless File.exist?(FAVORITES_FILE)
  File.readlines(FAVORITES_FILE, chomp: true, encoding: 'UTF-8')
end

def save_favorites(favorites)
  File.open(FAVORITES_FILE, 'w', encoding: 'UTF-8') do |f|
    favorites.each { |fav| f.puts(fav) }
  end
end

def add_favorite(isbn)
  favorites = get_favorites
  favorites << isbn unless favorites.include?(isbn)
  save_favorites(favorites)
end

def remove_favorite(isbn)
  favorites = get_favorites
  favorites.delete(isbn)
  save_favorites(favorites)
end

def load_xml_utf8(path)
  File.open(path, encoding: 'UTF-8') { |f| Nokogiri::XML(f) }
end

def load_xslt_utf8(path)
  File.open(path, encoding: 'UTF-8') { |f| Nokogiri::XSLT(f) }
end

cgi = CGI.new("UTF-8")

keyword = cgi['keyword'].to_s.encode('UTF-8', invalid: :replace, undef: :replace)
mode    = cgi['mode'].to_s.encode('UTF-8', invalid: :replace, undef: :replace)
isbn    = cgi['isbn'].to_s.encode('UTF-8', invalid: :replace, undef: :replace)

if mode == 'add_favorite'
  add_favorite(isbn)
  print cgi.header({"Status" => "204 No Content", "type" => "text/plain; charset=UTF-8"})
  exit
elsif mode == 'remove_favorite'
  remove_favorite(isbn)
  print cgi.header({"Status" => "204 No Content", "type" => "text/plain; charset=UTF-8"})
  exit
end

xslt_file_path = case mode
                 when 'detail'
                   DETAIL_XSLT_FILE
                 else
                   DEFAULT_XSLT_FILE
                 end

begin
  xml_doc  = load_xml_utf8(XML_FILE)
  xslt_doc = load_xslt_utf8(xslt_file_path)
rescue Errno::ENOENT => e
  print cgi.header("type" => "text/html; charset=UTF-8")
  puts "<html><body><h1>Error</h1><p>Required file not found: #{e.message.encode('UTF-8', invalid: :replace, undef: :replace)}</p></body></html>"
  exit
end

output_doc = Nokogiri::XML::Document.new
output_doc.encoding = 'UTF-8'
selected_books_element = output_doc.create_element('selected-books', keyword: keyword, mode: mode)
output_doc.root = selected_books_element

favorites = get_favorites
selected_book_nodes = []

if mode == 'detail'
  book = xml_doc.at_xpath("//item[isbn=$isbn]", nil, { isbn: isbn })
  if book
    selected_book_nodes << book
  end

elsif mode == 'favorites'
  favorites.each do |fav_isbn|
    book = xml_doc.at_xpath("//item[isbn=$isbn]", nil, { isbn: fav_isbn })
    selected_book_nodes << book if book
  end

elsif mode == 'list_all'
  selected_book_nodes = xml_doc.xpath('//item').to_a.first(50)

else
  matched_books = []
  if !keyword.empty?
    matched_books = xml_doc.xpath(
      "//item[contains(title, $kw) or contains(creator, $kw) or contains(description, $kw)]",
      nil, { kw: keyword }
    )
  end
  matched_books = matched_books.to_a
  if matched_books.length < 4
    all_book_nodes = xml_doc.xpath('//item').to_a
    remaining_books = all_book_nodes - matched_books
    needed = 4 - matched_books.length
    matched_books.concat(remaining_books.sample(needed)) if needed > 0
  end
  selected_book_nodes = matched_books.sample(4).compact
end

selected_book_nodes.each do |book_node|
  next unless book_node
  new_node = book_node.dup(1)
  book_isbn = new_node.at_xpath('isbn')&.text.to_s.encode('UTF-8', invalid: :replace, undef: :replace)
  if book_isbn && favorites.include?(book_isbn)
    new_node['favorited'] = 'true'
  end
  selected_books_element.add_child(new_node)
end

params = Nokogiri::XSLT.quote_params({'keyword' => keyword, 'mode' => mode })
out = xslt_doc.transform(output_doc, params)

warn out.to_html(encoding: 'UTF-8')

print cgi.header("type" => "text/html; charset=UTF-8")
result_html = out.to_html(encoding: 'UTF-8')
result_html = result_html.encode('UTF-8', invalid: :replace, undef: :replace).force_encoding('UTF-8')
print result_html
