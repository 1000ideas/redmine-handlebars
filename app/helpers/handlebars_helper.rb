module HandlebarsHelper

  def issue_handlebar(issue, tag = :div)
    maximum = false
    height = (4*((issue.estimated_hours || 0) - issue.spent_hours)).to_i
    Rails.logger.debug height
    height = 1 unless height > 0
    
    if height > 16*4
      maximum = true
      height = 16*4
    end
    
    class_name = [:hascontextmenu, :handlebar, :"height-#{height}"]
    class_name << :maximum if maximum

    content_tag tag, class: class_name, data: {issue_id: issue.id} do
      content_tag(:span, "##{issue.id} #{issue.subject}")
    end
  end
end