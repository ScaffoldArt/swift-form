//
//  FormCraftMacros.swift
//  form-craft
//
//  Created by Артем Дробышев on 01.02.2026.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

public struct FormCraft: MemberMacro {
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
       let accessPaths = uniquePreservingOrder(
           collectAccessPaths(
               in: structDecl,
               prefix: [],
               nestedStructsByName: nestedStructsByName,
               visitedStructNames: [structName]
           )
       )

       let mapperString = accessPaths.map { "\"\($0)\": \\.\($0)" }.joined(separator: ", ")
       let orderString = accessPaths.map { "\"\($0)\"" }.joined(separator: ", ")

       return [
           """
           private static var _formCraftAccessNamesCache: [String: PartialKeyPath<\(raw: structName)>]?

           func getAccessNames() -> [String: PartialKeyPath<\(raw: structName)>] {
               if let cache = Self._formCraftAccessNamesCache {
                   return cache
               }

               let all: [String: PartialKeyPath<\(raw: structName)>] = [\(raw: mapperString)]
               let filtered: [String: PartialKeyPath<\(raw: structName)>] = Dictionary(
                   uniqueKeysWithValues: all.compactMap { (name, keyPath) -> (String, PartialKeyPath<\(raw: structName)>)? in
                       guard self[keyPath: keyPath] is any FormCraftFieldConfigurable else {
                           return nil
                       }

                       return (name, keyPath)
                   }
               )

               Self._formCraftAccessNamesCache = filtered
               return filtered
           }

           func getAccessOrder() -> [String] {
               let accessNames = getAccessNames()
               let ordered = [\(raw: orderString)]
               return ordered.filter { accessNames[$0] != nil }
           }
           """
       ]
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

    private static func collectAccessPaths(
        in structDecl: StructDeclSyntax,
        prefix: [String],
        nestedStructsByName: [String: StructDeclSyntax],
        visitedStructNames: Set<String>
    ) -> [String] {
        var accessPaths: [String] = []

        for member in structDecl.memberBlock.members {
            guard let variable = member.decl.as(VariableDeclSyntax.self), !isStaticOrClass(variable) else {
                continue
            }

            for binding in variable.bindings {
                guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    continue
                }

                let propertyName = identifier.identifier.text
                let currentPath = prefix + [propertyName]
                let currentPathString = currentPath.joined(separator: ".")

                guard let referencedType = referencedTypeName(for: binding),
                      let referencedStruct = nestedStructsByName[referencedType],
                      isGroupStruct(referencedStruct),
                      !visitedStructNames.contains(referencedType) else {
                    accessPaths.append(currentPathString)
                    continue
                }

                let nestedPaths = collectAccessPaths(
                    in: referencedStruct,
                    prefix: currentPath,
                    nestedStructsByName: nestedStructsByName,
                    visitedStructNames: visitedStructNames.union([referencedType])
                )

                if nestedPaths.isEmpty {
                    accessPaths.append(currentPathString)
                } else {
                    accessPaths.append(contentsOf: nestedPaths)
                }
            }
        }

        return accessPaths
    }

    private static func isStaticOrClass(_ variable: VariableDeclSyntax) -> Bool {
        variable.modifiers.contains { modifier in
            let tokenKind = modifier.name.tokenKind
            return tokenKind == .keyword(.static) || tokenKind == .keyword(.class)
        }
    }

    private static func isGroupStruct(_ structDecl: StructDeclSyntax) -> Bool {
        guard let inheritanceClause = structDecl.inheritanceClause else {
            return false
        }

        for inheritedType in inheritanceClause.inheritedTypes {
            let inheritedTypeName = normalizedTypeName(from: inheritedType.type.trimmedDescription)
            if inheritedTypeName == "FormCraftGroup" {
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

        if let reference = initializer.calledExpression.as(DeclReferenceExprSyntax.self) {
            return reference.baseName.text
        }

        if let memberAccess = initializer.calledExpression.as(MemberAccessExprSyntax.self) {
            return memberAccess.declName.baseName.text
        }

        return nil
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

    private static func uniquePreservingOrder(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []

        for value in values where seen.insert(value).inserted {
            result.append(value)
        }

        return result
    }
}

@main
struct FormCraftMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        FormCraft.self
    ]
}
