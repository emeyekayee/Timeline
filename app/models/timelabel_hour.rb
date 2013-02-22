class TimelabelHour < Timelabel
  self.label   = 'Hour'
  self.format  = '%I:%M'
  self.t_block = 15.minutes
end

