module Sleek
  module Queries
    module Targetable
      def valid_options?
        super && options[:target_property].present?
      end

      def target_property
        "d.#{options[:target_property]}"
      end
    end
  end
end
