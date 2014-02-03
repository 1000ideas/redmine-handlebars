class HandlebarsController < ApplicationController
  unloadable

  def show
    hidden_ids = JSON.parse( (cookies['handlebars-hidden'] || '[]').gsub('|', ',') ) rescue []

    @hidden = User.where(id: hidden_ids)

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
