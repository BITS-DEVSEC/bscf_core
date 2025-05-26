class AddLockedAmountToVirtualAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :bscf_core_virtual_accounts, :locked_amount, :decimal
  end
end
