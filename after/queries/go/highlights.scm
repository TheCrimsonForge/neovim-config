; extends

; Logical operators onto the keyword colour, same rule and reasoning as
; after/queries/typescript/highlights.scm.
;
; A bare "!" is safe here where it is not in TypeScript: Go has no non-null
; assertion, `!=` is a single token, and `&&=`/`||=` do not exist in the
; grammar. Matching bare anonymous nodes is also how go/highlights.scm captures
; these tokens itself.
[
  "&&"
  "||"
  "!"
] @keyword.operator

; Struct- and map-literal KEYS, normalised onto the same capture the ecma files
; use, so `member` can be given its own colour without flooding every
; composite literal. Without this, `Cfg{Bar: 1}` files a key as
; @variable.member -- the same capture as `s.Bar` member ACCESS -- and colouring
; that role turned every key in the file the member colour.
;
; Both forms are captured: a bare identifier key (struct fields) and a string
; key (map literals), so the two do not diverge the way they did in TypeScript.
(keyed_element
  key: (literal_element
    (identifier) @variable.member.key))

(keyed_element
  key: (literal_element
    (interpreted_string_literal) @variable.member.key))
