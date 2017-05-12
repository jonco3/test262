// This file was procedurally generated from the following sources:
// - src/declarations/redeclare-with-let-declaration.case
// - src/declarations/redeclare/block-attempt-to-redeclare-async-function-declaration.template
/*---
description: redeclaration with let-LexicalDeclaration (AsyncFunctionDeclaration in BlockStatement)
esid: sec-block-static-semantics-early-errors
flags: [generated, async-functions]
negative:
  phase: early
  type: SyntaxError
info: |
    Block : { StatementList }

    It is a Syntax Error if the LexicallyDeclaredNames of StatementList contains
    any duplicate entries.

---*/


{ async function f() {} let f; }