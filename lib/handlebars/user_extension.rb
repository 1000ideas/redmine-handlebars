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
    closed = IssueStatus.find { |status| status.is_closed == true }.id
    assigned_issues(reload)
      .where("status_id != #{closed}",
             project_id: Project.has_module(:handlebars))
      .includes(:author, :project)
      .where('projects.status != 9')
      .sort! do |a, b|
        [b.priority.position, b.subpriority || default_subpriority, b.id] <=>
          [a.priority.position, a.subpriority || default_subpriority, a.id]
      end
  end

  def handlebars_user_ids
    instance_variable_get('@handlebars_user_ids') || begin
      ids = JSON.parse(Setting.plugin_handlebars[:users] || '')
                .find do |key, _value|
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
    pr = progresstimes.last
    return nil if pr.nil?
    time = nil
    
    if pr.end_time
      time = pr.end_time
    else
      time = pr.start_time
    end
    
    time
  end
end

User.send :include, UserExtension
