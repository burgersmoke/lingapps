class Language < ActiveRecord::Base
	
	validates_presence_of :name, :code
  validates_uniqueness_of :code
  
  def to_s
    name
  end

end
