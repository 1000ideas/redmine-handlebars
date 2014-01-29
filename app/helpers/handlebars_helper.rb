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
    content_tag tag, class: [:hascontextmenu, :handlebar, :"height-#{height}", (:maximum if maximum)] do
      content_tag(:span, "##{issue.id} #{issue.subject}")
    end
  end
end