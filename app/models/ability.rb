class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    user ||= User.new(nil) # Guest user
    @user = user

    if user.role_id == "staff_admin"
      can :manage, :all
    elsif user.role_id == "client_admin" && user.uid.present?
      can [:create, :update, :read], Report, :user_id => user.uid
    end
  end
end
