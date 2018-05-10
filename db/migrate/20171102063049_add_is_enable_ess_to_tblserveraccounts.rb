class AddIsEnableEssToTblserveraccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :tblserveraccounts, :IsEnableESS, :boolean, :default => false, :null => false
  end
end
