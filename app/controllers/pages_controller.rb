class PagesController < ApplicationController

  # GET /about
  # Via: about_path
  # Avaiable: all
  #
  # Shows the 'about' page.
  def about
    @current_tab = 'about'
    @page_title = "Sobre"
  end

  # GET /contact
  # Via: contact_path
  # Avaiable: all
  #
  # Shows the 'contact' page.
  def contact
    @current_tab = 'contact'
    @page_title = "Contato"
  end
  
end
