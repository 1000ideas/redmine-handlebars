class AddSubpriorityToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :subpriority, :integer, default: 1
  end
end
