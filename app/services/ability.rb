# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      # a guest user can only do this stuff
      can :read, Person
      can :read, Building, &:reviewed?
      can :read, Architect
      can :read, CensusRecord, &:reviewed?
      can :read, Photograph, &:reviewed?
      can :read, Audio, &:reviewed?
      can :read, Video, &:reviewed?
      can :read, Document, &:available_to_public?
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
        can :review, [Photograph, Audio, Video, Narrative]
      end

      if user.has_role?('photographer')
        can :update, [Photograph, Audio, Video]
      end

      if user.has_role?('census taker')
        can :create, CensusRecord
        can :update, CensusRecord, created_by_id: user.id, reviewed_by_id: nil
      end

      if user.has_role?('builder')
        can :create, Building
        can :update, Building
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
      can :create, Flag
      can :read, Document
      can :read, Person

      # User generated photographs?
      can :create, [Photograph, Audio, Video, Narrative]
      can :update, [Photograph, Audio, Video, Narrative], created_by_id: user.id, reviewed_by_id: nil
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
