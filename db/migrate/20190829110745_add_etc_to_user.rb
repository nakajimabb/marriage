class AddEtcToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :status, :tinyint, unsigned: true, null: false
    add_column :users, :first_name, :string, limit: 64
    add_column :users, :last_name, :string, limit: 64
    add_column :users, :first_name_kana, :string, limit: 64
    add_column :users, :last_name_kana, :string, limit: 64
    add_column :users, :first_name_en, :string, limit: 64
    add_column :users, :last_name_en, :string, limit: 64
    add_column :users, :sex, :tinyint, null: false
    add_column :users, :birthday, :date
    add_column :users, :tel, :string, limit: 16
    add_column :users, :mobile, :string, limit: 16
    add_column :users, :fax, :string, limit: 16
    add_column :users, :lang, :tinyint, unsigned: true
    add_column :users, :country, :smallint
    add_column :users, :zip, :string, limit: 10
    add_column :users, :prefecture, :smallint
    add_column :users, :city, :string, limit: 64
    add_column :users, :street, :string, limit: 64
    add_column :users, :building, :string, limit: 64
    add_column :users, :religion, :tinyint
    add_column :users, :sect, :string, limit: 64
    add_column :users, :church, :string, limit: 64
    add_column :users, :baptized, :boolean
    add_column :users, :baptized_year, :smallint
    add_column :users, :bio, :string
    add_column :users, :role_courtship, :boolean, null: false, default: false
    add_column :users, :role_matchmaker, :boolean, null: false, default: false
    add_column :users, :role_head, :boolean, null: false, default: false
    add_column :users, :gene_partner_id, :string, limit: 10
    add_column :users, :income, :integer
    add_column :users, :drinking, :tinyint
    add_column :users, :smoking, :tinyint
    add_column :users, :weight, :tinyint, unsigned: true
    add_column :users, :height, :tinyint, unsigned: true
    add_column :users, :job, :string, limit: 64
    add_column :users, :education, :string, limit: 64
    add_column :users, :hobby, :string, limit: 64
    add_column :users, :blood, :tinyint
    add_column :users, :marital_status, :tinyint
    add_column :users, :diseased, :boolean
    add_column :users, :disease_name, :string, limit: 64
    add_column :users, :remark, :text
    add_column :users, :member_sharing, :tinyint
    add_reference :users, :matchmaker, foreign_key: { to_table: :users }
    add_reference :users, :created_by, foreign_key: { to_table: :users }
    add_reference :users, :updated_by, foreign_key: { to_table: :users }
  end
end
