class DropController < ApplicationController
  
  # This references the Dropbox SDK gem install with "gem install dropbox-sdk"
	require 'dropbox_sdk'
  
  APP_KEY = 'o1xfbfp7xpih038'
	APP_SECRET = '8tmmv20y681jnie'
	ACCESS_TYPE = :app_folder  #The two valid values here are :app_folder and :dropbox
	
=begin
		@client = DropboxClient.new(@@session, ACCESS_TYPE)
		puts "linked account:", @client.account_info().inspect
  end
=end
	
	# GET drop/authorize
	def authorize
    if not params[:oauth_token] then
      dbsession = DropboxSession.new(APP_KEY, APP_SECRET)

      session[:dropbox_session] = dbsession.serialize #serialize and save this DropboxSession

      #pass to get_authorize_url a callback url that will return the user here
      redirect_to dbsession.get_authorize_url url_for(:action => 'authorize')
    else
      # the user has returned from Dropbox
      dbsession = DropboxSession.deserialize(session[:dropbox_session])
      # This will fail if the user didn't visit the above URL and hit 'Allow'
      dbsession.get_access_token  #we've been authorized, so now request an access_token
      session[:dropbox_session] = dbsession.serialize
      
      redirect_to drop_all_files_path
		end
	end
	
	def unauthorize
	  
	  if session[:dropbox_session] then
	    
	    dbsession = DropboxSession.deserialize(session[:dropbox_session])
	    
	    #clear access token
	    dbsession.clear_access_token
	    
	    #clear session info
	    #session[:dropbox_session] = nil
	    session = nil
	  end
	  
	  redirect_to drop_all_files_path
	  
	end
  
  # GET drop/new
	def new_upload
    

	end
	
	# POST drop/upload
	def upload
	  
	  # Check if user has no dropbox session...re-direct them to authorize
    return redirect_to(:action => 'authorize') unless session[:dropbox_session]

    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
    
		# upload the posted file to dropbox keeping the same name
    @resp = client.put_file(params[:file].original_filename, params[:file].read)
    
	end
	
	# GET all_files
	def all_files
	  
	  # Check if user has no dropbox session...re-direct them to authorize
    return redirect_to(:action => 'authorize') unless session[:dropbox_session]

    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
    
    @parsed_file_metadata = client.metadata('/')
    
    
	end
	
	# GET drop/new_download
	def new_download
	  
	  # Check if user has no dropbox session...re-direct them to authorize
    return redirect_to(:action => 'authorize') unless session[:dropbox_session]

    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
    
    @parsed_file_metadata = client.metadata('/')
	  
	end
	
	# GET drop/download
	def download
	  
	  file_name = params[:file_name][1...params[:file_name].length]
	  
	  dbsession = DropboxSession.deserialize(session[:dropbox_session])
	  client = DropboxClient.new(dbsession, ACCESS_TYPE)
	  
	  out, metadata = client.get_file_and_metadata(file_name)
    open(file_name, 'w') {|f| f.puts out }
    
    @out = out
    @metadata = metadata
    
	end
	
	def parser
	  
	  
	  
	end

end
