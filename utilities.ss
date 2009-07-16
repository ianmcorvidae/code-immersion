#lang scheme
(require mzlib/string)
(provide ignoring-errors run-and-print-with-label)
(define (ignoring-errors input-string)
    (with-handlers ([(lambda (exn) #t) (lambda (exn) #t)])
      (eval (read-from-string input-string))))
(define (run-and-print-with-label label-string code-string) 
  (display label-string) (display ":\t") (display code-string) (display "\n")
  (ignoring-errors code-string) (display "\n"))
