require 'bundler'

Bundler.setup

require 'sequel'
require 'sinatra/base'

url = "postgres://"
url += ENV['OPENSHIFT_POSTGRESQL_DB_USERNAME'] + ":"
url += ENV['OPENSHIFT_POSTGRESQL_DB_PASSWORD'] + "@"
url += ENV['OPENSHIFT_POSTGRESQL_DB_HOST'] + ":"
url += ENV['OPENSHIFT_POSTGRESQL_DB_PORT'] + "/"
url += ENV['OPENSHIFT_APP_NAME']

DB = Sequel.connect(url)

class Application < Sinatra::Base

  helpers do
    def word(table)
      DB["select string from #{table} offset random()* (select count(*) from #{table}) limit 1;"].first[:string]
    end
    def insult(name=nil)
      (name ? "#{name}, thou " : "") + "#{word(:short_adjective)} #{word(:long_adjective)} #{word(:noun)}!"
    end
  end
  get "/" do
    insult
  end

  get "/:name" do
    insult(params[:name])
  end

end

run Application
