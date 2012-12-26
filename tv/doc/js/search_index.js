var search_data = {"index":{"searchIndex":["channel","program","resourceuseblock","schedresource","schedulecontroller","timeheader","timeheaderdaynight","timeheaderhour","timelabel","timelabeldaynight","timelabelhour","block_class_for_resource_name()","channel_by_num()","config_from_yaml()","css_classes_for_row()","decorate_resource()","decorate_resource()","endtime_with_local_tz()","find_as_schedule_resource()","find_as_schedule_resource()","floor()","floor()","get_all_blocks()","get_all_blocks()","get_all_blocks()","get_timeblocks()","groupupdate()","index()","kind()","new()","new()","new()","resource_list()","schedule()","set_visual_info()","show()","starttime_with_local_tz()","sub_id()","test()","to_css_class()","visible_time()","readme"],"longSearchIndex":["channel","program","resourceuseblock","schedresource","schedulecontroller","timeheader","timeheaderdaynight","timeheaderhour","timelabel","timelabeldaynight","timelabelhour","schedresource::block_class_for_resource_name()","channel::channel_by_num()","schedresource::config_from_yaml()","schedresource#css_classes_for_row()","channel#decorate_resource()","timeheader#decorate_resource()","program#endtime_with_local_tz()","channel::find_as_schedule_resource()","timeheader::find_as_schedule_resource()","timelabel::floor()","timelabeldaynight::floor()","program::get_all_blocks()","schedresource::get_all_blocks()","timelabel::get_all_blocks()","timelabel::get_timeblocks()","schedulecontroller#groupupdate()","schedulecontroller#index()","schedresource#kind()","resourceuseblock::new()","timeheader::new()","timelabel::new()","schedresource::resource_list()","schedulecontroller#schedule()","program#set_visual_info()","schedulecontroller#show()","program#starttime_with_local_tz()","schedresource#sub_id()","schedulecontroller#test()","program#to_css_class()","schedresource::visible_time()",""],"info":[["Channel","","Channel.html","","<p>channel.rb Copyright (c) 2008-2012 Mike Cannon\n(github.com/emeyekayee/Timeline) (michael.j.cannon@gmail ...\n"],["Program","","Program.html","","<p>program.rb Copyright (c) 2008-2012 Mike Cannon\n(github.com/emeyekayee/Timeline) (michael.j.cannon@gmail ...\n"],["ResourceUseBlock","","ResourceUseBlock.html","","\n<pre>ResourceUseBlock</pre>\n<p>Represents the USE of a resource for an interval of time.\n\n<pre>Resource X UseModel X [startime..endtime]; ...</pre>\n"],["SchedResource","","SchedResource.html","","<p>A \"schedule resource\" is something that can be used for one thing at a\ntime.\n<p>Example: A Room ...\n"],["ScheduleController","","ScheduleController.html","",""],["Timeheader","","Timeheader.html","",""],["TimeheaderDayNight","","TimeheaderDayNight.html","",""],["TimeheaderHour","","TimeheaderHour.html","",""],["Timelabel","","Timelabel.html","",""],["TimelabelDayNight","","TimelabelDayNight.html","",""],["TimelabelHour","","TimelabelHour.html","",""],["block_class_for_resource_name","SchedResource","SchedResource.html#method-c-block_class_for_resource_name","( name )",""],["channel_by_num","Channel","Channel.html#method-c-channel_by_num","()","<p>Convenience\n"],["config_from_yaml","SchedResource","SchedResource.html#method-c-config_from_yaml","( session )","<p>Process configuration file.\n"],["css_classes_for_row","SchedResource","SchedResource.html#method-i-css_classes_for_row","()",""],["decorate_resource","Channel","Channel.html#method-i-decorate_resource","( rsrc )",""],["decorate_resource","Timeheader","Timeheader.html#method-i-decorate_resource","( rsrc )",""],["endtime_with_local_tz","Program","Program.html#method-i-endtime_with_local_tz","()",""],["find_as_schedule_resource","Channel","Channel.html#method-c-find_as_schedule_resource","(rid)","<p>Return Channel object from channum (String)\n"],["find_as_schedule_resource","Timeheader","Timeheader.html#method-c-find_as_schedule_resource","( rid )","<p>For SchedResource Return Timeheader* object from resource id (string)\n"],["floor","Timelabel","Timelabel.html#method-c-floor","(t)",""],["floor","TimelabelDayNight","TimelabelDayNight.html#method-c-floor","(t)",""],["get_all_blocks","Program","Program.html#method-c-get_all_blocks","( rids, t1, t2, inc )","<p>Returns a hash where each key is a <code>SchedResource</code> object\ncorresponding to a resource id and the value ...\n"],["get_all_blocks","SchedResource","SchedResource.html#method-c-get_all_blocks","(t1, t2, inc)",""],["get_all_blocks","Timelabel","Timelabel.html#method-c-get_all_blocks","(ids, t1, t2, inc)","<p>ScheduledResource protocol...\n"],["get_timeblocks","Timelabel","Timelabel.html#method-c-get_timeblocks","(id, t1, t2, inc)",""],["groupupdate","ScheduleController","ScheduleController.html#method-i-groupupdate","()",""],["index","ScheduleController","ScheduleController.html#method-i-index","()",""],["kind","SchedResource","SchedResource.html#method-i-kind","()",""],["new","ResourceUseBlock","ResourceUseBlock.html#method-c-new","(rsrc, blk)",""],["new","Timeheader","Timeheader.html#method-c-new","( rid )",""],["new","Timelabel","Timelabel.html#method-c-new","( t )",""],["resource_list","SchedResource","SchedResource.html#method-c-resource_list","()",""],["schedule","ScheduleController","ScheduleController.html#method-i-schedule","()",""],["set_visual_info","Program","Program.html#method-i-set_visual_info","()","<p>Figure css classes for program block display using...\n\n<pre>- prog.category_type (eg, &quot;series&quot;, ...)\n- prog.category ...</pre>\n"],["show","ScheduleController","ScheduleController.html#method-i-show","()",""],["starttime_with_local_tz","Program","Program.html#method-i-starttime_with_local_tz","()",""],["sub_id","SchedResource","SchedResource.html#method-i-sub_id","()",""],["test","ScheduleController","ScheduleController.html#method-i-test","()",""],["to_css_class","Program","Program.html#method-i-to_css_class","( cat )",""],["visible_time","SchedResource","SchedResource.html#method-c-visible_time","()",""],["README","","README.html","","<p>Timeline is a schedule widget, built on Rails, that uses Javascript, jQuery\nand AJAX to show how resources ...\n"]]}}