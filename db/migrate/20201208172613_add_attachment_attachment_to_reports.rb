class AddAttachmentAttachmentToReports < ActiveRecord::Migration[5.2]
  def self.up
    change_table :reports do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :reports, :attachment
  end
end
