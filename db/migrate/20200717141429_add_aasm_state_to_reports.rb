class AddAasmStateToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :aasm_state, :string
  end
end
