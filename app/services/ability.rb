# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      # a guest user can only do this stuff
      can :read, Person
      can :read, Building do |building| building.reviewed?; end
      can :read, Architect
      can :read, CensusRecord do |record| record.reviewed?; end
      can :read, Photograph do |record| record.reviewed?; end
      can :read, Document do |record| record.available_to_public?; end

    else
      # A user can have multiple roles so we only grant the things that apply to that role

      if user.has_role?('administrator')
        can :manage, :all
        cannot :review, Person # because it isn't a thing right now
      end

      if user.has_role?('editor')
        can :create, CensusRecord
        can :update, CensusRecord
      end

      if user.has_role?('reviewer')
        can :review, CensusRecord
        can :review, Building
        can :review, Photograph
      end

      if user.has_role?('photographer')
        can :create, Photograph
        can :update, Photograph
      end

      if user.has_role?('census taker')
        can :create, CensusRecord
        can :update, CensusRecord, created_by_id: user.id
      end

      if user.has_role?('builder')
        can :create, Building
        can :update, Building #, created_by_id: user.id
        can :merge, Building
      end

      if user.has_role?('person record editor')
        can :create, Person
        can :update, Person
        can :merge, Person
        can :destroy, Person
      end

      # any logged in user can do the following things:

      can :update, User, id: user.id
      can :read, CensusRecord
      can :read, Building
      can :read, Photograph
      can :create, Flag
      can :read, Document
      can :read, Person

      # User generated photographs?
      can :create, Photograph
      can :update, Photograph, created_by_id: user.id
    end
  end

  def can?(action, subject, attribute = nil, *extra_args)
    subject = subject.object if subject.is_a?(ApplicationDecorator)
    super(action, subject, attribute, *extra_args)
  end
end

# can :manage, Photograph
# can :manage, Flag
# can :manage, Person
# can :manage, :all
# cannot :bulk_update, :all
# cannot :manage, User
# can :manage, Document
# can :manage, DocumentCategory
# can :manage, Building
# can :manage, Architect
# can :manage, CensusRecord
# can :manage, Photograph
# can :manage, Flag
# can :manage, Person
# can :manage, StreetConversion
