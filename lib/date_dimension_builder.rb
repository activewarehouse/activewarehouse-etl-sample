class DateDimensionBuilder
  # Specify the start date for the first record
  attr_accessor :start_date
  
  # Specify the end date for the last record
  attr_accessor :end_date
  
  # Initialize the builder.
  # 
  # * <tt>start_date</tt>: The start date.
  # * <tt>end_date</tt>: The end date.
  def initialize(start_date, end_date)
    @start_date = start_date.class == String ? Date.parse(start_date) : start_date
    @end_date = end_date.class == String ? Date.parse(end_date) : end_date
  end
  
  # Returns an array of hashes representing records in the dimension. The values for each record are 
  # accessed by name.
  def build
    records = []
    date = start_date
    while date <= end_date
      record = {}
      record[:date] = date.strftime("%Y-%m-%d")
      record[:month] = Date::MONTHNAMES[date.month].downcase
      record[:day_of_week] = Date::DAYNAMES[date.wday].downcase
      record[:day_of_week_as_number] = date.wday
      record[:year] = date.year.to_s
      record[:year_and_month] = record[:year] + "-" + date.month.to_s.rjust(2,'0')
      record[:sql_date_stamp] = date
      record[:week] = "week #{date.to_date.cweek}"
      # compute quarter ourselves - available in Time but not in Date - anything better ?
      quarter = 1 + (date.month-1) / 3
      record[:quarter] = "Q#{quarter}"
      record[:semester] = "S#{(quarter+1)/2}"
      records << record
      date = date.next
    end
    records
  end
end
