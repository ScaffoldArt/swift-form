import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

public struct SAForm: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        let structName = structDecl.name.text
        let nestedStructsByName = collectNestedStructDeclarations(in: structDecl)

        let accessNamesLines = buildAccessLines(
            in: structDecl,
            nestedStructsByName: nestedStructsByName,
            mode: .names,
            pathParts: [],
            keyPath: "",
            loopDepth: 0,
            visitedStructNames: [structName]
        )

        let accessOrderLines = buildAccessLines(
            in: structDecl,
            nestedStructsByName: nestedStructsByName,
            mode: .order,
            pathParts: [],
            keyPath: "",
            loopDepth: 0,
            visitedStructNames: [structName]
        )

        let accessNamesBody = renderBody(accessNamesLines)
        let accessOrderBody = renderBody(accessOrderLines)

        return [
            """
            func getAccessNames() -> [String: PartialKeyPath<\(raw: structName)>] {
                var accessNames: [String: PartialKeyPath<\(raw: structName)>] = [:]
            \(raw: accessNamesBody)    return accessNames
            }

            func getAccessOrder() -> [String] {
                var accessOrder: [String] = []
            \(raw: accessOrderBody)    return accessOrder
            }
            """
        ]
    }

    private enum AccessMode {
        case names
        case order
    }

    private enum PathPart {
        case property(String)
        case index(String)
    }

    private static func buildAccessLines(
        in structDecl: StructDeclSyntax,
        nestedStructsByName: [String: StructDeclSyntax],
        mode: AccessMode,
        pathParts: [PathPart],
        keyPath: String,
        loopDepth: Int,
        visitedStructNames: Set<String>
    ) -> [String] {
        var lines: [String] = []

        for member in structDecl.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self), !isStaticOrClass(variable) else {
                continue
            }

            for binding in variable.bindings {
                guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    continue
                }

                let propertyName = identifier.identifier.text
                let nextPathParts = pathParts + [.property(propertyName)]
                let nextKeyPath = appendProperty(propertyName, to: keyPath)

                if let referencedType = referencedTypeName(for: binding),
                   let referencedStruct = nestedStructsByName[referencedType],
                   isGroupStruct(referencedStruct) {
                    guard !visitedStructNames.contains(referencedType) else {
                        continue
                    }

                    lines += buildAccessLines(
                        in: referencedStruct,
                        nestedStructsByName: nestedStructsByName,
                        mode: mode,
                        pathParts: nextPathParts,
                        keyPath: nextKeyPath,
                        loopDepth: loopDepth,
                        visitedStructNames: visitedStructNames.union([referencedType])
                    )
                    continue
                }

                if let itemType = collectionItemTypeName(for: binding),
                   let itemStruct = nestedStructsByName[itemType],
                   isCollectionItemStruct(itemStruct) {
                    guard !visitedStructNames.contains(itemType) else {
                        continue
                    }

                    let indexName = "_saFormIndex\(loopDepth)"
                    lines.append("for \(indexName) in self.\(nextKeyPath).indices {")

                    let nestedLines = buildAccessLines(
                        in: itemStruct,
                        nestedStructsByName: nestedStructsByName,
                        mode: mode,
                        pathParts: nextPathParts + [.index(indexName)],
                        keyPath: "\(nextKeyPath)[\(indexName)]",
                        loopDepth: loopDepth + 1,
                        visitedStructNames: visitedStructNames.union([itemType])
                    )

                    lines += indented(nestedLines)
                    lines.append("}")
                    continue
                }

                let pathExpression = renderPathExpression(nextPathParts)

                lines.append("if (self.\(nextKeyPath) as Any) is any SAFormFieldConfigurable {")
                switch mode {
                case .names:
                    lines.append("    accessNames[\(pathExpression)] = \\.\(nextKeyPath)")
                case .order:
                    lines.append("    accessOrder.append(\(pathExpression))")
                }
                lines.append("}")
            }
        }

        return lines
    }

    private static func appendProperty(_ propertyName: String, to keyPath: String) -> String {
        if keyPath.isEmpty {
            return propertyName
        }

        return "\(keyPath).\(propertyName)"
    }

    private static func renderPathExpression(_ pathParts: [PathPart]) -> String {
        var rendered = "\""
        var isFirst = true

        for pathPart in pathParts {
            switch pathPart {
            case .property(let name):
                if isFirst {
                    rendered += name
                } else {
                    rendered += ".\(name)"
                }

            case .index(let indexName):
                if isFirst {
                    rendered += "[\\(\(indexName))]"
                } else {
                    rendered += ".[\\(\(indexName))]"
                }
            }

            isFirst = false
        }

        rendered += "\""
        return rendered
    }

    private static func renderBody(_ lines: [String]) -> String {
        guard !lines.isEmpty else {
            return ""
        }

        return lines.map { "    \($0)" }.joined(separator: "\n") + "\n"
    }

    private static func indented(_ lines: [String], spaces: Int = 4) -> [String] {
        guard !lines.isEmpty else {
            return []
        }

        let prefix = String(repeating: " ", count: spaces)
        return lines.map { prefix + $0 }
    }

    private static func collectNestedStructDeclarations(
        _ structDecl: StructDeclSyntax,
        into declarationsByName: inout [String: StructDeclSyntax]
    ) {
        declarationsByName[structDecl.name.text] = structDecl

        for member in structDecl.memberBlock.members {
            guard let nestedStruct = member.decl.as(StructDeclSyntax.self) else {
                continue
            }

            collectNestedStructDeclarations(nestedStruct, into: &declarationsByName)
        }
    }

    private static func collectNestedStructDeclarations(
        in rootStruct: StructDeclSyntax
    ) -> [String: StructDeclSyntax] {
        var declarationsByName: [String: StructDeclSyntax] = [:]

        for member in rootStruct.memberBlock.members {
            guard let nestedStruct = member.decl.as(StructDeclSyntax.self) else {
                continue
            }

            collectNestedStructDeclarations(nestedStruct, into: &declarationsByName)
        }

        return declarationsByName
    }

    private static func isStaticOrClass(_ variable: VariableDeclSyntax) -> Bool {
        variable.modifiers.contains { modifier in
            let tokenKind = modifier.name.tokenKind
            return tokenKind == .keyword(.static) || tokenKind == .keyword(.class)
        }
    }

    private static func isGroupStruct(_ structDecl: StructDeclSyntax) -> Bool {
        inherits(structDecl, from: "SAFormGroup")
    }

    private static func isCollectionItemStruct(_ structDecl: StructDeclSyntax) -> Bool {
        inherits(structDecl, from: "SAFormCollectionItem")
    }

    private static func inherits(_ structDecl: StructDeclSyntax, from protocolName: String) -> Bool {
        guard let inheritanceClause = structDecl.inheritanceClause else {
            return false
        }

        for inheritedType in inheritanceClause.inheritedTypes {
            if normalizedTypeName(from: inheritedType.type.trimmedDescription) == protocolName {
                return true
            }
        }

        return false
    }

    private static func referencedTypeName(for binding: PatternBindingSyntax) -> String? {
        if let typeAnnotation = binding.typeAnnotation {
            let normalized = normalizedTypeName(from: typeAnnotation.type.trimmedDescription)
            if !normalized.isEmpty {
                return normalized
            }
        }

        guard let initializer = binding.initializer?.value.as(FunctionCallExprSyntax.self) else {
            return nil
        }

        return calledTypeName(from: initializer.calledExpression)
    }

    private static func collectionItemTypeName(for binding: PatternBindingSyntax) -> String? {
        if let typeAnnotation = binding.typeAnnotation,
           let itemType = extractCollectionItemType(from: typeAnnotation.type.trimmedDescription) {
            return itemType
        }

        guard let initializer = binding.initializer?.value.as(FunctionCallExprSyntax.self),
              isSAFormCollectionCall(initializer.calledExpression) else {
            return nil
        }

        if let trailingClosure = initializer.trailingClosure,
           let itemType = closureReturnTypeName(from: trailingClosure) {
            return itemType
        }

        if let firstArgument = initializer.arguments.first?.expression,
           let arrayExpression = firstArgument.as(ArrayExprSyntax.self),
           let firstElement = arrayExpression.elements.first?.expression.as(FunctionCallExprSyntax.self),
           let itemType = calledTypeName(from: firstElement.calledExpression) {
            return itemType
        }

        return nil
    }

    private static func isSAFormCollectionCall(_ expression: ExprSyntax) -> Bool {
        calledTypeName(from: expression) == "SAFormCollection"
    }

    private static func calledTypeName(from expression: ExprSyntax) -> String? {
        if let reference = expression.as(DeclReferenceExprSyntax.self) {
            return normalizedTypeName(from: reference.baseName.text)
        }

        if let memberAccess = expression.as(MemberAccessExprSyntax.self) {
            return normalizedTypeName(from: memberAccess.declName.baseName.text)
        }

        return nil
    }

    private static func closureReturnTypeName(from closure: ClosureExprSyntax) -> String? {
        for statement in closure.statements {
            if let expression = statement.item.as(ExprSyntax.self),
               let functionCall = expression.as(FunctionCallExprSyntax.self),
               let typeName = calledTypeName(from: functionCall.calledExpression) {
                return typeName
            }

            if let returnStatement = statement.item.as(ReturnStmtSyntax.self),
               let expression = returnStatement.expression,
               let functionCall = expression.as(FunctionCallExprSyntax.self),
               let typeName = calledTypeName(from: functionCall.calledExpression) {
                return typeName
            }
        }

        return nil
    }

    private static func extractCollectionItemType(from rawTypeName: String) -> String? {
        let compact = String(rawTypeName.filter { !$0.isWhitespace })

        guard let genericStart = compact.firstIndex(of: "<"),
              let genericEnd = compact.lastIndex(of: ">"),
              genericStart < genericEnd else {
            return nil
        }

        let baseName = String(compact[..<genericStart])
        guard normalizedTypeName(from: baseName) == "SAFormCollection" else {
            return nil
        }

        let genericBody = String(compact[compact.index(after: genericStart)..<genericEnd])
        let itemRawName = firstGenericArgument(in: genericBody)
        let itemType = normalizedTypeName(from: itemRawName)

        return itemType.isEmpty ? nil : itemType
    }

    private static func firstGenericArgument(in genericBody: String) -> String {
        var depth = 0
        var result = ""

        for character in genericBody {
            if character == "<" {
                depth += 1
                result.append(character)
                continue
            }

            if character == ">" {
                depth -= 1
                result.append(character)
                continue
            }

            if character == "," && depth == 0 {
                break
            }

            result.append(character)
        }

        return result
    }

    private static func normalizedTypeName(from rawTypeName: String) -> String {
        var typeName = String(rawTypeName.filter { !$0.isWhitespace })

        if typeName.hasPrefix("any"), typeName.count > 3 {
            typeName.removeFirst(3)
        }

        if typeName.hasPrefix("some"), typeName.count > 4 {
            typeName.removeFirst(4)
        }

        while typeName.hasSuffix("?") || typeName.hasSuffix("!") {
            typeName.removeLast()
        }

        if let genericStart = typeName.firstIndex(of: "<") {
            typeName = String(typeName[..<genericStart])
        }

        if let dot = typeName.lastIndex(of: ".") {
            typeName = String(typeName[typeName.index(after: dot)...])
        }

        return typeName
    }
}

@main
struct SAFormMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        SAForm.self
    ]
}
