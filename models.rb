require 'digest/sha1'
require 'bcrypt'
require 'carrierwave/orm/mongoid'
require 'mongoid'   
                  
class ImageUploader < CarrierWave::Uploader::Base
  def store_dir
    'public/uploads'
  end
end

class Person
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, :unique => true
  field :key
  field :last_seen, :type => DateTime

  # references_many :channels

  def verify(token)
    if (Digest::SHA1.hexdigest(self.key + "salt" + self.username) == token)
      true
    else
      false
    end
  end
end         

class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username
  field :channel
  field :text
  field :image   
  field :yeps
  field :nopes  

  references_many :comments                     
  
  mount_uploader :image, ImageUploader
end

class Comment
  include Mongoid::Document
  field :username
  field :body
  referenced_in :post                     
  
end
