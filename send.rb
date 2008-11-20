require 'rubygems'
require 'rest_client'
require 'sequel'
require 'json'

require '/Users/adam/rush/lib/rush'

dir = Rush.dir(__FILE__)
dir['local.db'].destroy
dir['full.db'].duplicate 'local.db'

dir['remote.db'].destroy
dir['empty.db'].duplicate 'remote.db'

DB = Sequel.connect('sqlite://local.db')

server = RestClient::Resource.new('http://localhost:4567')

uri = server['sessions'].post 'sqlite://remote.db'
session = server[uri]

chunk_size = 10

DB.tables.each do |table|
	count = DB[table].count
	puts "#{table} - #{count} records"

	page = 1
	while (page-1)*chunk_size < count
		data = DB[table].order(:id).paginate(page, chunk_size).all.to_json
		session[table].post data
		print "."
		page += 1
	end

	puts
end

session.delete

