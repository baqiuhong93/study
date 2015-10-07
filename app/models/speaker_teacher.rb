class SpeakerTeacher < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :teacherable
  attr_accessible :teacher_name, :teacher_id
  
end
