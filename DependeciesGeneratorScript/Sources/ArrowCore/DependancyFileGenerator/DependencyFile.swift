import Foundation
import SwiftSyntax

class DependencyFile {
    private let presenter: FilePresenter
    
    init(_ presenter: FilePresenter) {
        self.presenter = presenter
    }
    
    private let colon = SyntaxFactory.makeColonToken(trailingTrivia: .spaces(1))
    private let leftBrace = SyntaxFactory.makeLeftBraceToken(trailingTrivia: .newlines(1))
    private let rightBrace = SyntaxFactory.makeRightBraceToken(leadingTrivia: .newlines(1))
    private let leftParen = SyntaxFactory.makeLeftParenToken()
    private let rightParen = SyntaxFactory.makeRightParenToken()
    private let comma = SyntaxFactory.makeCommaToken(trailingTrivia: .spaces(1))
    
    /*
     import UIKit
     import Arrow
     
     extension Container {
        func resgister() {
            self.register(Type.self, name: "Type") { a, b in
                Type(a: a, b: b)
            }
     
            self.register(Type.self, name: "Type") { a, b in
                Type(a: a, b: b)
            }
        }
     }
     */
    lazy var file = SourceFileSyntax { builder in
        builder.addStatement(SyntaxFactory.makeCodeBlockItem(
            item: Syntax(importUIKitDecl),
            semicolon: nil,
            errorTokens: nil))
        builder.addStatement(SyntaxFactory.makeCodeBlockItem(
            item: Syntax(importArrowDecl),
            semicolon: nil,
            errorTokens: nil))
        presenter.getImports().map(importDecl).forEach {
            builder.addStatement(SyntaxFactory.makeCodeBlockItem(
                item: Syntax($0),
                semicolon: nil,
                errorTokens: nil))
        }
        builder.addStatement(CodeBlockItemSyntax { builder in
            builder.useItem(Syntax(extensionDecl))
        })
    }
    
    /*
     import UIKit
     */
    private lazy var importUIKitDecl = ImportDeclSyntax { builder in
        builder.useImportTok(SyntaxFactory.makeImportKeyword(trailingTrivia: .spaces(1)))
        builder.addPathComponent(AccessPathComponentSyntax { builder in
            builder.useName(SyntaxFactory.makeUnknown("UIKit", trailingTrivia: .newlines(1)))
        })
    }
    
    /*
     import Arrow
     */
    private lazy var importArrowDecl = ImportDeclSyntax { builder in
        builder.useImportTok(SyntaxFactory.makeImportKeyword(trailingTrivia: .spaces(1)))
        builder.addPathComponent(AccessPathComponentSyntax { builder in
            //replace with Arrow
            builder.useName(SyntaxFactory.makeUnknown("Swinject", trailingTrivia: .newlines(1)))
        })
    }
    
    /*
     import ...
     */
    private func importDecl(_ moduleName: String) -> ImportDeclSyntax {
        ImportDeclSyntax { builder in
            builder.useImportTok(SyntaxFactory.makeImportKeyword(trailingTrivia: .spaces(1)))
            builder.addPathComponent(AccessPathComponentSyntax { builder in
                //replace with Arrow
                builder.useName(SyntaxFactory.makeUnknown(moduleName, trailingTrivia: .newlines(1)))
            })
        }
    }
    
    /*
     extension Container {

     }
     */
    private lazy var extensionDecl = ExtensionDeclSyntax { builder in
        builder.useExtensionKeyword(SyntaxFactory.makeExtensionKeyword(leadingTrivia: .newlines(1), trailingTrivia: .spaces(1)))
        builder.useExtendedType(SyntaxFactory.makeTypeIdentifier("Container", trailingTrivia: .spaces(1)))
        builder.useMembers(SyntaxFactory.makeMemberDeclBlock(
            leftBrace: leftBrace,
            members: SyntaxFactory.makeMemberDeclList([SyntaxFactory.makeMemberDeclListItem(
                decl: DeclSyntax(funcDecl),
                semicolon: nil)]),
            rightBrace: rightBrace))
    }
    
    /*
     func register() {
         
     }
     */
    private lazy var funcDecl = FunctionDeclSyntax { builder in
        builder.useFuncKeyword(SyntaxFactory.makeFuncKeyword(trailingTrivia: .spaces(1)))
        builder.useIdentifier(SyntaxFactory.makeIdentifier("register"))
        builder.useSignature(SyntaxFactory.makeFunctionSignature(
            input: SyntaxFactory.makeParameterClause(
                leftParen: leftParen,
                parameterList: SyntaxFactory.makeBlankFunctionParameterList(),
                rightParen: SyntaxFactory.makeRightParenToken(trailingTrivia: .spaces(1))),
            asyncOrReasyncKeyword: nil,
            throwsOrRethrowsKeyword: nil,
            output: nil))
        builder.useBody(SyntaxFactory.makeCodeBlock(
            leftBrace: SyntaxFactory.makeLeftBraceToken(trailingTrivia: .newlines(1)),
            statements: SyntaxFactory.makeCodeBlockItemList(presenter.getObjects().map(map)),
            rightBrace: SyntaxFactory.makeRightBraceToken(leadingTrivia: .spaces(4))))
    }.withLeadingTrivia(.spaces(4))
    
    /*
     self.register(Type.self, name: "Type") { a, b in
         Type(a: a, b: b)
     }
     */
    private func map(_ object: Object) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax{ builder in
            builder.useItem(
                Syntax(FunctionCallExprSyntax { builder in
                    builder.useCalledExpression(ExprSyntax(SyntaxFactory.makeMemberAccessExpr(
                        base: ExprSyntax(SyntaxFactory.makeIdentifierExpr(
                            identifier: SyntaxFactory.makeSelfKeyword(),
                            declNameArguments: nil)),
                        dot: SyntaxFactory.makePeriodToken(),
                        name: SyntaxFactory.makeIdentifier("register"),
                        declNameArguments: nil)))
                    builder.useLeftParen(leftParen)
                    builder.addArgument(SyntaxFactory.makeTupleExprElement(
                        label: nil,
                        colon: nil,
                        expression: ExprSyntax(SyntaxFactory.makeMemberAccessExpr(
                            base: ExprSyntax(SyntaxFactory.makeIdentifierExpr(
                                identifier: SyntaxFactory.makeIdentifier(object.type),
                                declNameArguments: nil)),
                            dot: SyntaxFactory.makePeriodToken(),
                            name: SyntaxFactory.makeSelfKeyword(),
                            declNameArguments: nil)),
                        trailingComma: comma))
                    builder.addArgument(SyntaxFactory.makeTupleExprElement(
                        label: SyntaxFactory.makeIdentifier("name"),
                        colon: SyntaxFactory.makeColonToken(trailingTrivia: .spaces(1)),
                        expression: ExprSyntax(SyntaxFactory.makeStringLiteralExpr(object.name)),
                        trailingComma: nil))
                    builder.useRightParen(SyntaxFactory.makeRightParenToken(trailingTrivia: .spaces(1)))
                    builder.useTrailingClosure(SyntaxFactory.makeClosureExpr(
                        leftBrace: SyntaxFactory.makeLeftBraceToken(trailingTrivia: .spaces(1)),
                        signature: SyntaxFactory.makeClosureSignature(
                            attributes: nil,
                            capture: nil,
                            input: Syntax(SyntaxFactory.makeClosureParamList(object.args.map(map))),
                            asyncKeyword: nil,
                            throwsTok: nil,
                            output: nil,
                            inTok: SyntaxFactory.makeInKeyword(leadingTrivia: .spaces(1), trailingTrivia: .newlines(1))),
                        statements: SyntaxFactory.makeCodeBlockItemList(createStatements(object)),
                        rightBrace: SyntaxFactory.makeRightBraceToken(trailingTrivia: .newlines(2))))
                }.withLeadingTrivia(.spaces(8)))
            )
        }
    }
    
    /*
     a, b
     */
    private func map(_ arg: Arg) -> ClosureParamSyntax {
        SyntaxFactory.makeClosureParam(
            name: SyntaxFactory.makeIdentifier(arg.name!),
            trailingComma: arg.comma ? nil : comma)
    }
    
    /*
     Type(a: a, b: b)
     */
    private func createStatements(_ object: Object) -> [CodeBlockItemSyntax] {
        [
            CodeBlockItemSyntax { builder in
                builder.useItem(Syntax(SyntaxFactory.makeFunctionCallExpr(
                    calledExpression: ExprSyntax(SyntaxFactory.makeIdentifierExpr(
                        identifier: SyntaxFactory.makeIdentifier(object.type),
                        declNameArguments: nil)),
                    leftParen: leftParen,
                    argumentList: SyntaxFactory.makeTupleExprElementList(object.args.map(map)),
                    rightParen: SyntaxFactory.makeRightParenToken(trailingTrivia: .newlines(1).appending(.spaces(8))),
                    trailingClosure: nil,
                    additionalTrailingClosures: nil)))
            }.withLeadingTrivia(.spaces(12))
        ]
    }
    
    /*
     (a: a, b: b)
     */
    private func map(_ arg: Arg) -> TupleExprElementSyntax {
        SyntaxFactory.makeTupleExprElement(
            label: arg.name == nil ? nil : SyntaxFactory.makeIdentifier(arg.name!),
            colon: arg.name == nil ? nil : colon,
            expression: ExprSyntax(SyntaxFactory.makeIdentifierExpr(
                identifier: SyntaxFactory.makeIdentifier(arg.name!),
                declNameArguments: nil)),
            trailingComma: arg.comma ? nil : comma)
    }
}
