class Customer < ActiveRecord::Base
end

file = File.expand_path(File.dirname(__FILE__) + '/../customers.csv')

source :input,
  {
    :file => file,
    :parser => :csv,
    :skip_lines => 1
  },
  [
    :first_name,
    :last_name,
    :email
  ]

transform(:email_provider) do |n,v,r|
  r[:email].downcase.split('@').last
end

transform :email_provider, :default,
  :default_value => "Unknown"

transform(:full_name) do |n,v,r|
  [r[:first_name], r[:last_name]].join(' ')
end

before_write do |r|
  r[:email_provider] =~ /hotmail/ ? nil : r
end

destination :out, {
  :type => :insert_update_database,
  :target => :datawarehouse,
  :table => 'customers'
},
{
  :primarykey => [:email],
  :order => [:email, :full_name, :email_provider]
}

screen(:fatal) {
  assert_equal 1, Customer.where(:email => 'john.barry@gmail.com').count
}