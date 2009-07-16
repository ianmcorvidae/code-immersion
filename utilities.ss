#lang scheme
(require mzlib/string)
(provide ignoring-errors)
(define (ignoring-errors input-string)
    (with-handlers ([(lambda (exn) #t) (lambda (exn) #t)])
      (eval (read-from-string input-string))))
