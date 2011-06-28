class CreateCommitsTable < ActiveRecord::Migration

  def self.up
    create_table :commits do |t|
      t.string :hash

      t.integer :files_changed
      t.integer :insertions
      t.integer :deletions

      t.integer :date_id
      t.integer :time_id
      t.integer :user_id
    end
    
    add_index :commits, :hash, :unique
  end
  
  def self.down
    drop_table :commits
  end
  
end