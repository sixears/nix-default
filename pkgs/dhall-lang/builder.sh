$coreutils/bin/mkdir -p $out/share
$coreutils/bin/cp -av $src/ $out/share/dhall-lang/
$coreutils/bin/chmod u+w $out/share/dhall-lang
p="$out/share/dhall-lang/Prelude"
$coreutils/bin/cat <<EOF > $out/share/dhall-lang/prelude
    let concat  = ${p}/List/concat
 in let concatT = ${p}/Text/concat
 in let map     = ${p}/List/map
 in let toList  = ${p}/Optional/toList
 in let catMaybes 
            : ∀(a : Type) → ∀(xs : List (Optional a)) → List a
                  = λ(a : Type)
                  → λ(xs : List (Optional a))
                  → concat a (map (Optional a)
                                  (List a) (toList a) xs)
 in let unlines : List Text → Text
                = λ(ls : List Text)
                → concatT (map Text Text 
                          (λ(l : Text) → l ++ "\n") ls)
 in { catMaybes    = catMaybes
    , concat       = concat
    , concatT      = concatT
    , intercalateT = ${p}/Text/concatSep
    , map          = map
    , nullT        = ${p}/Optional/null Text
    , maybe        = ${p}/Optional/fold
    , omap         = ${p}/Optional/map
    , unlines      = unlines
    }
EOF
