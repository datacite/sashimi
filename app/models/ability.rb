class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    user ||= User.new(nil) # Guest user
    @user = user

    if user.role_id == "staff_admin"
      can :manage, :all
    elsif user.role_id == "client_admin" && user.client_id.present?
      can [:create, :update, :read], Report, :client_id => user.client_id
    end
  end
end
