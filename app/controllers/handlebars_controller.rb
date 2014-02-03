class HandlebarsController < ApplicationController
  unloadable

  def show
    @hidden = JSON.parse( (cookies['handlebars-hidden'] || '[]').gsub('|', ',') )

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
