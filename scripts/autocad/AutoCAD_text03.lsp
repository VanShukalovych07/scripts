(defun c:RANDTHK (/ orig ss i ent obj rand newval scaled whole decimal txt)

  ;; Ask for original thickness
  (setq orig (getreal "\nEnter original thickness: "))

  (if orig
    (progn

      ;; Select TEXT and MTEXT
      (setq ss (ssget '((0 . "TEXT,MTEXT"))))

      (if ss
        (progn

          (setq i 0)

          (while (< i (sslength ss))

            (setq ent (ssname ss i))
            (setq obj (entget ent))

            ;; Random number: 0, 1, 2 or 3
            (setq rand
              (rem (+ (getvar "MILLISECS") i) 4)
            )

            ;; Original minus 0.0 - 0.3
            (setq newval
              (- orig (* rand 0.1))
            )

            ;; Convert to tenths and round
            (setq scaled
              (fix (+ (* newval 10.0) 0.5))
            )

            ;; Get whole number
            (setq whole
              (fix (/ scaled 10))
            )

            ;; Get decimal digit
            (setq decimal
              (- scaled (* whole 10))
            )

            ;; Create text with ALWAYS one decimal
            (setq txt
              (strcat
                (itoa whole)
                "."
                (itoa decimal)
              )
            )

            ;; Replace original text
            (setq obj
              (subst
                (cons 1 txt)
                (assoc 1 obj)
                obj
              )
            )

            (entmod obj)

            (setq i (1+ i))
          )

          (princ
            "\nRandom thickness completed."
          )
        )

        (princ
          "\nNo TEXT or MTEXT selected."
        )
      )
    )

    (princ
      "\nNo original thickness entered."
    )
  )

  (princ)
)