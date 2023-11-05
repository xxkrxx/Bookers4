class CreateFolloweds < ActiveRecord::Migration[6.1]
  def change
    create_table :followeds do |t|

      t.timestamps
    end
  end
end
