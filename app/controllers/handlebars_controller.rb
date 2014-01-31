class HandlebarsController < ApplicationController
  unloadable

  def show
    Rails.logger.debug cookies['handlebars-hidden'].inspect
    @hidden = JSON.parse( (cookies['handlebars-hidden'] || '[]').gsub('|', ',') )
    Rails.logger.debug @hidden

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
