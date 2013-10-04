class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :bio

      t.timestamps
    end
  end
end
