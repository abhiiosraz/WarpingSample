//
//  ViewController.swift
//  SwiftGoo
//
//  Created by Simon Gladman on 13/04/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    lazy var toolbar: UIToolbar =
    {
        [unowned self] in
        
        let toolbar = UIToolbar()
        
        let loadBarButtonItem = UIBarButtonItem(
            title: "Load",
            style: .plain,
            target: self,
            action: #selector(ViewController.loadImage))
        
        let resetBarButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(ViewController.reset))
        
        let spacer = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
            target: nil,
            action: nil)
        
         toolbar.setItems([loadBarButtonItem, spacer, resetBarButtonItem], animated: true)
        
        return toolbar
    }()
    @IBOutlet weak var scrollView:PassTouchesScrollView!
    @IBOutlet weak var enableZoom:UIButton!
    
    var isZoom = Bool()
    
    let imageView = OpenGLImageView()
    
//    var mona = CIImage(image: UIImage(named: "monalisa.jpg")!)!
    var mona = CIImage(image: UIImage(named: "IMG_4546.JPG")!)!

//    var accumulator = CIImageAccumulator(
//        extent: CGRect(x: 0, y: 0, width: 640, height: 640),
//        format: CIFormat.ARGB8)
    var accumulator = CIImageAccumulator()
    
    let warpKernel = CIWarpKernel(source:
        "kernel vec2 gooWarp(float radius, float force,  vec2 location, vec2 direction)" +
        "{ " +
        " float dist = distance(location, destCoord()); " +
        
        "  if (dist < radius)" +
        "  { " +
            
        "     float normalisedDistance = 1.0 - (dist / radius); " +
        "     float smoothedDistance = smoothstep(0.0, 1.0, normalisedDistance); " +
            
        "    return destCoord() + (direction * force) * smoothedDistance; " +
        "  } else { " +
        "  return destCoord();" +
        "  }" +
        "}")!
    
    var lastScale = 1.0
    var gestureRecognizer = UITapGestureRecognizer()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        scrollView.delegatePass = self
        view.backgroundColor = UIColor.darkGray
        imageView.backgroundColor = UIColor.red
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.addSubview(imageView)
        view.addSubview(toolbar)
        if #available(iOS 10.0, *) {
            accumulator = CIImageAccumulator(
                extent: CGRect(x: 0, y: 0, width: mona.cgImage?.width ?? 365, height: mona.cgImage?.height ?? 700 - 50),
                format: CIFormat.ARGB8) ?? CIImageAccumulator()
        } else {
            // Fallback on earlier versions
        }
        accumulator.setImage(mona)
        
        imageView.image = accumulator.image()
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(sender:)))
//        self.view.addGestureRecognizer(pinch)
      //  imageView.addGestureRecognizer(pinch)
        
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(gestureRecognizer)
        
    }
    @objc func handleDoubleTap() {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(2.0, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
        } else {
//            if #available(iOS 11.0, *) {
//                scrollView.contentInsetAdjustmentBehavior = .never
//            } else {
//                // Fallback on earlier versions
//            }
//          //  scrollView.setContentOffset(scrollView.contentOffset, animated: true)
            //scrollView.setZoomScale(1, animated: true)
            // scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            self.scrollView.isScrollEnabled = false
        }
    }
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = imageView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    @objc func scaleImage(sender: UIPinchGestureRecognizer){
        imageView.bringSubviewToFront(sender.view!)

        if sender.state == .ended {
            lastScale = Double(sender.scale) //global float variable.
            return
        }
        
//        print(sender.scale)
//        var senderScale = 1.0
//        if sender.scale > 4.0 {
//            senderScale = 4.0
//        }else if sender.scale < 1.0 {
//            senderScale = 1.0
//        }
        var scale = 1.0 - (lastScale - Double(sender.scale))
        print("Sender Scale ->",sender.scale)
        print("Final scale -> ",scale)
        if scale < 1.00{
            scale = 1.00
        }else if scale > 1.06{
            scale = 1.06
        }
        let currentTransform = sender.view?.transform
        let newTransform = currentTransform?.scaledBy(x: CGFloat(scale), y: CGFloat(scale))

        sender.view?.transform = newTransform!
    }

    // MARK: Layout
    
    override func viewDidLayoutSubviews()
    {
        toolbar.frame = CGRect(
            x: 0,
            y: view.frame.height - toolbar.intrinsicContentSize.height,
            width: view.frame.width,
            height: toolbar.intrinsicContentSize.height)
        
//        imageView.frame = CGRect(
//            x: 0,
//            y: topLayoutGuide.length + 5,
//            width: scrollView.frame.width,
//            height: scrollView.frame.height -
//                topLayoutGuide.length -
//                toolbar.intrinsicContentSize.height - 10)
        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.frame.width,
            height: scrollView.frame.height)
       // imageView.contentMode = .scaleAspectFit
    }
    @IBAction func enableAndDisableZoom(_ sender: UIButton){
        if enableZoom.title(for: .normal) == "Enable zoom"{
            enableZoom.setTitle("Disable zoom", for: .normal)
            //scrollView.isUserInteractionEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = true
            isZoom = true
        }else{
            enableZoom.setTitle("Enable zoom", for: .normal)
            //scrollView.isUserInteractionEnabled = true
            scrollView.pinchGestureRecognizer?.isEnabled = false

            isZoom = false
        }
    }
     func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return .lightContent
    }
    
    // MARK: Image loading
    
    @objc func loadImage()
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.isModalInPopover = false
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARL: Reset
    
    @objc func reset()
    {
        accumulator.setImage(mona)
        
        imageView.image = accumulator.image()
    }
    
    // MARK: Touch handling
  
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

//        guard let touch = touches.first,
//              let coalescedTouches = event?.coalescedTouches(for: touch), imageView.imageExtent.contains(touch.location(in: imageView)) else
//        {
//            return
//        }
//
//        for coalescedTouch in coalescedTouches
//        {
//            let locationInImageY = (imageView.frame.height - coalescedTouch.location(in: imageView).y - imageView.imageExtent.origin.y) / imageView.imageScale
//            let locationInImageX = (coalescedTouch.location(in: imageView).x - imageView.imageExtent.origin.x) / imageView.imageScale
//
//            let location = CIVector(
//                x: locationInImageX,
//                y: locationInImageY)
//
//            let directionScale = 2 / imageView.imageScale
//
//            let direction = CIVector(
//                x: (coalescedTouch.previousLocation(in: imageView).x - coalescedTouch.location(in: imageView).x) * directionScale,
//                y: (coalescedTouch.location(in: imageView).y - coalescedTouch.previousLocation(in: imageView).y) * directionScale)
//
//            let r = max(mona.extent.width, mona.extent.height) / 10
//            let radius: CGFloat
//            let force: CGFloat
//
//            if coalescedTouch.maximumPossibleForce == 0
//            {
//                force = 0.2
//                radius = r
//            }
//            else
//            {
//                let normalisedForce = coalescedTouch.force / coalescedTouch.maximumPossibleForce
//                force = 0.2 + (normalisedForce * 0.2)
//                radius = (r / 2) + (r * normalisedForce)
//            }
//
//            let arguments = [radius, force, location, direction] as [Any]
//
//            let image = warpKernel.apply(
//                extent: (accumulator.image().extent),
//                roiCallback:
//                    {
//                        (index, rect) in
//                        return rect
//                    },
//                image: (accumulator.image()),
//                arguments: arguments)
//
//            accumulator.setImage(image!)
//        }
//
//        imageView.image = accumulator.image()
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        if let rawImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        {
            let scale = 1280 / max(rawImage.size.width, rawImage.size.height)
            
            mona = CIImage(
                cgImage: rawImage as! CGImage)
                .applyingFilter("CILanczosScaleTransform", parameters: [kCIInputScaleKey: scale])
            accumulator = CIImageAccumulator(
                extent: mona.extent,
                format: CIFormat.ARGB8)!
            
            accumulator.setImage(mona)
            imageView.image = accumulator.image()
        }
        
        dismiss(animated: true, completion: nil)
    }
}
extension ViewController:PassTouchesScrollViewDelegate{
    func touchMoved(_ touches: Set<UITouch>, event: UIEvent?) {
        guard let touch = touches.first,
              let coalescedTouches = event?.coalescedTouches(for: touch), imageView.imageExtent.contains(touch.location(in: imageView)) else
        {
            return
        }
        let scalMulti = scrollView.zoomScale
        for coalescedTouch in coalescedTouches
        {
            let locationInImageY = (imageView.frame.height - coalescedTouch.location(in: imageView).y - imageView.imageExtent.origin.y) / imageView.imageScale
            let locationInImageX = (coalescedTouch.location(in: imageView).x - imageView.imageExtent.origin.x) / imageView.imageScale

            
            
            print("Image height ->", imageView.frame.height)
            print("Image width ->", imageView.frame.width)
            print("zoom scale ->",scrollView.zoomScale,"And image scale ->",imageView.imageScale)
            //print("Points ->", locationInImageY, locationInImageX)

//            let location = CIVector(
//                x: locationInImageX,
//                y: locationInImageY)
            let location = CIVector(
                x: gestureRecognizer.location(in: gestureRecognizer.view).x,
                y: gestureRecognizer.location(in: gestureRecognizer.view).y)
            
            print("Location ->",location)
            
            
            let directionScale = (2 / imageView.imageScale)
          
            let direction = CIVector(
                x: (coalescedTouch.previousLocation(in: imageView).x - coalescedTouch.location(in: imageView).x) * directionScale,
                y: (coalescedTouch.location(in: imageView).y - coalescedTouch.previousLocation(in: imageView).y) * directionScale)
            
            print("Direction ->",direction)
          
            let r = max(mona.extent.width, mona.extent.height) / 10
            let radius: CGFloat
            let force: CGFloat
     
            if coalescedTouch.maximumPossibleForce == 0
            {
                force = 0.2
                radius = r
            }
            else
            {
                let normalisedForce = coalescedTouch.force / coalescedTouch.maximumPossibleForce
                force = 0.2 + (normalisedForce * 0.2)
                radius = (r / 2) + (r * normalisedForce)
            }

            let arguments = [radius, force, location, direction] as [Any]
            
            let image = warpKernel.apply(
                extent: (accumulator.image().extent),
                roiCallback:
                    {
                        (index, rect) in
                        return rect
                    },
                image: (accumulator.image()),
                arguments: arguments)
            
            accumulator.setImage(image!)
        }
         
        imageView.image = accumulator.image()
    }
    func touchBegan() {
        print("Touches begain")
    }
}
extension ViewController:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      //  return isZoom ? imageView : nil
       // if isZoom{
            return imageView
//        }
//        else{
//            return nil
//        }
    }
}

