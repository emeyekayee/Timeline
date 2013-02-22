class TimelabelDayNight < Timelabel
  self.label   = 'Day'
  self.format  = '<span class="ampmLeft" > %P </span>' +
                 '<span class="ampmCenter">&nbsp %a %B %e &nbsp&nbsp </span>' +
                 '<span class="ampmRight"> %P </span>'
  self.t_block = 12.hours

  def self.floor(t) t.change( :hour => (t.hour/12) * 12 ); end
end

