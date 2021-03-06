class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer :local_id
	  t.boolean :deleted, :default => false
	  t.string :name
      t.string :description
			t.string :activity
      t.integer :language_id
			t.integer :user_id
			t.datetime :project_date
			t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
