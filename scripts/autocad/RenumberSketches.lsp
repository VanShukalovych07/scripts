;;; ============================================================
;;;  RenumberSketches.lsp  (simple version)
;;;
;;;  Select the sketch texts (window or pick), then they are
;;;  sorted left-to-right, top-to-bottom, starting from the number
;;;  you choose. Everything after "Sketch:" (or "From Sketch:")
;;;  is replaced with just the number.
;;;
;;;  Load:  APPLOAD -> RenumberSketches.lsp
;;;  Run:   type  RenumberSketches
;;; ============================================================

(vl-load-com)

(defun _rs-is-sketch (txt)
  (and txt (wcmatch (strcase txt) "*SKETCH*"))
)

(defun _rs-layer-locked-p (ent / lay ld)
  (setq lay (cdr (assoc 8 (entget ent))))
  (setq ld (tblsearch "LAYER" lay))
  (and ld (/= (logand (cdr (assoc 70 ld)) 4) 0))
)

(defun _rs-renumber-text (s n / upper pos colonPos prefix)
  ;; Find "SKETCH" in the text, keep everything up to the colon
  ;; (or up to "Sketch" if no colon), then append " " + number.
  (setq upper (strcase s))
  (setq pos (vl-string-search "SKETCH" upper))
  (if pos
    (progn
      (setq colonPos (vl-string-search ":" s pos))
      (if colonPos
        (setq prefix (substr s 1 (+ colonPos 1)))
        (setq prefix (substr s 1 (+ pos 6)))
      )
      ;; Trim trailing spaces from prefix
      (while (and (> (strlen prefix) 0)
                  (= (ascii (substr prefix (strlen prefix) 1)) 32))
        (setq prefix (substr prefix 1 (1- (strlen prefix))))
      )
      (strcat prefix " " (itoa n))
    )
    (strcat s " " (itoa n))
  )
)

(defun c:RenumberSketches ( / ss i ent txt pt lst count newtxt tol abort)
  (vl-load-com)
  (princ "\n=== Renumber Sketches (Left to Right) ===")
  (princ "\nSelect sketch texts (window or pick). Press Enter when done.")

  (setq abort nil)
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (null ss)
    (progn
      (princ "\nNo selection.")
      (setq abort T)
    )
  )

  (if (not abort)
    (progn
      (setq i 0 lst '())
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq txt (cdr (assoc 1 (entget ent))))
        (if (_rs-is-sketch txt)
          (progn
            (setq pt (cdr (assoc 10 (entget ent))))
            (setq lst (cons (list ent txt pt) lst))
          )
        )
        (setq i (1+ i))
      )
      (setq lst (reverse lst))
      (if (null lst)
        (progn
          (princ "\nNo sketch texts in selection.")
          (setq abort T)
        )
      )
    )
  )

  (if (not abort)
    (progn
      (princ (strcat "\nFound " (itoa (length lst)) " sketch text(s)."))
      ;; Sort left-to-right, then top-to-bottom
      (setq lst (vl-sort lst (function (lambda (a b)
        (if (equal (car (caddr a)) (car (caddr b)) 0.001)
          (> (cadr (caddr a)) (cadr (caddr b)))
          (< (car (caddr a)) (car (caddr b)))
        )
      ))))

      (setq i 1)
      (foreach item lst
        (princ (strcat (itoa i) ". " (cadr item) "\n"))
        (setq i (1+ i))
      )

      (setq startNum (getint "\nStarting number <1>: "))
      (if (null startNum) (setq startNum 1))
      (setq count startNum)
      (foreach item lst
        (setq ent (car item))
        (setq txt (cadr item))
        (if (_rs-layer-locked-p ent)
          (princ (strcat "\n  Skipped (locked layer): " txt))
          (progn
            (setq newtxt (_rs-renumber-text txt count))
            (entmod (subst (cons 1 newtxt) (assoc 1 (entget ent)) (entget ent)))
            (entupd ent)
            (princ (strcat "\n  " (itoa count) "  " newtxt))
            (setq count (1+ count))
          )
        )
      )
      (princ (strcat "\n\nDone! Renumbered " (itoa (1- count)) " sketch(es)."))
      (command "_.REGEN")
    )
  )

  (princ)
)

(princ "\nRenumberSketches.lsp loaded.")
(princ "\nType  RenumberSketches  to run.")
(princ)
