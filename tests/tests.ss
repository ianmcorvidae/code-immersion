#lang scheme/base

(require (planet schematics/schemeunit:3)
         (planet schematics/schemeunit:3/text-ui)
         "../client.ss"
         "../daemon.ss"
         "../server.ss"
         "../utilities.ss"
         "../datastore.ss"
         "../config.ss")

(require/expose "../config.ss" (read-config))

(define tests
  (list
   (test-suite
    "Tests for client.ss")
   
   (test-suite
    "Tests for daemon.ss")
   
   (test-suite
    "Tests for server.ss")
   
   (test-suite
    "Tests for utilities.ss")
   
   (test-suite
    "Tests for datastore.ss")
   
   (test-suite
    "Tests for config.ss"
    (test-case "config-file is proper"
               (check-equal? config-file (string-append (path->string (find-system-path 'pref-dir)) "code-immersion.config")))
    (test-case "read-config default"
               (check-equal? (read-config) (read-config config-file)))
    (test-case "read-config null"
               (check-equal? (read-config "/") '()))
    (test-case "read-config test.config"
               (check-equal? (read-config "test.config") '((NAME "aoeuidhtns")
                                                           (SERVER "foobar")
                                                           (DAEMON "barfoo")
                                                           (SERVER-PORT 5243)
                                                           (DAEMON-PORT 4578)
                                                           (FORMAT-STRING "~a ~a ~a")
                                                           (DATASTORE-TYPE "null-datastore"))))
    (test-case "Default values"
               (reread-config "/")
               (check-equal? (NAME) "Unconfigured Name")
               (check-equal? (SERVER) "localhost")
               (check-equal? (DAEMON) "localhost")
               (check-equal? (SERVER-PORT) 2000)
               (check-equal? (DAEMON-PORT) 2005)
               (check-equal? (FORMAT-STRING) "~a from ~a: ~a~n")
               (check-equal? (DATASTORE-TYPE) "hash-datastore"))
    (test-case "test.config values"
               (reread-config "test.config")
               (check-equal? (NAME) "aoeuidhtns")
               (check-equal? (SERVER) "foobar")
               (check-equal? (DAEMON) "barfoo")
               (check-equal? (SERVER-PORT) 5243)
               (check-equal? (DAEMON-PORT) 4578)
               (check-equal? (FORMAT-STRING) "~a ~a ~a")
               (check-equal? (DATASTORE-TYPE) "null-datastore")))))


(for-each 
 (lambda (test) ;(printf "~a~n" (vector-ref (struct->vector test) 2)) 
   (run-tests test 'verbose)) 
 tests)
