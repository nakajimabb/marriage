class AddEtcToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :first_name_kana, :string
    add_column :users, :last_name_kana, :string
    add_column :users, :first_name_en, :string
    add_column :users, :last_name_en, :string
    add_column :users, :sex, :tinyint, null: false
    add_column :users, :birthday, :date
    add_column :users, :tel, :string
    add_column :users, :fax, :string
    add_column :users, :country, :smallint
    add_column :users, :zip, :integer
    add_column :users, :prefecture, :smallint
    add_column :users, :city, :string
    add_column :users, :house_number, :string
    add_column :users, :religion, :tinyint
    add_column :users, :sect, :tinyint
    add_column :users, :bio, :string
    add_column :users, :admin, :boolean, null: false, default: false
  end
end
