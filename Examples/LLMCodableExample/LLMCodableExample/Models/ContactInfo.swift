import LLMCodable
import FoundationModels

@Generable
struct ContactInfo: LLMCodable {
    @Guide(description: "Email address")
    var email: String?

    @Guide(description: "Phone number")
    var phone: String?

    @Guide(description: "Physical address")
    var address: String?
}
