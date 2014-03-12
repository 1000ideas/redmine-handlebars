module IssuePriorityExtension
  extend ActiveSupport::Concern

  module Helper
    def self.hsv2rgb(h,s,v)
      h = h.to_f
      s = s.to_f
      v = v.to_f

      rgb = if v == 0
        [0.0, 0.0, 0.0]
      else
        h = h/60
        i = h.floor
        f = h-i
        p = v*(1-s)
        q = v*(1-(s*f))
        t = v*(1-(s*(1-f)))
        if i == 0
          [v, t, p]
        elsif i == 1
          [q, v, p]
        elsif i == 2
          [p, v, t]
        elsif i == 3
          [p, q, v]
        elsif i == 4
          [t, p, v]
        else
          [v, p, q]
        end
      end
      rgb.map { |c| (c*255).to_i }
    end
  end

  module ClassMethods
    def colors
      positions = self.all.map(&:position)
      count = positions.length.to_f
      positions.map do |p|
        # exp = (10**(2 - (p-1)/count))/100.0
        val = ((p-1)*100.0)/(count - 1).to_f
        hue = ((100 - val) * 178.0 / 100.0).floor
        value = 0.8 + (val - 100)*0.2/100
        "#%02x%02x%02x" % Helper.hsv2rgb(hue, 1, value)
      end
    end
  end

  private

end

IssuePriority.send :include, IssuePriorityExtension
