module UserExtension
  extend ActiveSupport::Concern

  included do
    has_many :assigned_issues,
      class_name: 'Issue',
      foreign_key: :assigned_to_id,
      include: :priority
    has_many :progresstimes
  end

  def handlebars_issues(reload = false)
    default_subpriority = 1
    assigned_issues(reload)
      .joins(:status, :project)
      .where(issue_statuses: {is_closed: false}, project_id: Project.has_module(:handlebars))
      .where("projects.status != 9")
      .sort! do |a, b|
        [b.priority.position, b.subpriority || default_subpriority, b.id] <=> 
          [a.priority.position, a.subpriority || default_subpriority, a.id]
      end
  end

  def handlebars_user_ids
    instance_variable_get('@handlebars_user_ids') || begin
      ids = JSON.parse(Setting.plugin_handlebars[:users] || '').find do |key, value|
        key.to_i == id
      end.try(:second).try(:map, &:to_i) || []
      instance_variable_set('@handlebars_user_ids', ids)
      ids
    end
  end

  def started?
    progresstimes.where(closed: [false, nil]).any?
  end

  def handlebars_users
    User.active.where(id: handlebars_user_ids)
  end

  def handlebars?
    handlebars_user_ids.any?
  end

  def last_progress
    pr = progresstimes.where("start_time > :week", {:week => 1.week.ago})
    time = nil

    if pr.select{|p| p.end_time == nil}.count > 0
      pr = pr.order("start_time DESC").first
      if pr
        time = pr.start_time
      end
    else
      pr = pr.order("end_time DESC").first
      if pr
        time = pr.end_time
      end
    end
    return time

  end

end

User.send :include, UserExtension
