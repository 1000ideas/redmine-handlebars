class HandlebarsController < ApplicationController
  unloadable

  before_filter :check_in_progress, only: [:show]

  def show
    hidden_ids = JSON.parse( (cookies['handlebars-hidden'] || '[]').gsub('|', ',') ) rescue []
    order_ids = JSON.parse( (cookies['handlebars-order'] || '[]').gsub('|', ',') ) rescue []

    @hidden = User.where(id: hidden_ids)
    @users = User.current.handlebars_users

    if order_ids.any?
      @users.sort_by! do |user|
        order_ids.index(user.id) || 0
      end
    end

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  private

  def check_in_progress
    user_issues = Issue.where(assigned_to_id: User.current.id)
    @any_in_progress = user_issues.any?(&:started?)
  end
end
