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
(provide (all-defined-out))
;data storage: hashtable datastore
(define hash-datastore
  (let ([hash-datastore (make-hash)])
    (list
     ;Put
     (lambda (type message)
       (let* ([hash-key (string-append (car message) "-" type)]
              [hash-return-value (hash-ref hash-datastore hash-key #f)]
              [value-to-place (cadr message)])
         (cond
           [(not (list? hash-return-value)) (hash-set! hash-datastore hash-key (list value-to-place))]
           [else (hash-set! hash-datastore hash-key (cons value-to-place hash-return-value))])))
     ;Get
     (lambda (type message)
       (let* ([hash-key (string-append (car message) "-" type)]
              [hash-return-value (hash-ref hash-datastore hash-key #f)]
              [list-index (cadr message)])
         (cond
           [(not (list? hash-return-value)) "invalid"];(format "~a is not a list. The request was: ~a~nThis error is probably because there were no values found." hash-return-value hash-key)]
           [(not (> (length hash-return-value) list-index)) "invalid"]
           [else (list-ref hash-return-value list-index)])))
     ;Users
     (lambda ()
       (hash-map hash-datastore (lambda (key val) (substring key 0 (- (string-length key) 5)))))
     )))
(define null-datastore
  (list (lambda (type message) null) (lambda (type message) null) (lambda () null)))
(define datastores
  `((hash-datastore ,hash-datastore) (null-datastore ,null-datastore)))
(define DATASTORE 
  (cond 
    [(equal? (DATASTORE-TYPE) "hash-datastore")
     hash-datastore]
    [(equal? (DATASTORE-TYPE) "null-datastore")
     null-datastore]
    [else hash-datastore]))
