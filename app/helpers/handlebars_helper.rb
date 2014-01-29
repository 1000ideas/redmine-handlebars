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
    
    desc = strip_tags(issue.description)
    if desc.length > 300
      desc = desc.slice(0, 299).concat("&hellip;")
    end

    tooltip = content_tag(:div) do
      items = []
      items << content_tag(:strong, "##{issue.id} ") + issue.subject
      items << desc
      items << content_tag(:strong, "#{l(:field_author)}: ") + issue.author.name
      items << content_tag(:strong, "#{l(:field_estimated_hours)}: ") + "#{issue.estimated_hours}h"
      items << content_tag(:strong, "#{l(:label_spent_time)}: ") + "#{issue.spent_hours}h"
      items.join('<br />').html_safe
    end

    content_tag tag, class: class_name, data: {issue_id: issue.id, tooltip: tooltip.to_str} do
      content_tag(:span, "##{issue.id} #{issue.subject}")
    end
  end
end