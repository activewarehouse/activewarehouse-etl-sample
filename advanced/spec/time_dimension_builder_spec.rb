require File.dirname(__FILE__) + '/spec_helper'
require 'time_dimension_builder'

describe TimeDimensionBuilder do

  def times(from, to, key=nil)
    result = TimeDimensionBuilder.new(from, to).build
    result.map! { |e| e[key] } unless key.nil?
    result
  end
  
  def time(time, key=nil)
    times(time, time, key).first
  end
  
  it "should return exactly one record for each minute of the 24 hours day" do
    times('0:00', '23:59', :sql_time_stamp).size.should eql(60*24)
  end
  
  it "should fill the sql_time_stamp" do
    time('21:00', :sql_time_stamp).should eql('21:00')
  end
  
  it "should fill the hour as integer" do
    times('21:00', '21:59', :hour).uniq.should eql([21])
  end
  
  it "should fill the hour description" do
    times('17:00', '17:59', :hour_description).uniq.should eql(["between 05:00 pm and 05:59 pm"])
  end
  
  it "should fill the half hour description" do
    times('20:00', '20:29', :half_hour_description).uniq.should eql(["between 08:00 pm and 08:29 pm"])
    times('20:30', '20:59', :half_hour_description).uniq.should eql(["between 08:30 pm and 08:59 pm"])
    times('7:00', '7:29', :half_hour_description).uniq.should eql(["between 07:00 am and 07:29 am"])
  end
  
  it "should fill the day part" do
    times('0:00', '7:59', :day_part).uniq.should eql(["night"])
    times('8:00', '11:59', :day_part).uniq.should eql(["morning"])
    times('12:00', '18:59', :day_part).uniq.should eql(["afternoon"])
    times('19:00', '21:59', :day_part).uniq.should eql(["evening"])
    times('22:00', '23:59', :day_part).uniq.should eql(["night"])
  end

  it "should states weither the hour is a closed or opened hour" do
    times('0:00', '8:59', :hour_type).uniq.should eql(["non opening hours"])
    times('9:00', '16:59', :hour_type).uniq.should eql(["opening hours"])
    times('17:00', '23:59', :hour_type).uniq.should eql(["non opening hours"])
  end
  
end