module HandlebarsHelper
  def issue_handlebar(issue, user_id, tag = :div)
    maximum = false

    # issue.spent_time requires table_it plugin
    spent_time = issue.try(&:spent_time) || issue.spent_hours.round(2)

    timespan = (issue.estimated_hours || 0) - spent_time
    # if issue.respond_to?(:progresstimes)
    #   start = issue.progresstimes.started.last.try(:start_time)
    #   if start
    #     timespan -= (Time.now - start) / 3600.0
    #   end
    # end
    # height = timespan > 0 ? (4*timespan).ceil : 1
    # height set to 1 due to layout issues with estimated time
    height = 1
    overtime = timespan < 0 && issue.estimated_hours.present?
    percentage_progress = overtime ? '11' : issue.estimated_hours.present? &&
      ((issue.estimated_hours - timespan) * 10 /
      issue.estimated_hours).round

    # if height > 16*4
    #   maximum = true
    #   height = 16*4
    # end

    class_name = [
      :hascontextmenu,
      :handlebar,
      :"height-#{height}",
      :"progress-#{percentage_progress}",
      :"priority-position-#{issue.priority.position}"
    ]
    class_name << :maximum if maximum
    class_name << :feedback if issue.status_id == Setting.plugin_handlebars['feedback'].to_i

    desc = strip_tags(issue.description)
    desc = desc.slice(0, 299).concat('&hellip;') if desc.length > 300

    tooltip = content_tag(:div) do
      items = []
      items << content_tag(:strong, "##{issue.id} ") + issue.subject
      items << desc
      items << content_tag(:strong, "#{l(:field_author)}: ") + issue.author.name
      items << content_tag(:strong, "#{l(:field_project)}: ") + issue.project.name
      items << content_tag(:strong, "#{l(:field_priority)}: ") + issue.priority.name + "(#{issue.subpriority})"
      items << content_tag(:strong, "#{l(:field_estimated_hours)}: ") + "#{issue.estimated_hours}h" if issue.estimated_hours.present?
      items << content_tag(:strong, "#{l(:label_spent_time)}: ") + "#{spent_time}h"
      items.join('<br />').html_safe
    end

    content_tag tag, class: class_name, data: { issue_id: issue.id, tooltip: tooltip.to_str } do
      items = [link_to("##{issue.id} [#{issue.project.name}] #{issue.subject}", issue, target: '_blank')]
      items << content_tag(:span, class: :status) do
        path = switch_time_issue_path(issue)
        data = { remote: true, method: :post }
        subitems = []
        subitems << link_to(content_tag(:i, '', class: :stop, title: l(:label_stopped)), path, data: data, class: [:'start-time', :'handlebars-status-icon']) unless issue.started_by_user?(user_id)
        subitems << link_to(content_tag(:i, '', class: :play, title: l(:label_working_on)), path, data: data, class: [:'stop-time', :'handlebars-status-icon']) if issue.respond_to?(:started_by_user?) && issue.started_by_user?(user_id)
        subitems << content_tag(:i, '!', class: :'overtime', title: l(:label_overtime)) if overtime
        subitems.join.html_safe
      end

      items << content_tag(:span, '', class: "progress done-#{issue.done_ratio}")
      items << content_tag(:span, "#{timespan}h", class: 'more-than-max') if maximum
      items << content_tag(:span, "E", class: 'extra-access') if issue.assigned_to_id != user_id

      items.join.html_safe
    end
  end

  def with_feedback(issues, feedback = true)
    @feedback_id ||= Setting.plugin_handlebars['feedback'].to_i
    return issues.find_all { |issue| issue.status_id == @feedback_id } if feedback
    issues.find_all { |issue| issue.status_id != @feedback_id }
  end
end
