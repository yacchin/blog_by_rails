class Tag < ActiveRecord::Base
  attr_accessible :name, :post_ids
  has_many :taggings
  has_many :posts, through: :tagging

end
