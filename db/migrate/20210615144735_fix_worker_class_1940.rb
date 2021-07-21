class FixWorkerClass1940 < ActiveRecord::Migration[6.0]
  def change
    Census1940Record.where(worker_class: 'Gw').each do |row|
      row.worker_class = 'GW'
      row.save
    end
    Census1940Record.where(worker_class: 'Pw').each do |row|
      row.worker_class = 'PW'
      row.save
    end
    Census1940Record.where(worker_class: 'Oa').each do |row|
      row.worker_class = 'OA'
      row.save
    end
    Census1940Record.where(worker_class: 'Np').each do |row|
      row.worker_class = 'NP'
      row.save
    end
    Census1940Record.where(worker_class: 'Unknown').each do |row|
      row.worker_class = 'unknown'
      row.save
    end
  end
end
