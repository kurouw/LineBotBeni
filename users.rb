class User
  include Mongoid::Document
  field :toId, type: String
  field :pref, type: String
  field :shopName, type: String
=begin
  validates :toId, presence: true
  validates :toId, unqueness: true
  validates :pref, presence: true
  validates :shopName, presence: true
=end
end
