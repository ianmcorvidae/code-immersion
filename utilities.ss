;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2009 Ian McEwen                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This file is part of the Code-Immersion software collaboration framework.    ;
;                                                                             ;
;    Code-Immersion is free software: you can redistribute it and/or modify   ;
;    it under the terms of the GNU Affero General Public License as published ; 
;     by the Free Software Foundation, either version 3 of the License, or    ;
;    (at your option) any later version.                                      ;
;                                                                             ;
;    Code-Immersion is distributed in the hope that it will be useful,        ;
;    but WITHOUT ANY WARRANTY; without even the implied warranty of           ;
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            ;
;    GNU Affero General Public License for more details.                      ;
;                                                                             ;
;    You should have received a copy of the GNU Affero General Public License ;
;    along with Code-Immersion.  If not, see <http://www.gnu.org/licenses/>.  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#lang scheme
(require "config.ss")
(require mzlib/defmacro)
(provide ignoring-errors 
         print-all-source
         format-prettily
         verify-data
         define-listener-and-verifier)
;Data validation function
(define (verify-data data)
  (cond
    [(not (list? data)) #f]
    [(not (eq? (length data) 3)) #f]
    [(and (string? (car data)) (string? (cadr data))) 
     (cond 
       [(equal? (cadr data) "code") 
        #t]
       [(equal? (cadr data) "users") 
        #t]
       [(equal? (cadr data) "text")
        (if (string? (caddr data)) 
            (if (not (string=? (caddr data) "")) #t #f) 
            (if (list? (caddr data)) #t #f))]
       [(equal? (cadr data) "register")
        (if (string? (caddr data)) 
            (if (string=? (caddr data) "") #t #f) 
            #f)]
       [(equal? (cadr data) "source")
        (if (string? (caddr data)) 
            (if (string=? (caddr data) "") #t #f) 
            #f)]
       [else
        (if (string? (caddr data)) #t #f)])]
    [else #f]))
;formatting function for displaying messages/code
(define (format-prettily message #:format-string [format-string (FORMAT-STRING)])
  (let ([name (car message)] [type (cadr message)] [message (caddr message)])
    (display (format format-string type name message))))

;A basic function that runs whatever code you throw at it ignoring every error that 
;said code might have (returning #t). Should probably return a special value to 
;indicate there was an error, but this is unnecessary for now.
(define (ignoring-errors code)
    (with-handlers ([(lambda (exn) #t) (lambda (exn) #t)])
      (eval code)))
;AGPL compliance: making it possible to send source through the application
;create a string from a text file. probably hackish and bad. So shoot me.
(define (string-from-text-file text-file-port)
  (let ([return-string ""])
      (if (eof-object? (peek-string 1 0 text-file-port))
          return-string
          (string-append (read-line text-file-port) "\n" 
                           (string-from-text-file text-file-port)))))
;return a massive string that's all the source files all together
(define (print-all-source)
  (let ([utilities (open-input-file "utilities.ss" #:mode 'text)]
        [server (open-input-file "server.ss" #:mode 'text)]
        [client (open-input-file "client.ss" #:mode 'text)]
        [daemon (open-input-file "daemon.ss" #:mode 'text)]
        [datastore (open-input-file "datastore.ss" #:mode 'text)]
        [config-example (open-input-file "config-example.ss" #:mode 'text)]
        [copying (open-input-file "COPYING" #:mode 'text)])
    (string-append "UTILITIES.SS:\n\n" (string-from-text-file utilities) "\n\n" 
                   "DATASTORE.SS:\n\n" (string-from-text-file datastore) "\n\n"
                   "SERVER.SS:\n\n" (string-from-text-file server) "\n\n" 
                   "DAEMON.SS:\n\n" (string-from-text-file daemon) "\n\n"
                   "CLIENT.SS:\n\n" (string-from-text-file client) "\n\n"
                   "CONFIG-EXAMPLE.SS:\n\n" (string-from-text-file config-example) "\n\n"
                   "COPYING:\n\n" (string-from-text-file copying))))
;server/daemon macro!
(define-macro (define-listener-and-verifier port close? body)
  `(let ([listener (tcp-listen ,port)])
     ;So it keeps going, and going, and going...
     (with-handlers (((lambda (exn) #t) (lambda (exn)
                                          (tcp-close listener) (kill-thread (current-thread)))))
       (let loop ()
         (let-values ([(client->me me->client)
                       (tcp-accept listener)])
           (with-handlers (((lambda (exn) #t) (lambda (exn) (close-input-port client->me) (close-output-port me->client) (raise exn))))
             ;Reading the s-expression that should have been sent by a client, 
             ;verifying it, then processing it based on the type
             (let ([data (read client->me)])  
               (if (verify-data data) 
                   (let ([name (car data)]
                         [type (cadr data)]
                         [message (caddr data)])
                     ;Check what exactly they want with a cond over (eq? type ...)
                     (cond
                       ,@body))
                   (begin 
                     (write '("server" "text" "Malformed data was ignored.") me->client)
                     (close-output-port me->client))))
             ;Whoops, we don't want this closed sometimes!
             ,(when close? '(close-output-port me->client))
             (close-input-port client->me))
           (loop))))))
