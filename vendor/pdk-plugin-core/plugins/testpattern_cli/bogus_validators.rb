module PDK
  module Validate
    class BogusPausingValidator < PDK::Validate::InternalRubyValidator
      def initialize(*_)
        super
      end

      def delay
        0
      end

      def return_code
        0
      end

      def name
        "pausing_validator_#{delay}"
      end

      def pattern
        ['*']
      end

      def ui_job_text(_targets = [])
        if return_code.zero?
          "#{delay} second validator"
        else
          "#{delay} second failing validator"
        end
      end

      def before_validation
        @paused = false
      end

      def validate_target(report, target)
        return return_code if @paused
        @paused = true
        sleep(delay)
        return_code
      end
    end

    class BogusValidator2sec < BogusPausingValidator
      def delay
        2
      end
    end

    class BogusValidator7sec < BogusPausingValidator
      def delay
        7
      end
    end

    class BogusFailingValidator5sec < BogusPausingValidator
      def delay
        5
      end

      def return_code
        1
      end
    end

    class BogusValidatorGroup1 < PDK::Validate::ValidatorGroup
      def name
        'bogus_group_1'
      end

      def validators
        [BogusValidator2sec].freeze
      end
    end

    class BogusValidatorGroup2 < PDK::Validate::ValidatorGroup
      def name
        'bogus_group_2'
      end

      def validators
        [BogusValidator2sec, BogusValidator7sec].freeze
      end
    end

    class BogusValidatorGroup3 < PDK::Validate::ValidatorGroup
      def name
        'bogus_group_3'
      end

      def validators
        [BogusValidator2sec].freeze
      end
    end

    class BogusValidatorGroup4 < PDK::Validate::ValidatorGroup
      def name
        'bogus_group_4'
      end

      def validators
        [BogusValidator2sec, BogusFailingValidator5sec].freeze
      end
    end

    class BogusValidatorGroup5 < PDK::Validate::ValidatorGroup
      def name
        'bogus_group_5'
      end

      def validators
        [BogusValidator2sec].freeze
      end
    end
  end
end
