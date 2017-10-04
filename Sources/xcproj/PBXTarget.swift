import Foundation

// This element is an abstract parent for specialized targets.
public class PBXTarget: PBXObject, Hashable, Decodable {

    /// Target build configuration list.
    public var buildConfigurationList: String

    /// Target build phases.
    public var buildPhases: [String]

    /// Target build rules.
    public var buildRules: [String]

    /// Target dependencies.
    public var dependencies: [String]

    /// Target name.
    public var name: String

    /// Target product name.
    public var productName: String?

    /// Target product reference.
    public var productReference: String?

    /// Target product type.
    public var productType: PBXProductType?

    public init(reference: String,
                buildConfigurationList: String,
                buildPhases: [String],
                buildRules: [String],
                dependencies: [String],
                name: String,
                productName: String? = nil,
                productReference: String? = nil,
                productType: PBXProductType? = nil) {
        self.buildConfigurationList = buildConfigurationList
        self.buildPhases = buildPhases
        self.buildRules = buildRules
        self.dependencies = dependencies
        self.name = name
        self.productName = productName
        self.productReference = productReference
        self.productType = productType
        super.init(reference: reference)
    }
    
    enum CodingKeys: String, CodingKey {
        case buildConfigurationList
        case buildPhases
        case buildRules
        case dependencies
        case name
        case productName
        case productReference
        case productType
        case reference
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.buildConfigurationList = try container.decode(String.self, forKey: .buildConfigurationList)
        self.buildPhases = try container.decode([String].self, forKey: .buildPhases)
        self.buildRules = try container.decode([String].self, forKey: .buildRules)
        self.dependencies = try container.decode([String].self, forKey: .dependencies)
        self.name = try container.decode(String.self, forKey: .name)
        self.productName = try container.decode(String?.self, forKey: .productName)
        self.productReference = try container.decode(String?.self, forKey: .productReference)
        self.productType = try container.decode(PBXProductType?.self, forKey: .productType)
        let reference = try container.decode(String.self, forKey: .reference)
        super.init(reference: reference)
    }

    public static func == (lhs: PBXTarget,
                           rhs: PBXTarget) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.buildConfigurationList == rhs.buildConfigurationList &&
            lhs.buildPhases == rhs.buildPhases &&
            lhs.buildRules == rhs.buildRules &&
            lhs.dependencies == rhs.dependencies &&
            lhs.name == rhs.name &&
            lhs.productReference == rhs.productReference &&
            lhs.productType == rhs.productType
    }

    func plistValues(proj: PBXProj, isa: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(isa))
        let buildConfigurationListComment = "Build configuration list for \(isa) \"\(name)\""
        dictionary["buildConfigurationList"] = .string(CommentedString(buildConfigurationList, comment: buildConfigurationListComment))
        dictionary["buildPhases"] = .array(buildPhases
            .map { buildPhase in
                let comment = proj.buildPhaseName(buildPhaseReference: buildPhase)
                return .string(CommentedString(buildPhase, comment: comment))
        })
        dictionary["buildRules"] = .array(buildRules.map {.string(CommentedString($0))})
        dictionary["dependencies"] = .array(dependencies.map {.string(CommentedString($0, comment: PBXTargetDependency.isa))})
        dictionary["name"] = .string(CommentedString(name))
        if let productName = productName {
            dictionary["productName"] = .string(CommentedString(productName))
        }
        if let productType = productType {
            dictionary["productType"] = .string(CommentedString("\"\(productType.rawValue)\""))
        }
        if let productReference = productReference {
            let productReferenceComment = proj.fileName(buildFileReference: productReference)
            dictionary["productReference"] = .string(CommentedString(productReference, comment: productReferenceComment))
        }
        return (key: CommentedString(self.reference, comment: name),
                value: .dictionary(dictionary))
    }
    
}
