class Post < ActiveRecord::Base
  attr_accessible :body, :title, :tag_ids
  has_many :taggings
  has_many :tags, through: :tagging
  has_many :user
end
