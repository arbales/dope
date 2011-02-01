require 'sinatra/base'       
require 'coffee-script'
require 'omniauth'
require 'padrino-helpers'   
require 'padrino-core/application/rendering'
require 'haml'               
require 'omniauth'
require './renderer' 
require './models' 

class Dope
  class Application < Sinatra::Base     
    enable :methodoverride 
    enable :sessions
    
    use OmniAuth::Builder do                                                   
      provider :facebook, '172085949497689', '3bd1ec690772a06761401762720cb9e1', scope: 'email,offline_access'
    end 
    
                          
    #load './models.rb'
    load './auth.rb'
    
    set :public,   File.expand_path(File.dirname(__FILE__) + '/public') #Include your public folder
    set :views,    File.expand_path(File.dirname(__FILE__) + '/views')  #Include the views
    
    helpers do       
      register Padrino::Helpers
      register Padrino::Rendering
    end

    configure :development do
      Dope::Application.reset!
      use Rack::Reloader
    end                 
    
    configure do
      file_name = File.join(File.dirname(__FILE__), ".", "config", "mongoid.yml")
      @mongoid_settings = YAML.load(ERB.new(File.new(file_name).read).result)

      Mongoid.configure do |config|
        config.from_hash(@mongoid_settings[ENV['RACK_ENV']])
      end
    end
                 
    get '/cafe/:name.js' do
      coffee("/coffee/#{params[:name]}".to_sym, no_wrap: true)
    end
  
    get '/' do               
      unless session[:username]
        redirect '/login'
      end
      
      @posts = Post.all
      render 'index'
    end
    
    post '/' do
      p = Post.new
      p.image = params[:file]
      p.username = session[:username]
      if p.save
        redirect "/post/#{p.id}"
      else
        "Failed to Save."
      end           
    end   
    
    delete '/comment/:id' do
      Comment.find(params[:id]).destroy
    end    
    
    delete '/post/:id' do
      Post.find(params[:id]).destroy
    end
    
    post '/post/:id/comments' do
      p = Post.find(params[:id])
      if p.comments.create(:body => params[:body], :username => session[:username]) 
        "True"
      else
        error "Failed to save comment."
      end
    end  
    
    get '/post/:id' do
      @post = Post.find(params[:id])
      haml :post
    end 
    
    put '/post/:id/yeps' do
      p = Post.find params[:id]
      num = p.yeps.to_i
      num += 1
      p.yeps = num
      p.save                   
      puts num
      num.to_s
    end    
    
    put '/post/:id/nopes' do
      p = Post.find params[:id]
      num = p.nopes.to_i
      num += 1
      p.nopes = num
      p.save                   
      puts num
      num.to_s
    end
    
    get '/login' do
      haml :login, :layout => 'layouts/alt'.to_sym
    end
    
    post '/login' do
      session[:username] = params[:email].split("@")[0]
      redirect '/'
    end
    
    
    get '/leave' do
      session.clear
      render :bye, :layout => 'layouts/alt'.to_sym
    end
  
  end
end