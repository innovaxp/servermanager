class UploadService < ActiveRecord::Base

  has_many :backup_configurations
  serialize :meta

  validates :name, :presence => true
  validates :location, :presence => true


    def nice_name
      return self.name+"("+self.location+")"
    end
end
