class Member < ActiveRecord::Base
  belongs_to :team, touch: true
end
