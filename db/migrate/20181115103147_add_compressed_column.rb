class AddCompressedColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :compressed, :binary, :limit => 10.megabyte
  end

  def self.down
    remove_column :reports, :compressed
  end
end
