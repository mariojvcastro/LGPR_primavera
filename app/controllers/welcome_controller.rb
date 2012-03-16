class WelcomeController < ApplicationController
  
  def index
    
    if session[:dropbox_session] then
      redirect_to drop_all_files_path
    end
    
  end

end
