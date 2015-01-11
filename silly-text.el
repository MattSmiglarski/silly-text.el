;;; silly-text.el -- Modify text with silly, obscure Unicode.
;;;
;;; Commentary:
;;;
;;; Support flip and widen.
;;;
;;; Flip changes "foo bar" to "ɹɐq ooɟ".
;;; Widen changes "foo bar" to "ｆｏｏ ｂａｒ".
;;;
;;; Assumes UTF-8.
;;;
;;; Usage:
;;;
;;; (flip-string "The message to be flipped") ;; => ""pǝddᴉlɟ ǝb oʇ ǝƃɐssǝɯ ǝɥ┴"
;;; M-x flip-buffer RET
;;; M-x flip-region RET
;;;
;;; Similar functions exist for widen-*.
;;;

;;; Code:

(defvar flip-alist
  '(("a" . "ɐ")
    ("b" . "q")
    ("c" . "ɔ")
    ("d" . "p")
    ("e" . "ǝ")
    ("f" . "ɟ")
    ("g" . "ƃ")
    ("h" . "ɥ")
    ("i" . "ᴉ")
    ("j" . "ɾ")
    ("k" . "ʞ")
    ("m" . "ɯ")
    ("n" . "u")
    ("r" . "ɹ")
    ("t" . "ʇ")
    ("v" . "ʌ")
    ("w" . "ʍ")
    ("y" . "ʎ")
    ("A" . "∀")
    ("B" . "q")
    ("C" . "Ɔ")
    ("D" . "p")
    ("E" . "Ǝ")
    ("F" . "Ⅎ")
    ("G" . "פ")
    ("J" . "ſ")
    ("L" . "˥")
    ("M" . "W")
    ("P" . "Ԁ")
    ("R" . "ɹ")
    ("T" . "┴")
    ("U" . "∩")
    ("V" . "Λ")
    ("Y" . "⅄")
    ("1" . "Ɩ")
    ("2" . "ᄅ")
    ("3" . "Ɛ")
    ("4" . "ㄣ")
    ("5" . "ϛ")
    ("6" . "9")
    ("7" . "ㄥ")
    ("8" . "8")
    ("," . "'")
    ("." . "˙")
    ("?" . "¿")
    ("!" . "¡")
    ("\"" . ",")
    ("'" . ",")
    ("`" . ",")
    ("'" . ",")
    ("(" . ")")
    (")" . "(")
    ("[" . "]")
    ("]" . "[")
    ("{" . "}")
    ("<" . ">")
    (">" . "<")
    ("&" . "⅋")
    ("_" . "‾")
    "An alist for flipping characters."))

(defvar widen-alist
  '(("!" . "！")
    ("\"" . "＂")
    ("#" . "＃")
    ("$" . "＄")
    ("%" . "％")
    ("&" . "＆")
    ("'" . "＇")
    ("(" . "（")
    (")" . "）")
    ("*" . "＊")
    ("+" . "＋")
    ("," . "，")
    ("-" . "－")
    ("." . "．")
    ("/" . "／")
    ("0" . "０")
    ("1" . "１")
    ("2" . "２")
    ("3" . "３")
    ("4" . "４")
    ("5" . "５")
    ("6" . "６")
    ("7" . "７")
    ("8" . "８")
    ("9" . "９")
    (":" . "：")
    (";" . "；")
    ("<" . "＜")
    ("=" . "＝")
    (">" . "＞")
    ("?" . "？")
    ("@" . "＠")
    ("A" . "Ａ")
    ("B" . "Ｂ")
    ("C" . "Ｃ")
    ("D" . "Ｄ")
    ("E" . "Ｅ")
    ("F" . "Ｆ")
    ("G" . "Ｇ")
    ("H" . "Ｈ")
    ("I" . "Ｉ")
    ("J" . "Ｊ")
    ("K" . "Ｋ")
    ("L" . "Ｌ")
    ("M" . "Ｍ")
    ("N" . "Ｎ")
    ("O" . "Ｏ")
    ("P" . "Ｐ")
    ("Q" . "Ｑ")
    ("R" . "Ｒ")
    ("S" . "Ｓ")
    ("T" . "Ｔ")
    ("U" . "Ｕ")
    ("V" . "Ｖ")
    ("W" . "Ｗ")
    ("X" . "Ｘ")
    ("Y" . "Ｙ")
    ("[" . "Ｚ")
    ("\\" . "［")
    ("]" . "＼")
    ("^" . "］")
    ("_" . "＾")
    ("`" . "＿")
    ("^" . "＾")
    ("_" . "＿")
    ("`" . "｀")
    ("a" . "ａ")
    ("b" . "ｂ")
    ("c" . "ｃ")
    ("d" . "ｄ")
    ("e" . "ｅ")
    ("f" . "ｆ")
    ("g" . "ｇ")
    ("h" . "ｈ")
    ("i" . "ｉ")
    ("j" . "ｊ")
    ("k" . "ｋ")
    ("l" . "ｌ")
    ("m" . "ｍ")
    ("n" . "ｎ")
    ("o" . "ｏ")
    ("p" . "ｐ")
    ("q" . "ｑ")
    ("r" . "ｒ")
    ("s" . "ｓ")
    ("t" . "ｔ")
    ("u" . "ｕ")
    ("v" . "ｖ")
    ("w" . "ｗ")
    ("x" . "ｘ")
    ("y" . "ｙ")
    ("z" . "ｚ")
    ("{" . "｛")
    ("|" . "｜")
    ("}" . "｝")
    ("~" . "～")
    "An alist for widening characters."))

(defun flip-string (string)
  "Flips STRING upside down."
  (interactive "M")
  (apply #'concat
         (reverse
          (mapcar (lambda (x)
                    (or (cdr (assoc (char-to-string x) flip-alist))
                        (car (rassoc (char-to-string x) flip-alist))
                        (char-to-string x)))
                  (string-to-list string)))))

(defun flip-region (start end)
  "Flips the contents between START and END."
  (interactive "*r")
  (let ((text (buffer-substring start end)))
    (delete-region start end)
    (insert (flip-string text))))

(defun flip-buffer (buffer)
  "Flips the contents of BUFFER."
  (interactive "*b")
  (with-current-buffer buffer
    (flip-region (point-min) (point-max))))

(defun widenize-string (string)
  "Widen the contents of STRING."
  (interactive "M")
  (apply #'concat
         (mapcar (lambda (x)
                   (or (cdr (assoc (char-to-string x) widen-alist))
                       (char-to-string x)))
                 (string-to-list string))))

(defun widenize-region (start end)
  "Widen the contents between START and END."
  (interactive "*r")
  (let ((text (buffer-substring start end)))
    (delete-region start end)
    (insert (widenize-string text))))

(defun widenize-buffer (buffer)
  "Widen the contents of BUFFER."
  (interactive "*b")
  (with-current-buffer buffer
    (widenize-region (point-min) (point-max))))

(provide 'silly-text)
;;; silly-text.el ends here
