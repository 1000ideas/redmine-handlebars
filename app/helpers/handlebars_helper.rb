module HandlebarsHelper

  def issue_handlebar(issue, tag = :div)
    maximum = false

    timespan = (issue.estimated_hours || 0) - issue.spent_hours
    if issue.respond_to?(:progresstimes)
      start = issue.progresstimes.started.last.try(:start_time)
      if start
        timespan -= (Time.now - start) / 3600.0
      end
    end
    height = timespan > 0 ? (4*timespan).ceil : 1
    overtime = timespan < 0 && issue.estimated_hours.present?

    if height > 16*4
      maximum = true
      height = 16*4
    end

    class_name = [
      :hascontextmenu,
      :handlebar,
      :"height-#{height}",
      :"priority-position-#{issue.priority.position}"
    ]
    class_name << :maximum if maximum
    class_name << :feedback if issue.status_id == Setting.plugin_handlebars['feedback'].to_i


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
      items << content_tag(:strong, "#{l(:field_priority)}: ") + issue.priority.name
      items << content_tag(:strong, "#{l(:field_estimated_hours)}: ") + "#{issue.estimated_hours}h" if issue.estimated_hours.present?
      items << content_tag(:strong, "#{l(:label_spent_time)}: ") + "#{issue.spent_hours.round(2)}h"
      items.join('<br />').html_safe
    end

    content_tag tag, class: class_name, data: {issue_id: issue.id, tooltip: tooltip.to_str} do
      items = [link_to("##{issue.id} [#{issue.project.name}] #{issue.subject}", issue, target: '_blank')]
      items << content_tag(:span, class: :status) do
        subitems = []
        subitems << content_tag(:i, '', class: :play, title: l(:label_working_on)) if issue.respond_to?(:started?) and issue.started?
        subitems << content_tag(:i, '!', class: :'overtime', title: l(:label_overtime)) if overtime
        subitems.join.html_safe
      end

      items << content_tag(:span, '', class: "progress done-#{issue.done_ratio}")
      items << content_tag(:span, "#{timespan}h", class: "more-than-max") if maximum

      items.join.html_safe
    end
  end
end
