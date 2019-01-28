class User < ApplicationRecord
  
  before_save { self.email.downcase! }
  
  validates :name, presence: true, length:{maximum: 50}
  validates :email, presence: true, length:{maximum: 255},format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  
  has_secure_password
  
  has_many :microposts
  
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :likes
  has_many :liked_microposts, through: :likes, source: :micropost
  
  def like(other_micropost)
    unless self == other_micropost.user
    self.likes.find_or_create_by(micropost_id: other_micropost.id)
    end
  end
  
  def unlike(other_micropost)
    like = self.likes.find_by(micropost_id: other_micropost.id)
    like.destroy if like
  end
  
  def liked_micropost?(other_micropost)
    self.liked_microposts.include?(other_micropost)
  end
  
    
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def feed_likes
    Micropost.where(user_id: self.liked_micropost_ids)
  end
  
  def self.liked_microposts_by(user_id)
    user = User.find(user_id)
    user.liked_microposts
  end
  # class << self
  #   def liked_microposts_by(user_id)
  #     user = User.find(user_id)
  #     user.liked_microposts
  #   end
  # end
end

