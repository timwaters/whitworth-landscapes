require 'rubygems'
require 'vendor/sinatra-1.3.1/lib/sinatra.rb'
require 'vendor/rack-1.3.5/lib/rack.rb'

require 'activerecord'
require 'placemaker'

ActiveRecord::Base.establish_connection(
  :adapter => "mysql", :host => "host.examples.com",
  :database => "dbname", :username => "user",:password => "pass")

class Paintings < ActiveRecord::Base
  set_primary_key 'ecatalogue_key'
end

YAPI  = "YOUR YAHOO API KEY"

require 'flickraw'

FlickRaw.api_key="YOUR FLICKR API KEY"
FlickRaw.shared_secret="FLICKR SHARED SECRET"

get '/pics/:lat/:lon' do
  photos = flickr.photos.search(:tags =>'landscape', :lat => params[:lat], :lon => params[:lon], :radius => 10, :per_page => 3, :sort => 'interestingness-asc' )
  photos.inspect
  phtml = "<h2>Whitworth Art Gallery UK Landscape Paintings. Flickr Photos around "+ params[:lat]+", "+params[:lon]+"</h2>"
  photos.each do | photo |
    info = flickr.photos.getInfo(:photo_id => photo.id)

    phtml = phtml + "<img src = '"+FlickRaw.url_z(info) + "' class='my_img'/> <br /> "
  end
  phtml
end

get '/xml' do
  ps  =  Paintings.all
  ps.to_xml
  #first.TitMainTitle
end

get '/' do

  @paintings = Paintings.all
  erb :map
end

get '/images' do
  imgs = Dir['**/*.{jpg,png,gif}']
  ii = []
  imgs.each do | i |
    ii << File.basename(i)
  end

  ps = Paintings.all
  ps.each do | painting |
    ii.each do | i |
      if i.include? painting.TitAccessionNo.to_s.gsub('.','_')
        painting.imagefilename = i
        painting.save
        break
      end #if
    end #ii
  end  #painting
  "woot"
end

get '/parse' do
  lines = ""
  ps = Paintings.all
  ps.each do | painting |

    p = Placemaker::Client.new(:appid => YAPI, :document_content => painting.TitMainTitle.to_s, :focus_woe_id => '43201', :document_type => 'text/plain')
    p.fetch!

    names  = []
    p.documents.each do | d |
      names << d.geographic_scope
    end
    if names[0] && names[0].centroid
      #lines = lines + names[0].name.to_s + " "+names[0].centroid.lat.to_s + ", "+ names[0].centroid.lng + " <br /> "
      lines  = lines + names[0].centroid.lat.to_s + " : " + names[0].centroid.lng.to_s  + "<br />"
      painting.lon = names[0].centroid.lng.to_s.to_f
      painting.lat = names[0].centroid.lat.to_s.to_f
      painting.save
    end #names
  end #paintings
  lines
end #get
