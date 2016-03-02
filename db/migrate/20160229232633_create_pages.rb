class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :name, null: false
      t.text :config, null: false
      
      t.timestamps null: false

      t.index :name, unique: true
    end
  end
end
