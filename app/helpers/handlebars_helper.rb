module HandlebarsHelper

  def issue_handlebar(issue, tag = :div)
    maximum = false

    timespan = (issue.estimated_hours || 0) - issue.spent_hours
    height = timespan > 0 ? (4*timespan).to_i : 1
    
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
      items << content_tag(:strong, "#{l(:field_project)}: ") + issue.project.name
      items << content_tag(:strong, "#{l(:field_estimated_hours)}: ") + "#{issue.estimated_hours}h"
      items << content_tag(:strong, "#{l(:label_spent_time)}: ") + "#{issue.spent_hours}h"
      items.join('<br />').html_safe
    end

    content_tag tag, class: class_name, data: {issue_id: issue.id, tooltip: tooltip.to_str} do
      items = [link_to("##{issue.id} #{issue.subject}", issue, target: '_blank')]
      items << content_tag(:span, class: :status) do
        subitems = []
        subitems << content_tag(:i, '', class: :play, title: l(:label_working_on)) if issue.respond_to?(:started?) and issue.started?
        subitems << content_tag(:i, '!', class: :'overtime', title: l(:label_overtime)) if timespan < 0
        subitems.join.html_safe
      end
      
      items << content_tag(:span, '', class: "progress done-#{issue.done_ratio}")
      items << content_tag(:span, "#{timespan}h", class: "more-than-max") if maximum
      
      items.join.html_safe
    end
  end
end