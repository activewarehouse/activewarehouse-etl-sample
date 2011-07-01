require File.dirname(__FILE__) + '/spec_helper'
require 'date_dimension_builder'

describe DateDimensionBuilder do

  def days(from, to, key=nil)
    result = DateDimensionBuilder.new(from, to).build
    result.map! { |e| e[key] } unless key.nil?
    result
  end
  
  def day(from, key=nil)
    days(from, from, key).first
  end
  
  it "should return the expected number of days" do
    days('2007-01-01', '2007-12-31').size.should eql(365) 
  end
  
  it "should return :date formatted as yyyy-mm-dd" do
    day('2007-12-31', :date).should eql('2007-12-31')
  end
  
  it "should return :month in english" do
    (1..12).map { |month| day("2007-#{month}-01", :month) }.should eql(
      %w(january february march april may june july august september october november december)
    )
  end
  
  it "should return :year on four digits" do
    days('1959-1-1', '1959-12-31', :year).uniq.should eql(%w(1959))
  end
  
  it "should return :year_and_month in a sortable fashion" do
    day('2008-02-03', :year_and_month).should eql('2008-02')
    day('2008-12-03', :year_and_month).should eql('2008-12')
  end
  
  it "should return all the days of week in english" do
    days('2007-12-01', '2007-12-07', :day_of_week).should eql(%w(saturday sunday monday tuesday wednesday thursday friday))
  end
  
  it "should return all the days of week as numbers starting by sunday as 0" do
    days('2007-12-01', '2007-12-07', :day_of_week_as_number).should eql([6, 0, 1, 2, 3, 4, 5])
  end
  
  it "should return a sql_date_stamp" do
    day('1991-1-1', :sql_date_stamp).should eql(Date.parse("1991-1-1"))
  end
  
  it "should return :quarter" do
    day('2007-12-01', :quarter).should eql('Q4')
    day('2007-06-30', :quarter).should eql('Q2')
  end

  it "should implement quarter properly - it's home baked after all" do
    (1..12).map { |month| day("2007-#{month}-01", :quarter) }.should eql(%w(Q1 Q1 Q1 Q2 Q2 Q2 Q3 Q3 Q3 Q4 Q4 Q4))
  end
  
  it "should return :semester" do
    day('2007-7-1', :semester).should eql('S2')
    day('2007-06-30', :semester).should eql('S1')
    day('2007-12-31', :semester).should eql('S2')
  end
  
  it "should return :week and respect ISO 8601" do
    # http://fr.wikipedia.org/wiki/ISO_8601
    day('2009-12-31', :week).should eql('week 53')
    day('2010-1-1', :week).should eql('week 53')
    day('2010-1-4', :week).should eql('week 1')
  end
  
end