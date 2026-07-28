# frozen_string_literal: true

module Atol
  module Request
    class PostDocument
      module Correction
        class Body
          BadApiUrlError = Class.new(StandardError)

          attr_reader :instance

          def initialize(**kwargs)
            config = kwargs[:config] || Atol.config
            @instance = case config.api_url
                        when Atol::Version::V5, Atol::Version::V5_TEST
                          Atol::Request::PostDocument::Correction::V5::Body.new(**kwargs)
                        when Atol::Version::V4, Atol::Version::V4_TEST
                          raise BadApiUrlError, 'correction body for the v4 api is not implemented'
                        else
                          raise BadApiUrlError
                        end
          end

          def to_h
            instance.to_h
          end

          def to_json(*args)
            instance.to_json(*args)
          end
        end
      end
    end
  end
end
