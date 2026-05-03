public protocol SAFormValidationTypeRules {
    associatedtype Value: Sendable

    typealias Rule = (_ value: Value) async -> SAFormValidationResponse<Value>

    var rules: [Rule] { get set }
    var localizations: SAFormLocalizations { get }

    func validate(value: Value) async -> SAFormValidationResponse<Value>
}

public extension SAFormValidationTypeRules {
    var localizations: SAFormLocalizations {
        SAFormLocalizations()
    }

    func validate(raw: Any?) async -> SAFormValidationResponse<Value> {
        guard let typed = raw as? Value else {
            if raw == nil {
                return .failure(errors: .init([localizations.required]))
            }

            return .failure(
                errors: .init([
                    localizations.invalidType(
                        String(describing: Value.self),
                        String(describing: type(of: raw!))
                    )
                ])
            )
        }

        return await validate(value: typed)
    }

    func validate(value: Value) async -> SAFormValidationResponse<Value> {
        var modifyValue = value

        for rule in rules {
            let validated = await rule(modifyValue)

            switch validated {
            case .success(let successValue):
                modifyValue = successValue
            case .failure(let failure):
                return .failure(errors: failure)
            }
        }

        return .success(value: modifyValue)
    }

    func addRule(_ rule: @escaping Rule) -> Self {
        var copySelf = self
        
        copySelf.rules.append(rule)
        
        return copySelf
    }
}

public struct SAFormValidationRules {
    public init() {}
}
