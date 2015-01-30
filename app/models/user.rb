class User < ActiveRecord::Base
  attr_accessible :name, :password
  belongs_to :post
end
