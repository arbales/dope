use Rack::Session::Cookie

before do
  @_flash, session[:_flash] = session[:_flash], nil if session[:_flash]
end  

get '/auth/facebook/callback' do
    auth = request.env['omniauth.auth']
    # do whatever you want with the information!
    person = Person.where("#{params[:name]}_uid".to_sym => auth['uid'])[0]     

    if auth['user_info']['nickname'].start_with? "profile.php"
      abmessage_with_redirect :error, "Sorry, you aren&rsquo;t eligble to participate in this preview.", '/'
    end
      
    unless person
      person = Person.create(:username => auth['user_info']['nickname'],
                             :key => BCrypt::Engine.generate_salt,
                             "#{params[:name]}_uid".to_sym => auth['uid'],
                             :fb_image => session[:u_image])
    end
   
    session[:u_full_name] = auth['user_info']['name']
    session[:u_image] = (params[:name] == "facebook") ? ("https://graph.facebook.com/"+ auth['user_info']['nickname'] + "/picture") : (auth['user_info']['image'])
    session[:token] = Digest::SHA1.hexdigest(person.key + "salt" + person.username)
    session[:username] = person.username
    session[:userid] = person.id                       
    redirect "/"   
      
                         
end 
 
get '/logout' do
  session.clear
  redirect "/"
end

def rack_protected!
  response['WWW-Authenticate'] = %(Basic realm="Rambler") and \
  throw(:halt, [401, "Not authorized\n"]) and \
  return unless rack_authorized?
end

def rack_authorized?
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV['RAMBLER_USER'], ENV['RAMBLER_PASSWORD']]
end

def protected!
  requires_session_with_redirect!
end