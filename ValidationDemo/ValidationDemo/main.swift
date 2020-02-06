import Foundation
import ValidatedPropertyKit

struct ProfileFormViewModel {

    struct PasswordModel {
        var password: String
        var confirmation: String
    }

    @Validated(.nonEmpty)
    var username: String?

    @Validated(.isEmail)
    var email: String?

    @Validated(.isURL && .contains("https://"))
    var avatarURL: String?

    @Validated(.keyPath(\.password, .range(8...)) && .confirmationMatches)
    var password: PasswordModel?

    @Validated(.greaterOrEqual(13))
    var age: Int?

    func validate() -> [(String, String)] {
        let validations = [
            ("Username", _username.validationError),
            ("Email", _email.validationError),
            ("Avatar URL", _avatarURL.validationError),
            ("Password", _password.validationError),
            ("Age", _age.validationError)
        ]

        return validations.compactMap { pair -> (String, String)? in
            guard let errorMessage = pair.1?.failureReason else { return nil }
            return (pair.0, errorMessage)
        }
    }
}

extension Validation where Value == ProfileFormViewModel.PasswordModel {
    static var confirmationMatches: Validation {
        return .init { (passwordModel) -> Result<Void, ValidationError> in
            if passwordModel.confirmation == passwordModel.password {
                return .success(())
            } else {
                return .failure(ValidationError(message: "Passwords don't match"))
            }
        }
    }
}

var profile = ProfileFormViewModel()
profile.username = "musicman123"
profile.email = "joe@foo.com"
profile.avatarURL = "https://example.com/avatar.jpg"
profile.password = ProfileFormViewModel.PasswordModel(password: "123123123", confirmation: "123123123")

profile.username = ""

print("Username: ", profile.username ?? "(nil)")
print("Email: ", profile.email ?? "(nil)")
print("Avatar URL: ", profile.avatarURL ?? "(nil)")

print(profile.validate())
