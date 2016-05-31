class User
  include Mongoid::Document
  field :toId, type: String
  field :pref, type: String
  field :shopName, type: String
end
