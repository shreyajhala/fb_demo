class User < ActiveRecord::Base
  serialize :friends, Hash

  def self.create_with_omniauth(auth)
    user = User.new(email: auth["info"]["email"], uid: auth["uid"], token: auth["credentials"]["token"])
    user.save
    user = User.find_by(uid: auth["uid"])
    my_freinds = Array.new
    fb_friends = FbGraph::User.me(user.token).friends
    fb_friends.each do |x| my_freinds << [x.raw_attributes.fetch(:id), x.raw_attributes.fetch(:name)] end
    user.update_attributes(friends: Hash[my_freinds])
    user
  end

  def get_mutual_friends(user_id)
    graph = Koala::Facebook::API.new(self.token)
    friend_id = user_id
    graph.get_connections("me", "mutualfriends/#{friend_id}")
  end

end