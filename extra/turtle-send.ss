#lang scheme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; lee-turtles.ss
;; Lee Spector, lspector@hampshire.edu, 20091026
;; Also Ian McEwen, ihm08@hampshire.edu, 20091109 (changed do-turtle)
;; 	(also made this so it sent stuff instead)
;; 
;; This file implements a small turtle graphics system that was designed to 
;; support exercises in list manipulation. It includes an evaluation function
;; called do-turtles that takes a list of turtle graphics calls and evaluates
;; each of them, producing a drawing in the graphics window. This makes it 
;; convenient to write procedures that manipulate lists of calls to produce
;; more complex lists of calls that can then be passed to do-turtle to create
;; the drawing.
;;
;; After the core definitions (first of the graphics window basics, and then
;; of the turtle graphics code) are some examples of fractal turtle graphics
;; procedures that DO NOT use the technique of producing lists of calls and then
;; passing them to do-turtle -- rather, they draw directly to the window as side
;; effects of their execution. This demonstrates the power of turtle graphics
;; and serves as the basis for exercise #15.
;;
;; After the list of examples is a list of suggested exercises involving list
;; manipulation and do-turtle.
;;
;; User procedures:
;; Graphic window basics:
;;   (show-window) -- shows the window
;;   (clear) -- clears the drawing
;; Turtle graphics calls:
;;   (init-turtle) -- initializes the turtle's position, orientation, etc.
;;   (forward distance) -- moves forward, drawing if the pen is down
;;   (back distance) -- moves back, drawing if the pen is down
;;   (right degrees) -- rotates the turtle right
;;   (left degrees) -- rotates the turtle left
;;   (penup) -- lifts the pen, so it won't draw
;;   (pendown) -- lowers the pen, so it will draw
;;   (setxy x y) -- moves the turtle to location x, y
;;   (setpc r g b a) -- set pen color; 1st 3 args are 0-255 while 4th is 0.0-1.0
;;   (setw w) -- set pen line width
;;   (do-turtle calls) -- execute a list of turtle graphics calls
;; Examples (REMOVED, send separately if wanted):
;;   (tree trunk-length) -- draws a fractal tree
;;   (fern size) -- draws a fractal fern
;;   (color-frond) -- draws a colorful fractal plant-like design
(require "../client.ss")

(sendcode '("all"
            (require scheme/gui/base)
            
            (define x-position (/ width 2))
            (define y-position (- height 50))
            (define angle -90)
            (define pen-down #t)
            (define line-width 1)
            (define red 0)
            (define green 0)
            (define blue 0)
            (define alpha 1.0)
            
            (define init-turtle
              (lambda ()
                (set! x-position (/ width 2))
                (set! y-position (- height 50))
                (set! angle -90)
                (set! pen-down #t)
                (set! line-width 1)
                (set! red 0)
                (set! green 0)
                (set! blue 0)
                (set! alpha 1.0)))
            
            (define degrees->radians
              (lambda (degrees)
                (* 2 pi (/ degrees 360.0))))
            
            (define forward
              (lambda (distance)
                (let ((initial-x-position x-position)
                      (initial-y-position y-position))
                  (set! x-position 
                        (+ x-position (* distance (cos (degrees->radians angle)))))
                  (set! y-position 
                        (+ y-position (* distance (sin (degrees->radians angle)))))
                  (when pen-down
                    (line initial-x-position initial-y-position
                          x-position y-position
                          line-width red green blue alpha)))))
            
            (define back
              (lambda (distance)
                (let ((initial-x-position x-position)
                      (initial-y-position y-position))
                  (set! x-position 
                        (- x-position (* distance (cos (degrees->radians angle)))))
                  (set! y-position 
                        (- y-position (* distance (sin (degrees->radians angle)))))
                  (when pen-down
                    (line initial-x-position initial-y-position
                          x-position y-position
                          line-width red green blue alpha)))))
            
            (define right 
              (lambda (degrees)
                (set! angle (+ angle degrees))
                (when (>= angle 360)
                  (set! angle (- angle 360)))))
            
            (define left 
              (lambda (degrees)
                (set! angle (- angle degrees))
                (when (< angle 0)
                  (set! angle (+ angle 360)))))
            
            (define penup
              (lambda ()
                (set! pen-down #f)))
            
            (define pendown
              (lambda ()
                (set! pen-down #t)))
            
            (define setxy
              (lambda (x y)
                (set! x-position x)
                (set! y-position y)))
            
            (define setpc
              (lambda (r g b a)
                (set! red r)
                (set! green g)
                (set! blue b)
                (set! alpha a)))
            
            (define setw
              (lambda (w)
                (set! line-width w)))
            
            (define do-turtle 
              (lambda (calls)
                (for-each (lambda (call)
                            (let ((function (car call)))
                              (cond
                                ((equal? function 'penup) (penup))
                                ((equal? function 'pendown) (pendown))
                                ((equal? function 'setw) (setw (second call)))
                                ((equal? function 'forward) (forward (second call)))
                                ((equal? function 'back) (back (second call)))
                                ((equal? function 'left) (left (second call)))
                                ((equal? function 'right) (right (second call)))
                                ((equal? function 'setxy) (setxy (second call) (third call)))
                                ((equal? function 'setpc) (setpc (second call) (third call) (fourth call) (fifth call)))
                                (else #f))))
                          calls)))))
