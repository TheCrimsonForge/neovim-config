; extends

; Logical operators onto the keyword colour. Full reasoning lives in
; after/queries/typescript/highlights.scm -- keep the three ecma files in sync,
; and see the note there on why each language gets its own file instead of one
; shared `ecma` one.
;
; The unary_expression scoping is redundant in plain JavaScript, which has no
; non-null assertion, but it is kept identical to the TypeScript file so the
; three do not drift.
[
  "&&"
  "||"
  "??"
] @keyword.operator

(unary_expression
  "!" @keyword.operator)

; Object-literal and KEYS, normalised onto one capture.
;
; The base ecma queries file a BARE key as @variable.member and a QUOTED key as
; @string, so `{ Cash: 1, 'Credit Card': 2 }` rendered its two keys in two
; different colours for no reason but the quoting. Both are keys.
;
; This deliberately does NOT touch @variable.member itself: member ACCESS
; (`obj.attr.deep`) and class fields keep that capture and stay on the member
; colour. Only the key position is re-captured, which is why it needs a query
; rather than a highlight override -- the base grammar gives both the same name.
;
; Keep the three ecma files in sync (typescript / tsx / javascript); see the note
; above on why each language needs its own copy rather than inheriting.
(pair
  key: (property_identifier) @variable.member.key)

(pair
  key: (string) @variable.member.key)

(shorthand_property_identifier) @variable.member.key

; No `property_signature` pattern here: that node is TypeScript-only, and an
; unknown node name makes the WHOLE query error out rather than just that
; pattern, which would silently drop this file's operator rules too.

; PascalCase IS NOT A TYPE. The ecma queries capture every capitalised bare
; identifier as @type (`#lua-match? "^[A-Z]"`), so an imported component and a
; plain reference to one rendered in the type colour: `import { ReportMenuCard }`
; and `export default ReportMenu` both read as types when neither is one.
;
; Only the two bare-identifier positions are re-captured. Real types are
; (type_identifier) nodes, not (identifier), so `type CardProps` and `: Plan`
; keep the type colour untouched. JSX usage keeps @tag, and `const Foo = () =>`
; is already caught as @function by the base queries.
;
; Keep the three ecma files in sync (typescript / tsx / javascript); see the note
; at the top of this file on why each language needs its own copy.
(import_specifier
  name: (identifier) @variable)

(export_statement
  value: (identifier) @variable)
