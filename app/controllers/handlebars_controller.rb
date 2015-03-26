class HandlebarsController < ApplicationController
  unloadable

  def show
    hidden_ids = JSON.parse( (cookies['handlebars-hidden'] || '[]').gsub('|', ',') ) rescue []
    order_ids = JSON.parse( (cookies['handlebars-order'] || '[]').gsub('|', ',') ) rescue []

    @hidden = User.where(id: hidden_ids)
    @users = User.current.handlebars_users

    if order_ids.any? and @users.present?
      @users.sort_by! do |user|
        order_ids.index(user.id)
      end
    end

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end
end
