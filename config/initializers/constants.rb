class IdentifierError < RuntimeError; end

RESCUABLE_EXCEPTIONS = [CanCan::AccessDenied,
                        JWT::VerificationError,
                        JSON::ParserError,
                        ActiveRecord::RecordNotFound,
                        # AbstractController::ActionNotFound,
                        ActiveRecord::RecordNotUnique,
                        ActionController::RoutingError,
                        ActionController::ParameterMissing,
                        ActionController::UnpermittedParameters,
                        ActiveRecord::RecordInvalid,
                        NoMethodError]

COUNTRY_CODES = IsoCountryCodes.for_select.map {|code| code.last.downcase}
