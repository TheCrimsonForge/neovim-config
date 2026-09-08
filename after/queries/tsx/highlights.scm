; extends

; Logical operators onto the keyword colour. Full reasoning, and why the "!"
; rule is scoped rather than bare, lives in
; after/queries/typescript/highlights.scm -- keep the three ecma files in sync.
;
; Repeated here rather than inherited from typescript or ecma because of query
; precedence: an inherited file is concatenated BEFORE this language's own base
; query, while an `; extends` file named for the language being edited is
; concatenated last and therefore wins. tsx has no operator patterns of its own
; today, but this does not depend on that staying true.
[
  "&&"
  "||"
  "??"
] @keyword.operator

(unary_expression
  "!" @keyword.operator)

; Object-literal and type-literal KEYS, normalised onto one capture.
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

(property_signature
  name: (property_identifier) @variable.member.key)

(property_signature
  name: (string) @variable.member.key)
