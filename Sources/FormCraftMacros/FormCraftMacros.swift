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
       let members = declaration.memberBlock.members
       var propertyNames: [String] = []

       for member in members {
           if let variable = member.decl.as(VariableDeclSyntax.self) {
               let isStaticOrClass = variable.modifiers.contains { modifier in
                   let tokenKind = modifier.name.tokenKind
                   return tokenKind == .keyword(.static) || tokenKind == .keyword(.class)
               }

               if isStaticOrClass {
                   continue
               }

               for binding in variable.bindings {
                   if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                       propertyNames.append(identifier.identifier.text)
                   }
               }
           }
       }

       let mapperString = propertyNames.map { "\"\($0)\": \\.\($0)" }.joined(separator: ", ")

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
           """
       ]
   }
}

@main
struct FormCraftMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [
        FormCraft.self
    ]
}
