class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.string :suit
      t.string :num

      t.timestamps
    end
  end
end
