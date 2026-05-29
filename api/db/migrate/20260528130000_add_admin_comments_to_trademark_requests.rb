class AddAdminCommentsToTrademarkRequests < ActiveRecord::Migration[8.1]
  def up
    add_column :trademark_requests, :admin_comments, :text

    create_updateable_model.update_all(admin_comments: "")

    change_column_null :trademark_requests, :admin_comments, false
  end

  def down
    remove_column :trademark_requests, :admin_comments
  end

  private

  def create_updateable_model
    Class.new(ApplicationRecord) do
      self.table_name = "trademark_requests"
    end
  end
end
