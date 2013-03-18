
#                       ResourceUseBlock
#
# Represents the USE of a resource for an interval of time.
#
#  Resource X UseModel X [startime..endtime];
#   |         | Example -- tv:
#   |         |   Program   [ belongs_to :channel    ]
#   |         |   Timelabel [ belongs_to :timeheader ]
#   |
#   | Example -- tv: Channel, HeaderSlot
#
class ResourceUseBlock

  delegate  :kind,      :to => :@rsrc

  delegate  :starttime=, :endtime=,  
            :starttime,  :endtime,  :css_classes,     :block_label,
            :title,      :subtitle, :description,     :stars,
            :airdate,    :category, :previouslyshown,
      :to => :@blk

  def initialize(rsrc, blk)
    @rsrc = rsrc
    @blk = blk
  end

end
