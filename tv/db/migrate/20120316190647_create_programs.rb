class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.integer :chanid
      t.datetime :starttime
      t.datetime :endtime
      t.string :title
      t.string :subtitle
      t.string :description
      t.string :category
      t.string :category_type
      t.date :airdate
      t.float :stars
      t.boolean :previouslyshown

      t.timestamps
    end

    [:chanid, :starttime, :endtime, :title].each{|m| add_index :programs, m }
    rename_table :programs, :program
  end
end
