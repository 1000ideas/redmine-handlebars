module IssueHandlebarsExtension
  extend ActiveSupport::Concern

  included do
    validates :subpriority, inclusion: { in: 1..10 }
    safe_attributes 'subpriority',
      :if => lambda {|issue, user| issue.new_record? || user.allowed_to?(:edit_issues, issue.project) }
  end

end

Issue.send :include, IssueHandlebarsExtension