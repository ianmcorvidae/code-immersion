#lang scheme
(require "../client.ss")
(sendcode '(require scheme/gui/base))
(sendcode '("all" (define width 1000)
                  (define height 1000)
                  
                  (define frame (new frame% (label "Drawing Window")
                                     (width width)
                                     (height height)))
                  
                  (define canvas
                    (new canvas% (parent frame)))
                  
                  (define dc (send canvas get-dc))
                  (send dc set-pen (make-object pen% "BLACK" 1 'transparent)) ;; No pen
                  (send dc set-smoothing 'smoothed)
                  
                  (define show-window
                    (lambda ()
                      (send frame show #t)))
                  
                  (define ellipse
                    (lambda (x y width height r g b a)
                      (send dc set-brush (make-object brush% (make-object color% r g b) 'solid))
                      (send dc set-alpha a)
                      (send dc draw-ellipse x y width height)))
                  
                  (define rectangle
                    (lambda (x y width height r g b a)
                      (send dc set-brush (make-object brush% (make-object color% r g b) 'opaque))
                      (send dc set-alpha a)
                      (send dc draw-rectangle x y width height)))
                  
                  (define line
                    (lambda (x1 y1 x2 y2 width r g b a)
                      (let ((pen (make-object pen% "BLACK" width 'solid)))
                        (send pen set-color r g b)
                        (send dc set-pen pen)
                        (send dc set-alpha a)
                        (send dc draw-line x1 y1 x2 y2))
                      (send dc set-pen (make-object pen% "BLACK" 1 'transparent))))
                  
                  (define clear
                    (lambda ()
                      (rectangle 0 0 width height 255 255 255 1.0)))))
(sendcode '(show-window))
