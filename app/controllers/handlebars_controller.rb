class HandlebarsController < ApplicationController
  unloadable

  def show

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
