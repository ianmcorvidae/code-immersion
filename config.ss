#lang scheme
(provide reread-config config-file SERVER DAEMON SERVER-PORT DAEMON-PORT NAME FORMAT-STRING DATASTORE-TYPE)
(define config-file (string-append (path->string (find-system-path 'pref-dir)) "code-immersion.config"))
(define read-config  (lambda ((configuration-file config-file)) 
                       (if (file-exists? configuration-file)
                           (call-with-input-file configuration-file
                             (lambda (in) (read in)) 
                             #:mode 'text)
                           null)))
(define default '((SERVER "localhost")
                  (DAEMON "localhost")
                  (SERVER-PORT 2000)
                  (DAEMON-PORT 2005)
                  (NAME "Unconfigured Name")
                  (FORMAT-STRING "~a from ~a: ~a~n")
                  (DATASTORE-TYPE "hash-datastore")))
(define config (read-config))
(define reread-config 
  (lambda ((configuration-file config-file)) (set! config (read-config configuration-file))))
(define SERVER 
  (lambda () (second (or (assoc 'SERVER config) (assoc 'SERVER default)))))
(define DAEMON 
  (lambda () (second (or (assoc 'DAEMON config) (assoc 'DAEMON default)))))
(define SERVER-PORT 
  (lambda () (second (or (assoc 'SERVER-PORT config) (assoc 'SERVER-PORT default)))))
(define DAEMON-PORT 
  (lambda () (second (or (assoc 'DAEMON-PORT config) (assoc 'DAEMON-PORT default)))))
(define NAME 
  (lambda () (second (or (assoc 'NAME config) (assoc 'NAME default)))))
(define FORMAT-STRING 
  (lambda () (second (or (assoc 'FORMAT-STRING config) (assoc 'FORMAT-STRING default)))))
(define DATASTORE-TYPE 
  (lambda () (second (or (assoc 'DATASTORE-TYPE config) (assoc 'DATASTORE-TYPE default)))))
