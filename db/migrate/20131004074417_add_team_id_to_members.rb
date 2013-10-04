class AddTeamIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :team_id, :integer
  end
end
