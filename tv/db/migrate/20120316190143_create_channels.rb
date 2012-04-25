class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :channum
      t.string :callsign
      t.string :name
      t.boolean :visible

      t.timestamps
    end

    rename_column :channels, :id, :chanid
    [:channum, :visible].each{|m| add_index :channels, m}
    rename_table  'channels', 'channel'
  end
end
