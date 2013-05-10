module Sleek
  class EventMetadata
    include Mongoid::Document
    include Mongoid::Timestamps::Created::Short

    field :t, type: Time, as: :timestamp
    embedded_in :event

    before_create :set_timestamp

    def set_timestamp
      self.timestamp = created_at unless timestamp
    end
  end

  class Event
    include Mongoid::Document

    field :ns, type: Symbol, as: :namespace
    field :b, type: String, as: :bucket
    field :d, type: Hash, as: :data
    embeds_one :sleek, store_as: "s", class_name: 'Sleek::EventMetadata', cascade_callbacks: true
    accepts_nested_attributes_for :sleek

    validates :namespace, presence: true
    validates :bucket, presence: true

    after_initialize { build_sleek }

    index ns: 1, b: 1, "s.t" => 1

    def self.create_with_namespace(namespace, bucket, payload)
      sleek = payload.delete(:sleek)
      event = create(namespace: namespace, bucket: bucket, data: payload)
      event.sleek.update_attributes sleek
      event
    end
  end
end
