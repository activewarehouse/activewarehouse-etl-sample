class CreateCustomers < ActiveRecord::Migration

  def change
    create_table :customers, :force => true do |t|
      t.string :full_name
      t.string :email
      t.string :email_provider
    end
  end
  
end