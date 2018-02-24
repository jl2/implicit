;;;; implicit.lisp
;;
;;;; Copyright (c) 2018 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>


(in-package #:implicit)

(defun draw-implicit-line (i equation png xmin xmax ymin ymax tol)
  "Draw row i of an implicit equation plot."
  (declare (type fixnum i)
           (type function equation)
           (type (simple-array (unsigned-byte 8)) png)
           (type double-float  xmin xmax ymin ymax)
           (type (simple-array (unsigned-byte 8)) png))
  (let ((yp (ju:i-map-val i (sp:height png) ymin ymax)))
    (dotimes (j (sp:width png))
      (declare (type fixnum j)
               (type double-float yp))
      
      (let ((xp (ju:i-map-val j (sp:width png) xmax xmin)))
        (declare (type double-float xp))
        (when (> tol (abs (funcall equation xp yp)))
          (sp:set-rgb png j i 0  200 0))))))

(defun plot (file-name equation &key (width 1600) (height 1200) (xmin -2.0) (xmax 2.0) (ymin -2.0) (ymax 2.0) (tol 0.02))
  "Plot an implicit equation of the form f(x, y) = 0."
  (declare (type fixnum width height)
           (type function equation)
           (type string file-name)
           (type double-float xmin xmax ymin ymax tol))
  (ensure-directories-exist file-name)
  (let* ((png (sp:create-png width height))
         (aspect-ratio (if (> width height) (/ width height 1.0) (/ height width 1.0)))
         (wq (wq:create-work-queue (rcurry #'draw-implicit-line
                                           equation
                                           png
                                           (* aspect-ratio xmin)
                                           (* aspect-ratio xmax)
                                           ymin
                                           ymax
                                           tol))))
    (dotimes (i height)
      (wq:add-job wq i))
    (wq:destroy-work-queue wq)
    (sp:write-png png file-name)))


(defun implicit-animation (equation output-directory
                           &key
                             (frame-count (* 30 10))
                             (width 800) (height 600)
                             (xmin -2.0) (xmax 2.0)
                             (ymin -2.0) (ymax 2.0)
                             (zmin -1.0) (zmax 1.0)
                             (tol 0.02))
  "Generate a series of PNG images into output-directory showing where f(x, y) - z = 0, for z between zmin and zmax."
  (declare (type fixnum width height frame-count)
           (type function equation)
           (type string output-directory)
           (type double-float xmin xmax ymin ymax tol))
  (let ((real-dir-name (ensure-directories-exist
                        (if (char=  #\/ (aref output-directory (- (length output-directory) 1)))
                            output-directory
                            (concatenate 'string output-directory "/")))))
    (dotimes (i frame-count)
      (let ((cur-depth (ju:i-map-val i frame-count zmin zmax))
            (output-file-name (format nil "~aframe~8,'0d.png" real-dir-name i)))
        (implicit:plot output-file-name
                       (lambda (x y) (- (funcall equation x y) cur-depth))
                       :width width :height height
                       :xmin xmin :xmax xmax
                       :ymin ymin :ymax ymax
                       :tol tol)))))
