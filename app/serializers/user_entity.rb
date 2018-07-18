class UserEntity < API::Entities::UserBasic
  include RequestAwareEntity

  expose :path do |user|
    user_path(user)
  end
end
