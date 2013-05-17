module RemoteServersHelper

  def cron_minute_fields

      @field_name = 'minute'
      @field_value = 'minute'
      @select_list = {
          '--'=> '-- '+_('Common settings')+' --',
          '*' => _('Every minute (*)'),
          '*/5' => _('Every 5 minute')+'( */5)',
          '*/2' => _('Every other minute')+'(*/2)',
          '0,30'=> _('Every 30 minutes')+ '(0,30)',
      }

      (0..59).each do |i|
        @select_list[i.to_s] = i.to_s
      end

    render :partial => 'cron_field'

  end

  def cron_hour_fields
      @field_name = 'hour'
      @field_value = 'hour'
      @select_list = {
          '--'=> '-- '+_('Common settings')+' --',
          '*' => _('Every hour (*)'),
          '*/2' => _('Every other hour (*/2)'),
          '0,12' => _('Every 12 hours (0,12)'),

      }

      (0..23).each do |i|
        @select_list[i.to_s] = i.to_s
      end

    render :partial => 'cron_field'

  end

  def cron_day_fields

      @field_name = 'day'
      @field_value = 'day'
      @select_list = {
          '--'=> '-- '+_('Common settings')+' --',
          '*' => _('Every day (*)'),
          '*/2' => _('Every other day (*/2)'),
          '1-14' => _('First half (1-14)'),
          '15-31' => _('Second half (15-31)')

      }

      (1..31).each do |i|
        @select_list[i.to_s] = i.to_s
      end

    render :partial => 'cron_field'
  end

  def cron_month_fields

      @field_name = 'month'
      @field_value = 'month'
      @select_list = {
          '--'=> '-- '+_('Common settings')+' --',
          '*' => _('Every month (*)'),
          '*/2' => _('Every other month (*/2)'),
          '*/4' => _('Every 3 months (*/4)'),
          '1/7' => _('Every 6 months (1/7)'),
          '1' => _('January (1)'),
          '2' => _('February (2)'),
          '3' => _('March (3)'),
          '4' => _('April (4)'),
          '5' => _('May (5)'),
          '6' => _('June (6)'),
          '7' => _('July (7)'),
          '8' => _('August (8)'),
          '9' => _('September (9)'),
          '10' => _('October (10)'),
          '11' => _('November (11)'),
          '12' => _('December (12)'),

      }

    render :partial => 'cron_field'
  end

  def cron_weekday_fields

      @field_name = 'weekday'
      @field_value = 'weekday'
      @select_list = {
          '--'=> '-- '+_('Common settings')+' --',
          '*' => _('Every weekday (*)'),
          '*/2' => _('Every other weekday (*/2)'),
          '1' => _('Monday (1)'),
          '2' => _('Tuesday (2)'),
          '3' => _('Wednesday (3)'),
          '4' => _('Thursday (4)'),
          '5' => _('Friday (5)'),
          '6' => _('Saturday (6)'),
          '0' => _('Sunday (0)'),
          '1-5' => _('On weekdays (1-5)'),
          '6-7' => _('On weekends (6-0)')
      }

    render :partial => 'cron_field'
  end
  
  def cron_fields

    @field_list = {
      'minute' => _('Minute'),
      'hour' => _('Hour'),
      'day' => _('Day'),
      'month' => _('Month'),
      'weekday' => _('Weekday')
    }

    @common_settings = {
      '-- '+_('Common settings')+' --' => '--',
      _('Every minute')+' (*****)' => {
                                  'minute' => '*',
                                  'hour' => '*',
                                  'day' => '*',
                                  'month' => '*',
                                  'weekday' => '*'
                                },
      _('Every 5 minutes')+' (*/5****)' => {
                                  'minute' => '*/5',
                                  'hour' => '*',
                                  'day' => '*',
                                  'month' => '*',
                                  'weekday' => '*'
                                },
      _('Twice an hour')+' (0,30****)' => {
                                  'minute' => '0,30',
                                  'hour' => '*',
                                  'day' => '*',
                                  'month' => '*',
                                  'weekday' => '*'
                                },
      _('Twice an day')+' (0 0,12***)' => {
                                  'minute' => '0',
                                  'hour' => '0,12',
                                  'day' => '*',
                                  'month' => '*',
                                  'weekday' => '*'
                                }
    }

    @common_settings_for_select = Hash.new

    @common_settings.each do |k,v|
      if v.kind_of?(Hash)
        @common_settings_for_select[k] = v.map{|k,v| "#{k};#{v}"}.join('|')
      else
        @common_settings_for_select[k] = v
      end
      #raise 'commom_settings_for_select'+@common_settings_for_select.to_s
    end

    render :partial => 'cron_fields_list'

  end

end
