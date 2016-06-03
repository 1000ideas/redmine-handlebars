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
    statuses, projects = rejected_values
    statuses.compact!
    projects.compact!

    issues = assigned_issues(reload)
             .where(project_id: Project.has_module(:handlebars))
             .includes(:author, :project)
             .where('projects.status != 9')

    issues = issues.where('status_id NOT IN (?)', statuses) unless statuses.empty?
    issues = issues.where('projects.id NOT IN (?)', projects) unless projects.empty?

    issues.sort! do |a, b|
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

    return pr.end_time if pr.end_time
    return pr.start_time if pr.start_time

    nil
  end

  def rejected_values
    closed = IssueStatus.find { |status| status.is_closed == true }.try(:id)
    rejected = IssueStatus.find { |status| status.name =~ /Rejected/i }.try(:id)
    works_for_me = IssueStatus.find { |status| status.name =~ /Works for me/i }.try(:id)
    projekty = Project.find { |project| project.name =~ /^_projekty$/i }.try(:id)
    the_company = Project.find { |project| project.name =~ /^the_company$/i }.try(:id)
    qualified_deals = Project.find { |project| project.name =~ /^qualified deals$/i }.try(:id)
    [[closed, rejected, works_for_me], [projekty, the_company, qualified_deals]]
  end
end

User.send :include, UserExtension
