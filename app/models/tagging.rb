class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :post

  scope :search_post_taggings, lambda { |post_id|
  	where("post_id = ?", "#{post_id}")
  }

end
