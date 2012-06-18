require 'time'

class TimeDimensionBuilder
  # Specify the start time for the first record
  attr_accessor :start_time
  
  # Specify the end time for the last record
  attr_accessor :end_time

  # Avoid generating bad data on daylight change. If you are on a daylight changing day (ie: 2009/03/29) you'll get this:
  # >> Time.parse('1:59')+60               
  # => Sun Mar 29 03:00:00 0200 2009       => 3:00 is just after 1:59
  # Instead, append a day that hasn't got daylight change (2009/03/01)
  # >> Time.parse('2009/03/01 1:59')+60
  # => Sun Mar 01 02:00:00 0100 2009       => 2:00 is just after 1:59
  DAY_WITHOUT_DAYLIGHT_CHANGE = "2009/03/01 "
    
  # Initialize the builder.
  # 
  # * <tt>start_time</tt>: The start time.
  # * <tt>end_time</tt>: The end time.
  def initialize(start_time, end_time)
    @start_time = start_time.class == String ? Time.parse(DAY_WITHOUT_DAYLIGHT_CHANGE + start_time) : start_time
    @end_time = end_time.class == String ? Time.parse(DAY_WITHOUT_DAYLIGHT_CHANGE + end_time) : end_time
  end

  # Returns an array of hashes representing records in the dimension. The values for each record are 
  # accessed by name.
  def build(options={})
    records = []
    time = start_time
    while time <= end_time
      record = {}
      record[:sql_time_stamp] = time.strftime('%H:%M')
      record[:hour] = time.hour

      hour_format = "%I:%M %P"
      
      # full hour description
      full_hour_start = time.to_a
      full_hour_start[1] = 0 # set minutes to 0
      full_hour_start = Time.local(*full_hour_start)
      record[:hour_description] = "between #{full_hour_start.strftime(hour_format)} and #{(full_hour_start+59*60).strftime(hour_format)}"
      
      # half hour computation
      half_hour_start = time.to_a
      half_hour_start[1] = 30*(half_hour_start[1] / 30) # round to 0 or 30 minutes
      half_hour_start = Time.local(*half_hour_start)
      half_hour_end = half_hour_start + 29*60 # grab the next half by adding 30 minutes
      half_hour_start = half_hour_start.strftime(hour_format)
      half_hour_end = half_hour_end.strftime(hour_format)
      record[:half_hour_description] = "between #{half_hour_start} and #{half_hour_end}"

      record[:hour_type] = case time.hour
        when 9..16; "opening hours"
        else "non opening hours"
      end

      record[:day_part] = case time.hour
        when 8..11; "morning"
        when 12..18; "afternoon"
        when 19..21; "evening"
        else "night"
      end
      
      records << record
      time = time + 60
    end
    records
  end

end
