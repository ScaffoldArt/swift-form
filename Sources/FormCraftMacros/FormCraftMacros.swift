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
           func getAccessNames() -> [String: PartialKeyPath<\(raw: structName)>] {
               [\(raw: mapperString)]
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
