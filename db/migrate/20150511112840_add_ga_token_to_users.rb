class AddGaTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ggl_access_token, :string
  end
end
