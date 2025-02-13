# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Person

    # Everybody can read these things if they've been reviewed
    can :read, [
      Architect,
      Audio,
      Building,
      CensusRecord,
      Narrative,
      Photograph,
      Video
    ]

    cannot :read, [
      Audio,
      Building,
      CensusRecord,
      Narrative,
      Photograph,
      Video
    ], reviewed_at: nil

    if user.blank?
      # a guest user can only do this stuff
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
        can :read, CensusRecord, reviewed_at: nil
      end

      if user.has_role?('reviewer')
        can :review, CensusRecord
        can :review, Building
        can :review, [Photograph, Audio, Video, Narrative]
      end

      if user.has_role?('photographer')
        can :update, [Photograph, Audio, Video, Narrative]
        can :read, [Photograph, Audio, Video, Narrative], reviewed_at: nil
      end

      if user.has_role?('census taker')
        can :read, CensusRecord, reviewed_at: nil
        can :read, Building, reviewed_at: nil
        can :create, CensusRecord
        can :update, CensusRecord, created_by_id: user.id, reviewed_at: nil
      end

      if user.has_role?('builder')
        can :read, Building, reviewed_at: nil
        can :create, Building
        can :update, Building
        can :merge, Building
        can :review, Building
      end

      if user.has_role?('person record editor')
        can :create, Person
        can :update, Person
        can :merge, Person
        can :destroy, Person
      end

      if user.has_role?('content editor')
        can :manage, [Photograph, Audio, Video, Narrative]
      end

      # any logged-in user can do the following things:

      can :update, User, id: user.id
      can :create, Flag
      can :read, Document

      # Anyone can add user generated content
      can :create, [Photograph, Audio, Video, Narrative]

      # Anyone can edit their own user generated content until it's been reviewed
      can %i[read update destroy], [Photograph, Audio, Video, Narrative], created_by_id: user.id, reviewed_by_id: nil
    end
  end

  def can?(action, subject, attribute = nil, *extra_args)
    subject = subject.object if subject.is_a?(ApplicationDecorator)
    super(action, subject, attribute, *extra_args)
  end
end
